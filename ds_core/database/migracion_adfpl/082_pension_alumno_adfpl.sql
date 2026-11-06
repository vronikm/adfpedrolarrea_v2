-- 082_pension_alumno_adfpl.sql
-- «Pensión por alumno» (reportePensionAlumno), traída de ADF Pedro Larrea v1
-- a DigiSports: vista ds_futbol/app/views/content/reportePensionAlumno-view.php
-- y reporteController::pensionAlumno().
--
-- El menu ya viene de la v1 (bajo «Reportes», con sus permisos). En DigiSports
-- copiar, Excel e imprimir exigen permiso_exportar, que la 045 dejo en N. En
-- la v1 esos botones salian siempre, asi que quien tenia el reporte conserva
-- la exportacion. Se retira en Core > Permisos.
--
-- Idempotente.
SET NAMES utf8mb4;

UPDATE seguridad_permiso p
  JOIN seguridad_menu m ON m.menu_id = p.permiso_menuid
   SET p.permiso_exportar = 'S'
 WHERE m.menu_modulo = 'basketball' AND m.menu_vista = 'reportePensionAlumno'
   AND p.permiso_ver = 'S';
