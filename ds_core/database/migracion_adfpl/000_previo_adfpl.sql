-- 000_previo_adfpl.sql
-- Paso previo de ADF Pedro Larrea, equivalente al 000_previo_champions.
--
-- ADF Pedro Larrea v1 es SoccerEasy con estas diferencias (comparado columna
-- a columna contra digitech_soccereasy el 2026-11-05):
--   - ya tiene alumno_consentimiento, identica a la del 000 de Champions:
--     no se crea.
--   - le faltan las tablas de carnes (alumno_carnet, carnet_catcolor,
--     carnet_mes_color): nunca emitio carnes. Se crean con la forma de
--     SoccerEasy, el catalogo de colores y un color por mes sin bloquear.
--   - le faltan alumno_representante.repre_factura y las tres columnas del
--     carne vertical en general_escuela.
--   - facturacion_factura(_pago) no existen: la 065 de SoccerEasy solo las
--     borraba.
--   - sujeto_alumno trae alumno_fechamodificacion (NOT NULL sin valor por
--     defecto) y alumno_observacion. Se conservan; la primera pasa a admitir
--     NULL, porque DigiSports no la llena y con STRICT_TRANS_TABLES (el modo
--     de produccion) todo INSERT de un alumno fallaria con el error 1364.
--   - alumno_representanteconyuge.conyuge_sexo es CHAR(1) y no VARCHAR(1).
--   - el menu 46 se llama «Inscripción Online» y es la pantalla de enlaces,
--     no un grupo: la 010 crea el grupo solo si no hay un menu con ese nombre,
--     y lo confundiria con esta pantalla. Pasa a llamarse «Generar enlaces»,
--     como en DigiSports; la 065 de ADF lo cuelga del grupo.
--
-- Despues, lo mismo que el 000 de Champions: las ocho tablas que barcelona ya
-- tenia (configuracion de carnet y facturacion electronica) y el
-- representante 0 "sin vinculo" en NULL para la 008.
SET NAMES utf8mb4;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carnet_configuracion` (
  `config_id` int NOT NULL AUTO_INCREMENT,
  `config_clave` varchar(80) NOT NULL,
  `config_valor` varchar(255) NOT NULL,
  `config_descripcion` varchar(255) DEFAULT NULL,
  `config_fecha_actualizacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `config_clave` (`config_clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `alumno_id` int NOT NULL,
  `representante_id` int NOT NULL,
  `clave_acceso` varchar(49) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `tipo_comprobante` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '01',
  `establecimiento` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `punto_emision` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `secuencial` char(9) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `fecha_emision` date NOT NULL,
  `ambiente` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1',
  `tipo_emision` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1',
  `cliente_tipo_identificacion` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `cliente_identificacion` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `cliente_razon_social` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `cliente_direccion` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cliente_email` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cliente_telefono` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `subtotal_iva` decimal(14,2) NOT NULL DEFAULT '0.00',
  `subtotal_0` decimal(14,2) NOT NULL DEFAULT '0.00',
  `subtotal_no_objeto` decimal(14,2) NOT NULL DEFAULT '0.00',
  `subtotal_exento` decimal(14,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(14,2) NOT NULL DEFAULT '0.00',
  `descuento` decimal(14,2) NOT NULL DEFAULT '0.00',
  `iva` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `estado_sri` enum('PENDIENTE','GENERADA','FIRMADA','ENVIADA','RECIBIDA','DEVUELTA','AUTORIZADO','NO_AUTORIZADO','ERROR','ANULADA') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'GENERADA',
  `xml_generado` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `xml_firmado` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `xml_autorizado` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `ride_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `numero_autorizacion` varchar(49) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `fecha_autorizacion` datetime DEFAULT NULL,
  `mensaje_error` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clave_acceso` (`clave_acceso`),
  UNIQUE KEY `uk_fe_numero` (`tipo_comprobante`,`establecimiento`,`punto_emision`,`secuencial`),
  KEY `idx_fe_alumno` (`alumno_id`),
  KEY `idx_fe_representante` (`representante_id`),
  KEY `idx_fe_fecha` (`fecha_emision`),
  KEY `idx_fe_estado` (`estado_sri`),
  KEY `idx_fe_numero` (`establecimiento`,`punto_emision`,`secuencial`),
  KEY `idx_fe_cliente` (`cliente_identificacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas_certificado` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cert_lock` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'X',
  `archivo` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `nombre_original` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `ruc_certificado` varchar(13) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `razon_social` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `serial` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `valido_desde` datetime DEFAULT NULL,
  `valido_hasta` datetime DEFAULT NULL,
  `estado` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'NO_CONFIGURADO',
  `clave_cifrada` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `updated_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cert_lock` (`cert_lock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `config_lock` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'X',
  `ambiente` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1',
  `tipo_emision` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1',
  `iva_tarifa_default` decimal(5,2) NOT NULL DEFAULT '0.00',
  `forma_pago_default` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '20',
  `valores_incluyen_iva` tinyint(1) NOT NULL DEFAULT '1',
  `secuencial_inicio` int NOT NULL DEFAULT '1',
  `ruc` varchar(13) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `razon_social` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `nombre_comercial` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `direccion_matriz` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `direccion_establecimiento` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `codigo_establecimiento` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '001',
  `punto_emision` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '001',
  `obligado_contabilidad` enum('SI','NO') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'NO',
  `contribuyente_especial` varchar(13) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `agente_retencion` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `contribuyente_rimpe` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `updated_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_lock` (`config_lock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas_detalle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `factura_electronica_id` int NOT NULL,
  `pago_id` int DEFAULT NULL,
  `codigo_principal` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `descripcion` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `cantidad` decimal(14,6) NOT NULL DEFAULT '1.000000',
  `precio_unitario` decimal(14,6) NOT NULL DEFAULT '0.000000',
  `descuento` decimal(14,2) NOT NULL DEFAULT '0.00',
  `precio_total_sin_impuesto` decimal(14,2) NOT NULL DEFAULT '0.00',
  `iva_tarifa` decimal(5,2) NOT NULL DEFAULT '0.00',
  `iva_codigo_porcentaje` char(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '0',
  `iva_valor` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fed_factura` (`factura_electronica_id`),
  KEY `idx_fed_pago` (`pago_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas_forma_pago` (
  `codigo` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `orden` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas_pagos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `factura_electronica_id` int NOT NULL,
  `forma_pago` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '20',
  `total` decimal(14,2) NOT NULL DEFAULT '0.00',
  `plazo` int DEFAULT NULL,
  `unidad_tiempo` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'dias',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fep_factura` (`factura_electronica_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facturas_electronicas_secuenciales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo_comprobante` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '01',
  `establecimiento` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `punto_emision` char(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `secuencial_actual` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fe_secuencial` (`tipo_comprobante`,`establecimiento`,`punto_emision`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO carnet_configuracion (config_clave, config_valor, config_descripcion, config_fecha_actualizacion) VALUES
 ('cobrar_reimpresion','0','Define si la reimpresion de carnets genera cargo ROT',NOW()),
 ('valor_reimpresion','3.00','Configuracion automatica de carnets',NOW());

-- ---------------------------------------------------------------------
-- Carnes (forma de SoccerEasy; la 041 unifica el cotejamiento y la 062
-- agrega el anio a carnet_mes_color)
-- ---------------------------------------------------------------------
CREATE TABLE `alumno_carnet` (
  `carnet_id` int NOT NULL AUTO_INCREMENT,
  `carnet_mes` int NOT NULL COMMENT 'Mes de vigencia (1-12)',
  `carnet_anio` int NOT NULL,
  `carnet_alumnoid` int DEFAULT NULL,
  `carnet_fecha_emision` date DEFAULT NULL,
  `carnet_fecha_impresion` date DEFAULT NULL,
  PRIMARY KEY (`carnet_id`),
  KEY `carnet_mes` (`carnet_mes`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `carnet_catcolor` (
  `catcolor_id` int NOT NULL AUTO_INCREMENT,
  `catcolor_nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `catcolor_hex` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `catcolor_activo` tinyint(1) DEFAULT '1',
  `catcolor_fechacreacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`catcolor_id`),
  UNIQUE KEY `unique_catcolor_hex` (`catcolor_hex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `carnet_mes_color` (
  `mcolor_id` int NOT NULL AUTO_INCREMENT,
  `mcolor_mes` int NOT NULL COMMENT '1=Enero, 2=Febrero, ..., 12=Diciembre',
  `mcolor_catcolorid` int NOT NULL COMMENT 'Color asignado (referencia a catalogo_colores)',
  `mcolor_bloqueado` tinyint(1) DEFAULT '0' COMMENT '1=Bloqueado (hay carnets emitidos)',
  `mcolor_activo` tinyint(1) DEFAULT '1',
  `mcolor_fechacreacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `mcolor_fechamod` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`mcolor_id`),
  UNIQUE KEY `mcolor_mes` (`mcolor_mes`),
  UNIQUE KEY `unique_color_asignado` (`mcolor_catcolorid`) COMMENT 'Un color solo puede estar en un mes'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO carnet_catcolor (catcolor_id, catcolor_nombre, catcolor_hex) VALUES
 (1,'Rojo','#FF0000'),(2,'Verde','#00FF00'),(3,'Azul','#0000FF'),(4,'Amarillo','#FFFF00'),
 (5,'Morado','#800080'),(6,'Naranja','#FFA500'),(7,'Rosa','#FFC0CB'),(8,'Celeste','#00CED1'),
 (9,'Café','#8B4513'),(10,'Gris','#808080'),(11,'Negro','#000000'),(12,'Blanco','#FFFFFF'),
 (13,'Rojo Coral','#FF6B6B'),(14,'Turquesa','#4ECDC4'),(15,'Azul Cielo','#45B7D1'),(16,'Verde Menta','#96CEB4'),
 (17,'Amarillo Suave','#FFEAA7'),(18,'Gris Perla','#DFE6E9'),(19,'Azul Claro','#74B9FF'),(20,'Lavanda','#A29BFE'),
 (21,'Rosa Pastel','#FD79A8'),(22,'Naranja Suave','#FDCB6E'),(23,'Púrpura','#6C5CE7'),(24,'Verde Limón','#00BF63');

-- Un color por mes, sin bloquear (no hay carnes emitidos). Se cambia en Core.
INSERT INTO carnet_mes_color (mcolor_mes, mcolor_catcolorid) VALUES
 (1,2),(2,13),(3,19),(4,8),(5,5),(6,22),(7,1),(8,3),(9,12),(10,21),(11,24),(12,17);

-- ---------------------------------------------------------------------
-- Columnas que SoccerEasy tenia y ADF no
-- ---------------------------------------------------------------------
ALTER TABLE alumno_representante
  ADD COLUMN repre_factura CHAR(1) NOT NULL DEFAULT 'N';

ALTER TABLE general_escuela
  ADD COLUMN escuela_verticalcolor     VARCHAR(50) NOT NULL DEFAULT '',
  ADD COLUMN escuela_verticalfondo     VARCHAR(50) NOT NULL DEFAULT '',
  ADD COLUMN escuela_verticalprincipal VARCHAR(50) NOT NULL DEFAULT '';
UPDATE general_escuela
   SET escuela_verticalcolor     = 'vertical_azul.png',
       escuela_verticalfondo     = 'vertical_fondo.jpg',
       escuela_verticalprincipal = 'vertical_principal.jpg';
ALTER TABLE general_escuela
  ALTER COLUMN escuela_verticalcolor DROP DEFAULT,
  ALTER COLUMN escuela_verticalfondo DROP DEFAULT,
  ALTER COLUMN escuela_verticalprincipal DROP DEFAULT;

ALTER TABLE alumno_representanteconyuge MODIFY conyuge_sexo VARCHAR(1) NOT NULL;

-- Propias de ADF: se conservan, la fecha admite NULL (ver cabecera).
ALTER TABLE sujeto_alumno MODIFY alumno_fechamodificacion DATETIME NULL DEFAULT NULL;

-- ---------------------------------------------------------------------
-- Menu 46: pantalla de enlaces, no grupo (ver cabecera)
-- ---------------------------------------------------------------------
UPDATE seguridad_menu SET menu_nombre = 'Generar enlaces'
 WHERE menu_vista = 'inscripcionEnlace' AND menu_hijo = 'N';

-- Representante 0 "sin vinculo" -> NULL, para la 008.
ALTER TABLE sujeto_alumno MODIFY alumno_repreid INT NULL;
UPDATE sujeto_alumno SET alumno_repreid = NULL WHERE alumno_repreid = 0;

-- El usuario 3 (Secretaria) apunta al empleado 1, que ya no existe: la 008
-- no podria crear fk_usuario_empleado. Queda sin vinculo, que es lo que esa
-- misma clave hace al borrar un empleado (ON DELETE SET NULL).
UPDATE seguridad_usuario s
  LEFT JOIN sujeto_empleado e ON e.empleado_id = s.usuario_empleadoid
   SET s.usuario_empleadoid = NULL
 WHERE s.usuario_empleadoid <> 0 AND e.empleado_id IS NULL;
