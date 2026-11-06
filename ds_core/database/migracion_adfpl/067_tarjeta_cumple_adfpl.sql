-- 067_tarjeta_cumple_adfpl.sql
-- La tarjeta de cumpleaños como la generaba ADF Pedro Larrea v1
-- (app/views/content/cumpleaniosTarjeta-view.php del sistema anterior), en
-- lugar de 067_tarjeta_cumple_champions.
--
-- La v1 no tenia medidas fijas: buscaba en su marco.png (1080 x 1350) la
-- ventana transparente de la foto y la casilla blanca del nombre bajo
-- «Feliz Cumpleaños». Esa misma deteccion, ejecutada sobre el marco de ADF
-- el 2026-11-05, da en porcentajes del marco:
--   foto     x 32,222 %  y 19,037 %  ancho 52,037 %  alto 44,000 %
--   nombre   casilla x 41,019 %, ancho 52,685 %; letra de 40 px (3,704 %
--            del ancho), blanca, centrada; linea base en 92,474 % (centro de
--            la casilla, como la v1)
-- Sin edad ni franja: la v1 solo escribia el nombre, y el marco ya trae su
-- casilla.
--
-- El marco.png de ADF se copia a ds_futbol/app/views/imagenes/cumples/.
SET NAMES utf8mb4;

UPDATE cumple_plantilla
   SET foto_x = 32.222, foto_y = 19.037, foto_ancho = 52.037, foto_alto = 44.000,
       nombre_x = 41.019, nombre_y = 92.474, nombre_ancho = 52.685, nombre_tam = 3.704,
       nombre_color = '#FFFFFF', nombre_alinea = 'C',
       edad_texto = '',
       franja_activa = 'N',
       angulo = 0.00
 WHERE plantilla_archivo = 'marco.png';
