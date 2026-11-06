# Migración de ADF Pedro Larrea (v1) a DigiSports

Convierte una copia de la base de ADF Pedro Larrea v1 en una base DigiSports.
Ensayada el 2026-11-05 sobre `digitech_migra_adfpl`, copia de
`digitech_adfpl`. La base de origen nunca se toca: se trabaja sobre una copia.

Variante de `../migracion_champions/` (SoccerEasy → DigiSports). Usa sus
archivos genéricos y sustituye solo los que llevan decisiones de Champions.

## En qué se diferencia ADF de SoccerEasy

Comparado columna a columna contra `digitech_soccereasy` el 2026-11-05:

| ADF v1 | qué hace el `000_previo_adfpl.sql` |
|---|---|
| ya tiene `alumno_consentimiento` (idéntica a la del 000 de Champions) | no la crea; crea las otras ocho tablas de ese 000 (configuración de carnet y facturación electrónica) |
| no tiene `alumno_carnet`, `carnet_catcolor`, `carnet_mes_color` (nunca emitió carnés) | las crea con la forma de SoccerEasy, los 24 colores y un color por mes **sin bloquear** |
| no tiene `alumno_representante.repre_factura` ni las tres columnas del carné vertical de `general_escuela` | las agrega (`repre_factura = 'N'`; `vertical_azul.png`, `vertical_fondo.jpg`, `vertical_principal.jpg`) |
| no tiene `facturacion_factura(_pago)` | nada: la 065 de SoccerEasy solo las borraba |
| `sujeto_alumno.alumno_fechamodificacion` (NOT NULL sin valor por defecto) y `alumno_observacion` | se conservan; la fecha pasa a admitir NULL: DigiSports no la llena y con `STRICT_TRANS_TABLES` (producción) todo alta de alumno fallaría con 1364 |
| `conyuge_sexo` CHAR(1) | VARCHAR(1), como el resto |
| menú 46 «Inscripción Online» es la pantalla de enlaces, no un grupo | pasa a «Generar enlaces»: la 010 crea el grupo solo si no hay un menú con ese nombre |
| el usuario 3 (Secretaria) apunta al empleado 1, que no existe | queda sin vínculo (`NULL`), lo que hace `fk_usuario_empleado` al borrar un empleado; si no, la 008 no puede crear esa clave |

Los menús 1 a 38 son los de SoccerEasy con los mismos ids. Del 39 al 48
ADF tiene los suyos (Pensión por alumno, Estadísticas, Imágenes,
Cumpleaños, Inscripción y LOPDP) y las migraciones los tratan por vista,
no por id.

## Qué cambia respecto a Champions

| paso | ADF Pedro Larrea |
|---|---|
| `pre_retirar_residuos_qa` | **no se aplica** (residuos del arnés en la base de Champions) |
| `000` | `000_previo_adfpl.sql` (tabla de arriba) |
| `001`–`064` | iguales, con `015` y `041` de `migracion_champions/` |
| `014` | `014_permisos_opciones_nuevas.adfpl.sql`: la de Champions concede por **id** de rol, y su rol 6 («Asistente» en barcelona) en ADF es el **Gerente**: le daba Generar enlaces y Facturación, y le rebajaba Cumpleaños. La de ADF solo concede al Administrador |
| `065` | `065_ajustes_adfpl.sql`: ver abajo |
| `066` | la de Champions (genérica) |
| `067` | `067_tarjeta_cumple_adfpl.sql`: el marco y las medidas de la tarjeta de cumpleaños de ADF v1 |
| `068` | **no se aplica** (corrige un pago de Champions) |
| `069`–`081` | las de Champions (genéricas, repetibles) |
| `082` | `082_pension_alumno_adfpl.sql`: exportar en «Pensión por alumno». Los `08x_*_adfpl.sql` siguientes entran solos en la cadena |

`065_ajustes_adfpl.sql`:

- `torneo_equipo.equipo_categoria` a texto libre, como Champions.
- **No** inserta los menús 43 y 44 de Champions: en ADF esos ids son
  «Detalle ingresos y mora» e «Imágenes», y sus permisos caerían sobre esas
  pantallas. ADF ya trae Consentimientos (47) e Inscripciones pendientes (48).
- «Generar enlaces» dentro del grupo «Inscripción Online».
- «Carnets del mes» (908) solo para el Administrador, y las vistas ocultas
  de League (969–973), como Champions.
- «Imágenes» (`imagenesList`) no existe en DigiSports: su equivalente es
  «Fotos de alumnos» (`alumnoFotos`). Quien tenía Imágenes (Administrador y
  Publicidad) recibe ver y editar en Fotos de alumnos, y el menú se retira.
- Facturación electrónica no se concede a ningún rol: ADF no tiene
  configuración del SRI. Se concede en Core › Permisos al configurarla.
- Logo `organizacion_adfpl.png` y firma de los recibos `RubricaADFPL.jpg`
  (la v1 la estampaba fija en el código; en DigiSports es `escuela_firma`).

ADF tiene los roles Profesor (3), Secretaria (4), Gerente (6), Asistente (7)
y Publicidad (8). No chocan con la `029`, que crea «Árbitro» y «Oficial de
mesa» por nombre (quedan con ids 9 y 10).

## Un solo comando

```bash
MYSQL=/ruta/a/mysql MYSQL_OPTS="-u USUARIO -pCLAVE" \
  ds_core/database/migracion_adfpl/aplicar_migracion.sh BASE
```

82 archivos, se detiene en el primer error. Antes de empezar exige que `BASE`
sea ADF v1 **sin migrar**: tiene `alumno_consentimiento` y no tiene
`cumple_plantilla` ni `facturas_electronicas`. Para phpMyAdmin:
`--generar ARCHIVO.sql`.

