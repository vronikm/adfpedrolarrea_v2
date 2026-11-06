-- 065_ajustes_adfpl.sql
-- Ajustes posteriores de ADF Pedro Larrea, en lugar de 065_ajustes_champions.
--
-- Lo que se toma de la de Champions (generico):
--   - torneo_equipo.equipo_categoria pasa a texto libre ("Sub 15").
--   - el menu «Carnets del mes» (908) y las vistas ocultas de League
--     (969-973) con sus permisos de League.
--   - Facturacion no se concede mientras no haya configuracion del SRI
--     (ADF Pedro Larrea nunca facturo electronicamente).
--
-- Lo que NO se toma: los menus 43 y 44. En Champions eran «Consentimientos
-- LOPDP» e «Inscripciones pendientes»; en ADF los ids 43 y 44 ya son
-- «Detalle ingresos y mora» e «Imagenes», y sus permisos caerian sobre
-- esas pantallas. ADF ya trae esos dos menus (47 y 48) y la 010 los colgo
-- del grupo «Inscripción Online».
--
-- Propio de ADF:
--   - «Generar enlaces» (inscripcionEnlace, menu 46) se cuelga del grupo
--     «Inscripción Online», como en DigiSports.
--   - «Imagenes» (imagenesList) no existe en DigiSports: su equivalente es
--     «Fotos de alumnos» (alumnoFotos). Quien tenia Imagenes recibe ver y
--     editar en Fotos de alumnos (lo que la 060 concede) y el menu se retira.
--   - Carnets del mes solo para el Administrador: ADF no emitia carnes.
--   - Logo de la organizacion.
--
-- Idempotente.
SET NAMES utf8mb4;

-- Categorias de texto libre, como en barcelona y Champions.
ALTER TABLE torneo_equipo MODIFY equipo_categoria VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL;

-- ---------------------------------------------------------------------
-- Inscripcion Online: «Generar enlaces» dentro del grupo
-- ---------------------------------------------------------------------
UPDATE seguridad_menu m
  JOIN (SELECT menu_id FROM seguridad_menu
         WHERE menu_modulo = 'basketball' AND menu_nombre = 'Inscripción Online'
           AND menu_hijo = 'S' LIMIT 1) g
   SET m.menu_padreid = g.menu_id,
       m.menu_orden   = 1,
       m.menu_nombre  = 'Generar enlaces',
       m.menu_icono   = 'nav-icon fas fa-link'
 WHERE m.menu_modulo = 'basketball' AND m.menu_vista = 'inscripcionEnlace';

-- ---------------------------------------------------------------------
-- Carnets del mes y vistas ocultas de League (mismos ids que Champions)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO seguridad_menu
       (menu_id, menu_modulo, menu_nombre, menu_orden, menu_padreid, menu_hijo, menu_vista, menu_icono, menu_estado)
VALUES (908, 'basketball', 'Carnets del mes',  18,  0,    'N', 'carnetList',     'nav-icon far fa-address-card', 'A'),
       (969, 'league',     'Plantilla',        70,  NULL, 'N', 'plantillaPanel', 'fas fa-id-card',               'O'),
       (970, 'league',     'Sorteo',           80,  NULL, 'N', 'sorteoPanel',    'fas fa-random',                'O'),
       (971, 'league',     'Eliminatorias',    90,  NULL, 'N', 'playoffPanel',   'fas fa-sitemap',               'O'),
       (972, 'league',     'Acta del partido', 100, NULL, 'N', 'actaPartido',    'fas fa-clipboard-list',        'O'),
       (973, 'league',     'Líderes',          110, NULL, 'N', 'rankingPanel',   'fas fa-medal',                 'O');

INSERT IGNORE INTO seguridad_permiso
       (permiso_rolid, permiso_menuid, permiso_ver, permiso_crear, permiso_editar,
        permiso_eliminar, permiso_exportar, permiso_estado)
SELECT r.rol_id, v.menuid, v.ver, v.crear, v.editar, v.eliminar, v.exportar, v.estado
  FROM (          SELECT 'Administrador'       rol, 908 menuid, 'S' ver, 'S' crear, 'S' editar, 'N' eliminar, 'N' exportar, 'A' estado
        UNION ALL SELECT 'Super Administrador',     969, 'S', 'S', 'S', 'S', 'N', 'A'
        UNION ALL SELECT 'Super Administrador',     970, 'S', 'S', 'S', 'S', 'N', 'A'
        UNION ALL SELECT 'Super Administrador',     971, 'S', 'S', 'S', 'S', 'N', 'A'
        UNION ALL SELECT 'Árbitro',                 972, 'S', 'N', 'S', 'N', 'N', 'A'
        UNION ALL SELECT 'Oficial de mesa',         972, 'S', 'N', 'S', 'N', 'N', 'A'
        UNION ALL SELECT 'Super Administrador',     972, 'S', 'S', 'S', 'S', 'N', 'A'
        UNION ALL SELECT 'Super Administrador',     973, 'S', 'S', 'S', 'S', 'N', 'A') v
  JOIN seguridad_rol r ON r.rol_nombre = v.rol;

-- ---------------------------------------------------------------------
-- Imagenes -> Fotos de alumnos
-- ---------------------------------------------------------------------
INSERT IGNORE INTO seguridad_permiso
       (permiso_rolid, permiso_menuid, permiso_ver, permiso_crear, permiso_editar,
        permiso_eliminar, permiso_exportar, permiso_estado)
SELECT p.permiso_rolid, f.menu_id, 'S', 'N', 'S', 'N', 'N', 'A'
  FROM seguridad_permiso p
  JOIN seguridad_menu i ON i.menu_id = p.permiso_menuid AND i.menu_vista = 'imagenesList'
  JOIN seguridad_menu f ON f.menu_modulo = 'basketball' AND f.menu_vista = 'alumnoFotos';

-- Sus permisos se van con el menu (fk_permiso_menu es ON DELETE CASCADE).
DELETE FROM seguridad_menu WHERE menu_modulo = 'basketball' AND menu_vista = 'imagenesList';

-- ---------------------------------------------------------------------
-- Facturacion: sin configuracion del SRI no se concede a nadie (el Super
-- Administrador entra igual). Se concede en Core > Permisos al configurarla.
-- La 070 crea «Facturas emitidas» con los permisos de esta entrada.
-- ---------------------------------------------------------------------
DELETE p FROM seguridad_permiso p
  JOIN seguridad_menu m ON m.menu_id = p.permiso_menuid
 WHERE m.menu_vista = 'facturasList';

-- Logo de ADF Pedro Larrea en la carpeta de marca de Core
-- (ds_core/assets/img/marca/; el archivo de la v1 no se migra con la base).
UPDATE general_escuela SET escuela_logo = 'organizacion_adfpl.png' WHERE escuela_id = 1;

-- La v1 estampaba app/views/imagenes/rubricas/RubricaADFPL.jpg en los
-- recibos, fija en el codigo. En DigiSports la firma de los recibos es
-- escuela_firma (o la de cada sede), en la misma carpeta de marca.
UPDATE general_escuela SET escuela_firma = 'RubricaADFPL.jpg'
 WHERE escuela_id = 1 AND IFNULL(escuela_firma, '') = '';