## Orden completo

1. Crear la base vacía:
   ```sql
   CREATE DATABASE nombre CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
   ```
2. Restaurar el volcado de ADF v1 con `SET default_storage_engine=InnoDB;
   SET FOREIGN_KEY_CHECKS=0;` al principio y `SET FOREIGN_KEY_CHECKS=1;` al
   final. (36 de sus 37 tablas son MyISAM; la `007` las pasa a InnoDB.)
3. `aplicar_migracion.sh BASE`.
4. Comprobar (abajo).

## Llevarla a producción

Igual que Champions (`../migracion_champions/LEEME.md`): se migra **en
desarrollo** sobre una copia del sistema congelado y a producción viaja el
resultado, volcado sin `DEFINER` e importado en la base vacía del hosting.

## Archivos fuera de la base

No van en la base ni en el repositorio, y la copia local de la v1 casi no los
tiene: se copian desde el **servidor** de ADF v1.

| ADF v1 (`app/views/…`) | DigiSports |
|---|---|
| `imagenes/fotos/alumno/`   | `ds_futbol/app/views/imagenes/fotos/alumno/`   |
| `imagenes/fotos/empleado/` | `ds_futbol/app/views/imagenes/fotos/empleado/` |
| `imagenes/fotos/ingresos/`, `egresos/`, `equipos/`, `torneos/` | `ds_futbol/app/views/imagenes/fotos/…` (mismo nombre) |
| `imagenes/ingresos/`       | `ds_futbol/app/views/imagenes/ingresos/`       |
| `imagenes/cedulas/`        | `ds_futbol/app/views/imagenes/cedulas/`        |
| `imagenes/pagos/`          | `ds_futbol/app/views/imagenes/pagos/`          |
| `fotos/` (fotos de usuario) | `ds_futbol/app/views/fotos/usuario/`          |
| `imagenes/fotos/sedes/`    | `ds_core/assets/img/marca/` (las sedes sin foto heredan el logo) |
| `imagenes/cumples/marco.png` | `ds_futbol/app/views/imagenes/cumples/marco.png` (ya copiado) |
| `imagenes/rubricas/RubricaADFPL.jpg` | `ds_core/assets/img/marca/RubricaADFPL.jpg` (ya copiado) |
| `dist/img/Logos/LogoRojo.png` | `ds_core/assets/img/marca/organizacion_adfpl.png` (ya copiado) |

La pantalla «Fotos de alumnos» dice cuántas fichas apuntan a un archivo que
falta; sin la foto, el carné de ese alumno no se genera.

ADF no factura electrónicamente: no hay `firma.p12` ni `.cryptokey.php` que
copiar.

## Comprobación del ensayo 2026-11-05

`php ds_core/database/estado_migraciones.php`: **36 aplicadas, 0 pendientes,
28 no determinables** (lo mismo que Champions y Sendero).

Esquema idéntico a `digitech_migra_champions_cf` (107 tablas y vistas, 89
claves foráneas, todo `utf8mb4_0900_ai_ci`) salvo las 2 columnas propias de
ADF en `sujeto_alumno` (`alumno_fechamodificacion`, `alumno_observacion`).

Datos contra el origen: alumnos 1029 (570 activos), representantes 877, pagos
6095 (suma 162 301,42 / saldo 922,20), transacciones 40, descuentos 232,
asistencias 6986, horarios 29, consentimientos 104, usuarios 31, empleados 28,
sedes 7 y el hash de alumnos y representantes: **idénticos**.

- `asistencia_asignahorario` 1022 → 1021: la fila que falta apuntaba al
  horario 10, que no existe, y la `008` la retira antes de crear las claves.
- `seguridad_usuario_sede` 34 → 55: la `072` da a quien no tenía sede la de
  su ficha de empleado. Comprobado usuario por usuario: los 31 ven en
  DigiSports **exactamente las mismas sedes** que en la v1.

Permisos de los roles no administradores, vista por vista contra la v1:
ninguno pierde nada salvo «Imágenes» (Publicidad), sustituida por «Fotos de
alumnos». Ganan, por diseño de DigiSports: el Dashboard en solo lectura para
el Profesor (`015`: solo le muestra el bloque operativo) y «Fotos de
alumnos» para quien administra alumnos (`060`). Árbitro y Oficial de mesa son
roles nuevos de League.

Inicio de sesión con un usuario de la v1 (Asistente, sede Méndez) y su
misma contraseña: entra y abre sus pantallas; las que no tiene asignadas
responden 403.

## Traído de ADF v1

- «Pensión por alumno» (`reportePensionAlumno`): vista
  `ds_futbol/app/views/content/reportePensionAlumno-view.php`, método
  `reporteController::pensionAlumno()` y exportar en la `082`. El menú (39)
  ya venía de la v1. Diferencias con v1:
  - Filtro de sede, acotado a las del usuario (`condicionSede`).
  - Copiar, Excel e imprimir solo con `permiso_exportar`.
  - Mismos resultados que la v1: 570 alumnos (todas las sedes), 43 en La
    Cantera.

No se trajeron (DigiSports tiene su equivalente):

| ADF v1 | DigiSports |
|---|---|
| `imagenesList`, `imagenesUpdate` | Fútbol › Fotos de alumnos |
| `dashboardGerencial` | Insights (analítica) y el dashboard operativo |
| `dashboardAlumnos` | el dashboard operativo |
| usuarios, roles, menús, permisos, sedes, escuela, tablas, catálogos | Core |
| `reportePagosReceptados` (solo administradores, sin menú) | Reportes › Resumen pagos / Consolidado pagos |
