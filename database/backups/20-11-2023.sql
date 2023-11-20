-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 20-11-2023 a las 18:55:09
-- Versión del servidor: 10.4.10-MariaDB
-- Versión de PHP: 7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `posgrado`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_deleteCargaHoraria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteCargaHoraria` (IN `p_cgh_id` INT, IN `p_cgc_id` INT, IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	
    
    UPDATE CARGA_HORARIA_CICLO
    SET
		cgc_estado = '0008',
        usuario_eliminacion = p_usuario,
        fechahora_eliminacion = now(),
        dispositivo_eliminacion = p_dispositivo
    WHERE cgc_id = p_cgc_id;
    
    SELECT 1 as respuesta, 'Se eliminó el registro correctamente.' as mensaje, p_cgh_id as cgh_id;
END$$

DROP PROCEDURE IF EXISTS `sp_GetAsignacionDocenteByPrograma`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAsignacionDocenteByPrograma` (IN `p_sem_id` INT, IN `p_sec_id` INT)  BEGIN  
	SELECT 
		CGD.cgd_id,
        CH.sem_codigo,
        CGC.cgh_ciclo as ciclo,
        CHC.cur_codigo,
        CHC.cur_descripcion,
        CASE WHEN CCG.ccg_grupo = 1
			THEN 'A'
            ELSE 'B' END as grupo,
        CGD.cgd_titular,
        CGD.doc_condicion,
        CGD.doc_id,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_email,
        MIN(date_format(CGF.cgf_fecha, '%d/%m/%Y')) as fecha_inicio,
        MAX(date_format(CGF.cgf_fecha, '%d/%m/%Y')) as fecha_fin
    FROM CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO CCG ON CCG.ccg_id = CGD.ccg_id
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_FECHA CGF ON CGF.ccg_id = CCG.ccg_id
    INNER JOIN CARGA_HORARIA_CURSO CHC ON CHC.chc_id = CCG.chc_id
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgc_id = CHC.cgc_id
    INNER JOIN CARGA_HORARIA CH ON CH.cgh_id = CGC.cgh_id
    WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id
		AND CH.cgh_estado = '0001' AND CGD.cgd_titular = 1
	GROUP BY CGD.cgd_id, CH.sem_codigo, CGC.cgh_ciclo, CHC.cur_codigo, CHC.cur_descripcion,
		CCG.ccg_grupo, CGD.cgd_titular, CGD.doc_condicion, CGD.doc_id, CGD.doc_codigo, 
        CGD.doc_documento, CGD.doc_nombres, CGD.doc_email;
END$$

DROP PROCEDURE IF EXISTS `sp_GetAsignacionDocenteByUnidad`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAsignacionDocenteByUnidad` (IN `p_sem_id` INT, IN `p_sec_id` INT)  BEGIN  
	SELECT 
        CH.sem_codigo,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_email
    FROM CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO CCG ON CCG.ccg_id = CGD.ccg_id
    INNER JOIN CARGA_HORARIA_CURSO CHC ON CHC.chc_id = CCG.chc_id
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgc_id = CHC.cgc_id
    INNER JOIN CARGA_HORARIA CH ON CH.cgh_id = CGC.cgh_id
    WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id
		AND CH.cgh_estado = '0001' AND CGD.cgd_titular = 1
        AND CGD.doc_documento <> '00000000' AND CGD.doc_documento <> '' AND CGD.doc_email <> "sn@unitru.edu.pe" AND CGD.doc_email <> ''
	GROUP BY CH.sem_codigo, CGD.doc_codigo, CGD.doc_documento, 
    CGD.doc_nombres, CGD.doc_email;
END$$

DROP PROCEDURE IF EXISTS `sp_GetCargaHoraria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCargaHoraria` (IN `p_sem_id` INT, IN `p_sec_id` INT)  BEGIN  
	
    SELECT
		CH.cgh_id,
        CH.cgh_codigo as codigoCH,
        CH.sem_id,
		CH.sem_codigo as codSemestre, 
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.prg_id,
        CH.prg_mencion as mencion,
        CGC.cgc_id,
        CGC.cgh_ciclo as ciclo,
        CHC.chc_id,
        CHC.cur_descripcion as curso,
        CHC.cur_tipo,
        TC.nombre as tipo_curso,
        CHC.cur_calidad,
        CC.nombre as calidad_curso,
        CHC.cur_creditos,
        CHC.chc_horas,
        CCG.ccg_id,
        CCG.ccg_grupo as grupo,
        CGD.cgd_id,
        CGD.cgd_titular as titular,
        CGD.doc_condicion,
        CD.condicion,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGF.cgf_id,
        CGF.cgf_fecha as fecha
    FROM CARGA_HORARIA CH
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
    INNER JOIN CARGA_HORARIA_CURSO CHC ON CHC.cgc_id = CGC.cgc_id
    INNER JOIN V_TIPO_CURSO TC ON TC.valor = CHC.cur_tipo
    INNER JOIN V_CALIDAD_CURSO CC ON CC.valor = CHC.cur_calidad
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO CCG ON CCG.chc_id = CHC.chc_id
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD ON CGD.ccg_id = CCG.ccg_id
    INNER JOIN V_CONDICION_DOCENTE CD ON CD.idCondicion = CGD.doc_condicion
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_FECHA CGF ON CGF.ccg_id = CCG.ccg_id
    WHERE CH.sem_id = p_sem_id 
		AND CH.sec_id = p_sec_id
        AND CH.cgh_estado = '0001'
	ORDER BY CH.sec_descripcion ASC, CH.prg_mencion ASC, CGC.cgh_ciclo ASC, CHC.cur_descripcion ASC,
		CCG.ccg_grupo ASC, CGD.cgd_titular DESC, CGF.cgf_id ASC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetCargaHorariaById`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCargaHorariaById` (IN `p_cgh_id` INT, IN `p_cgc_id` INT)  BEGIN  

	SELECT
		CH.cgh_id,
        CH.cgh_codigo,
        CH.sem_id,
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.prg_id,
        CH.prg_mencion as mencion,
        CH.cgh_estado,
        CGC.cgc_id,
        CGC.cgh_ciclo as ciclo,
        CGC.cgc_estado,
        CHC.chc_id,
        CHC.cur_id,
        CHC.cur_codigo,
        CHC.cur_descripcion as curso,
        CHC.cur_tipo,
        TC.nombre as tipo_curso,
        CHC.cur_calidad,
        CC.nombre as calidad_curso,
        CHC.cur_creditos,
        CHC.chc_horas,
        CHC.chc_estado,
        CCG.ccg_id,
        CCG.ccg_grupo as grupo,
        CCG.ccg_estado,
        CGD.cgd_id,
        CGD.cgd_titular as titular,
        CGD.doc_condicion,
        CD.condicion,
        CGD.doc_grado,
        CGD.doc_id,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_celular,
        CGD.doc_email,
        CGD.cgd_estado,
        CGF.cgf_id,
        CGF.cgf_fecha as fecha,
        CGF.cgf_estado
    FROM CARGA_HORARIA CH
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
    INNER JOIN CARGA_HORARIA_CURSO CHC ON CHC.cgc_id = CGC.cgc_id
    INNER JOIN V_TIPO_CURSO TC ON TC.valor = CHC.cur_tipo
    INNER JOIN V_CALIDAD_CURSO CC ON CC.valor = CHC.cur_calidad
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO CCG ON CCG.chc_id = CHC.chc_id
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD ON CGD.ccg_id = CCG.ccg_id
    INNER JOIN V_CONDICION_DOCENTE CD ON CD.idCondicion = CGD.doc_condicion
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_FECHA CGF ON CGF.ccg_id = CCG.ccg_id 
    WHERE CH.cgh_id = p_cgh_id
		AND CGC.cgc_id= p_cgc_id
        AND CH.cgh_estado = '0001' AND CGC.cgc_estado = '0001'
        AND CHC.chc_estado = '0001' AND CCG.ccg_estado = '0001'
        AND CGD.cgd_estado = '0001' AND CGF.cgf_estado = '0001'
	ORDER BY CH.sec_descripcion ASC, CH.prg_mencion ASC, CGC.cgh_ciclo ASC, CHC.cur_descripcion ASC,
		CCG.ccg_grupo ASC, CGD.cgd_titular DESC, CGF.cgf_id ASC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetCicloByCargaHoraria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCicloByCargaHoraria` (IN `p_cgh_id` INT)  BEGIN  
	
    SELECT
		CGC.cgc_id,
        CGC.cgh_id,
        CGC.cgh_ciclo as ciclo,
        CGC.cgc_estado as estado
    FROM CARGA_HORARIA_CICLO CGC
    WHERE CGC.cgh_id = p_cgh_id
		AND CGC.cgc_estado = '0001';
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetCursosByCiclo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCursosByCiclo` (IN `p_cgc_id` INT)  BEGIN  
	
    SELECT
		CHC.chc_id,
        CHC.cgc_id,
        CHC.cur_id,
		CHC.cur_codigo,
        CHC.cur_descripcion as curso,
        CHC.cur_ciclo,
        CHC.cur_creditos,
        CHC.cur_tipo,
        TP.nombre as tipo,
        CHC.cur_calidad,
        CC.nombre as calidad,
        CHC.chc_horas,
        CHC.chc_estado as estado
    FROM CARGA_HORARIA_CURSO CHC
    INNER JOIN V_TIPO_CURSO TP ON TP.valor = CHC.cur_tipo
    INNER JOIN V_CALIDAD_CURSO CC ON CC.valor = CHC.cur_calidad
    WHERE CHC.cgc_id = p_cgc_id
		AND CHC.chc_estado = '0001'
	ORDER BY CHC.cur_creditos DESC, CHC.cur_descripcion ASC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetDocentesByGrupo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDocentesByGrupo` (IN `p_ccg_id` INT)  BEGIN  
	
    SELECT
		CGD.cgd_id,
        CGD.ccg_id,
        CGD.cgd_titular,
        CGD.cgd_horas,
        CGD.cgd_fecha_inicio,
        CGD.cgd_fecha_fin,
        CGD.doc_condicion,
        CGD.doc_id,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_celular,
        CGD.doc_email,
        CGD.cgd_estado as estado
    FROM CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD
    WHERE CGD.ccg_id = p_ccg_id
		AND CGD.cgd_estado = '0001';
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetFechasByGrupo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetFechasByGrupo` (IN `p_ccg_id` INT)  BEGIN  
	
    SELECT
		CGF.cgf_id,
		CGF.ccg_id,
        CGF.cgf_fecha as fecha,
        CGF.cgf_estado as estado
    FROM CARGA_HORARIA_CURSO_GRUPO_FECHA CGF
    WHERE CGF.ccg_id = p_ccg_id
		AND CGF.cgf_estado = '0001';
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetGruposByCurso`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetGruposByCurso` (IN `p_chc_id` INT)  BEGIN  
	
    SELECT
		CCG.ccg_id,
        CCG.chc_id,
        CCG.sem_id,
		CCG.prg_id,
        CCG.ccg_grupo as grupo,
        CCG.ccg_estado as estado
    FROM CARGA_HORARIA_CURSO_GRUPO CCG
    WHERE CCG.chc_id = p_chc_id
		AND CCG.ccg_estado = '0001';
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetMisCargasHorarias`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMisCargasHorarias` (IN `p_sem_id` INT, IN `p_sec_id` INT, IN `p_prg_id` INT, IN `p_ciclo` INT, IN `p_usuario` INT)  BEGIN  

	SELECT 
		CH.cgh_id,
        CASE WHEN CH.cgh_codigo = '' OR CH.cgh_codigo IS NULL THEN
			'-' 
		ELSE CH.cgh_codigo END as codigo,
        CH.sem_id,
		CH.sem_codigo,
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.prg_id, 
        CH.prg_mencion as programa,
        CGC.cgc_id, 
        CGC.cgh_ciclo as ciclo,
        date_format(CH.fechahora, '%d/%m/%Y %h:%i %p') as creado,
        CASE WHEN CGC.fechahora_modificacion IS NULL THEN
			'SIN EDICIÓN'
		ELSE date_format(CGC.fechahora_modificacion, '%d/%m/%Y %h:%i %p') END as editado,
        CGC.cgc_estado as estado_id,
        ECH.nombre as estado,
        ECH.color,
        CGC.usuario,
        CGC.usuario_modificacion
    FROM CARGA_HORARIA CH
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
    INNER JOIN V_ESTADOS_CARGA_HORARIA ECH ON ECH.valor = CGC.cgc_estado
    WHERE (CH.sem_id = p_sem_id)
		AND (CH.sec_id = p_sec_id)
		AND (CH.prg_id = p_prg_id OR p_prg_id = '')
        AND (CGC.cgh_ciclo = p_ciclo OR p_ciclo = '')
        -- AND CH.usuario = p_usuario;
	ORDER BY CH.cgh_id DESC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetMisCargasHorariasBySem`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMisCargasHorariasBySem` (IN `p_sem_id` INT, IN `p_sec_id` INT, IN `p_usuario` INT, IN `p_unidades` JSON)  BEGIN  
	DECLARE i INT DEFAULT 0;
	DECLARE total_elementos INT;
	DECLARE unidad JSON;
    DECLARE unidad_id INT;

	SET total_elementos = JSON_LENGTH(p_unidades);
	
    DROP TEMPORARY TABLE IF EXISTS UNIDADES_TEMP;
	CREATE TEMPORARY TABLE UNIDADES_TEMP (sec_id INT);
    
    WHILE i < total_elementos DO
		SET unidad = JSON_UNQUOTE(JSON_EXTRACT(p_unidades, CONCAT('$[', i, ']')));
        SET unidad_id = JSON_UNQUOTE(JSON_EXTRACT(unidad, '$.unidad_id'));
		INSERT INTO UNIDADES_TEMP VALUES (unidad_id);
		SET i = i + 1;
	END WHILE;
    
    SELECT
		CASE WHEN CH.cgh_codigo = '' OR CH.cgh_codigo IS NULL THEN
			'-' 
		ELSE CH.cgh_codigo END as codigo,
        CH.sem_id,
		CH.sem_codigo,
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.cgh_estado as estado_id,
        ECH.nombre as estado,
        ECH.color
    FROM CARGA_HORARIA CH
    INNER JOIN V_ESTADOS_CARGA_HORARIA ECH ON ECH.valor = CH.cgh_estado
    INNER JOIN UNIDADES_TEMP UTE ON UTE.sec_id = CH.sec_id
    WHERE (CH.sem_id = p_sem_id OR p_sem_id = '')
		AND (CH.sec_id = p_sec_id OR p_sec_id = '')
	GROUP BY CH.cgh_codigo, CH.sem_id, CH.sem_codigo, CH.sem_descripcion, CH.sec_id, CH.sec_descripcion,
		CH.cgh_estado, ECH.nombre, ECH.color
	ORDER BY CH.fechahora DESC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_getReporteEnvios`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getReporteEnvios` (IN `p_sem_id` INT, IN `p_sec_id` INT)  BEGIN  
	Select 
    chec_doc_nombre as Nombre,
    chec_doc_correo as Correo,
    chec_envio as Envio,
    chec_envio_fecha as Fecha,
    chec_envio_error as Error_Envio
    from carga_horaria_envio_credenciales CHEC
    where CHEC.sem_id = p_sem_id AND CHEC.sec_id = p_sec_id;
END$$

DROP PROCEDURE IF EXISTS `sp_SaveCargaHoraria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveCargaHoraria` (IN `p_cgh_id` INT, IN `p_cgh_codigo` VARCHAR(10), IN `p_sem_id` INT, IN `p_sem_codigo` VARCHAR(12), IN `p_sem_descripcion` VARCHAR(100), IN `p_sec_id` INT, IN `p_sec_descripcion` VARCHAR(100), IN `p_prg_id` INT, IN `p_prg_mencion` VARCHAR(500), IN `p_cgc_id` INT, IN `p_cgc_ciclo` INT, IN `p_cgh_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	DECLARE cgh_id INT;
	DECLARE cgc_id INT;
	IF p_cgh_id IS NULL OR p_cgh_id = 0 THEN
		SET @cgh_id = (SELECT 
							CH.cgh_id 
						FROM CARGA_HORARIA CH
                        INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
                        WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id 
							AND CH.prg_id = p_prg_id AND CGC.cgh_ciclo = p_cgc_ciclo 
                            AND CGC.cgc_estado = '0001'
                        ORDER BY CH.cgh_id DESC 
                        LIMIT 1);
        IF @cgh_id IS NULL OR @cgh_id = 0 THEN
        
			SET @cgh_id = (SELECT CH.cgh_id FROM CARGA_HORARIA CH 
							WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id 
                            AND CH.prg_id = p_prg_id AND CH.cgh_estado = '0001'
							ORDER BY CH.cgh_id DESC 
							LIMIT 1);
			
            IF @cgh_id IS NULL OR @cgh_id = 0 THEN
				-- Insertar nuevo registro
				INSERT INTO CARGA_HORARIA (
					cgh_codigo, sem_id, sem_codigo, sem_descripcion,
					sec_id, sec_descripcion, prg_id, prg_mencion, 
					cgh_estado, usuario, fechahora, dispositivo 
				) VALUES (
					p_cgh_codigo, p_sem_id, p_sem_codigo, p_sem_descripcion,
					p_sec_id, p_sec_descripcion, p_prg_id, p_prg_mencion,
					p_cgh_estado, p_usuario, NOW(), p_dispositivo
				);
                
                SET @cgh_id = last_insert_id();
            END IF;
            
            INSERT INTO CARGA_HORARIA_CICLO(
				cgh_id, cgh_ciclo, cgc_estado, usuario,
                fechahora, dispositivo
            ) VALUES (
				@cgh_id, p_cgc_ciclo, '0001', p_usuario,
                NOW(), p_dispositivo
            );
            
            SET @cgc_id = last_insert_id();
			
			SELECT 1 as respuesta, 'Se registro correctamente.' as mensaje, @cgc_id as cgc_id;
        ELSE
			SELECT 0 as respuesta, 'Ya existe una carga horaria para esa mención y ciclo.' as mensaje, @cgh_id as cgh_id;
        END IF;
    END IF;
    
    IF p_cgh_id IS NOT NULL OR p_cgh_id <> 0 THEN
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA 
        SET
            cgh_codigo = p_cgh_codigo,
            sem_id = p_sem_id,
            sem_codigo = p_sem_codigo,
            sem_descripcion = p_sem_descripcion,
            sec_id = p_sec_id,
            sec_descripcion = p_sec_descripcion,
            prg_id = p_prg_id,
            prg_mencion = p_prg_mencion,
            cgh_estado = p_cgh_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE cgh_id = p_cgh_id;
        
        SELECT p_cgh_id, p_cgh_codigo, p_sem_id, p_sem_codigo, p_sem_descripcion, p_sec_id, p_sec_descripcion, p_prg_id, p_prg_mencion, p_cgh_estado,
            p_usuario, NOW(), p_dispositivo;
        
        UPDATE CARGA_HORARIA_CICLO 
        SET
			cgh_id = p_cgh_id,
            cgh_ciclo = p_cgc_ciclo,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
		WHERE cgc_id = p_cgc_id;
        
        -- SELECT 1 as respuesta, 'Se actualizaron los registros.' as mensaje, p_cgc_id as cgc_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_SaveCargaHorariaCurso`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveCargaHorariaCurso` (IN `p_chc_id` INT, IN `p_cgc_id` INT, IN `p_cur_id` INT, IN `p_cur_codigo` VARCHAR(20), IN `p_cur_descripcion` VARCHAR(200), IN `p_cur_tipo` VARCHAR(4), IN `p_cur_calidad` VARCHAR(4), IN `p_cur_ciclo` INT, IN `p_cur_creditos` INT, IN `p_chc_horas` DECIMAL(10,2), IN `p_chc_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	DECLARE chc_id INT;
    
	IF p_chc_id IS NULL OR p_chc_id = 0 THEN

		-- Insertar nuevo registro
        INSERT INTO CARGA_HORARIA_CURSO (
            cgc_id, cur_id, cur_codigo, cur_descripcion, cur_tipo, cur_calidad,
            cur_ciclo, cur_creditos, chc_horas, chc_estado, usuario, fechahora, dispositivo
        ) VALUES (
            p_cgc_id, p_cur_id, p_cur_codigo, p_cur_descripcion, p_cur_tipo, p_cur_calidad,
            p_cur_ciclo, p_cur_creditos, p_chc_horas, p_chc_estado, p_usuario, NOW(), p_dispositivo
        );
        
        SET @chc_id = last_insert_id();
        
        SELECT 1 as respuesta, 'Se registro correctamente el curso.' as mensaje, @chc_id as chc_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_SaveDocenteByGrupo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveDocenteByGrupo` (IN `p_cgd_id` INT, IN `p_ccg_id` INT, IN `p_cgd_titular` BIT, IN `p_cgd_horas` DECIMAL(10,2), IN `p_cgd_fecha_inicio` DATE, IN `p_cgd_fecha_fin` DATE, IN `p_doc_grado` VARCHAR(4), IN `p_doc_condicion` VARCHAR(25), IN `p_doc_id` INT, IN `p_doc_codigo` VARCHAR(10), IN `p_doc_documento` VARCHAR(15), IN `p_doc_nombres` VARCHAR(180), IN `p_doc_celular` VARCHAR(180), IN `p_doc_email` VARCHAR(180), IN `p_cgd_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN  
	DECLARE cgd_id INT;
	IF p_cgd_id IS NULL OR p_cgd_id = 0 THEN
        -- Insertar nuevo registro
        INSERT INTO CARGA_HORARIA_CURSO_GRUPO_DOCENTE (
            ccg_id, cgd_titular, cgd_horas, cgd_fecha_inicio, cgd_fecha_fin, doc_condicion, doc_grado,
            doc_id, doc_codigo, doc_documento, doc_nombres, doc_celular, doc_email, 
            cgd_estado, usuario, fechahora, dispositivo 
        ) VALUES (
            p_ccg_id, p_cgd_titular, p_cgd_horas, p_cgd_fecha_inicio, p_cgd_fecha_fin, p_doc_condicion, p_doc_grado,
            p_doc_id, p_doc_codigo, p_doc_documento, p_doc_nombres, p_doc_celular, p_doc_email, 
            p_cgd_estado, p_usuario, NOW(), p_dispositivo
        );
        
        SET @cgd_id = last_insert_id();
        
        SELECT 1 as respuesta, 'El docente se guardo exitosamente.' as mensaje, @cgd_id as cgd_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_SaveFechaByGrupo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveFechaByGrupo` (IN `p_cgf_id` INT, IN `p_ccg_id` INT, IN `p_cgf_fecha` DATE, IN `p_cgf_hora_inicio` INT, IN `p_cgf_hora_fin` INT, IN `p_cgf_horas` DECIMAL(10,2), IN `p_cgf_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN  
	DECLARE cgf_id INT;
	IF p_cgf_id IS NULL OR p_cgf_id = 0 THEN
        -- Insertar nuevo registro
        INSERT INTO CARGA_HORARIA_CURSO_GRUPO_FECHA (
            ccg_id, cgf_fecha, cgf_hora_inicio, cgf_hora_fin,
            cgf_horas, cgf_estado, usuario, fechahora, dispositivo
        ) VALUES (
            p_ccg_id, p_cgf_fecha, p_cgf_hora_inicio, p_cgf_hora_fin,
            p_cgf_horas, p_cgf_estado, p_usuario, NOW(), p_dispositivo
        );
        
        SET @cgf_id = last_insert_id();
        
        SELECT 1 as respuesta, 'Se registro la fecha correctamente.' as mensaje, @cgf_id as cgf_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_SaveGrupoByCurso`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveGrupoByCurso` (IN `p_ccg_id` INT, IN `p_chc_id` INT, IN `p_sem_id` INT, IN `p_prg_id` INT, IN `p_ccg_grupo` INT, IN `p_ccg_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN  
	DECLARE ccg_id INT;
	IF p_ccg_id IS NULL OR p_ccg_id = 0 THEN
        -- Insertar nuevo registro
        INSERT INTO CARGA_HORARIA_CURSO_GRUPO (
            chc_id, sem_id, prg_id, ccg_grupo, ccg_estado,
            usuario, fechahora, dispositivo
        ) VALUES (
            p_chc_id, p_sem_id, p_prg_id, p_ccg_grupo, p_ccg_estado,
            p_usuario, NOW(), p_dispositivo
        );
        
        SET @ccg_id = last_insert_id();
        
        SELECT 1 as respuesta, 'Se registro correctamente el grupo.' as mensaje, @ccg_id as ccg_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_UpdateCargaHoraria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateCargaHoraria` (IN `p_cgh_id` INT, IN `p_cgh_codigo` VARCHAR(10), IN `p_sem_id` INT, IN `p_sem_codigo` VARCHAR(12), IN `p_sem_descripcion` VARCHAR(100), IN `p_sec_id` INT, IN `p_sec_descripcion` VARCHAR(100), IN `p_prg_id` INT, IN `p_prg_mencion` VARCHAR(500), IN `p_cgc_id` INT, IN `p_cgc_ciclo` INT, IN `p_cgh_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	IF p_cgh_id IS NOT NULL OR p_cgh_id <> 0 THEN
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA 
        SET
            cgh_codigo = p_cgh_codigo,
            sem_id = p_sem_id,
            sem_codigo = p_sem_codigo,
            sem_descripcion = p_sem_descripcion,
            sec_id = p_sec_id,
            sec_descripcion = p_sec_descripcion,
            prg_id = p_prg_id,
            prg_mencion = p_prg_mencion,
            cgh_estado = p_cgh_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE cgh_id = p_cgh_id;
        
        UPDATE CARGA_HORARIA_CICLO 
        SET
			cgh_id = p_cgh_id,
            cgh_ciclo = p_cgc_ciclo,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
		WHERE cgc_id = p_cgc_id;
        
        SELECT 1 as respuesta, 'Se actualizaron los registros.' as mensaje, p_cgc_id as cgc_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_UpdateCargaHorariaCurso`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateCargaHorariaCurso` (IN `p_chc_id` INT, IN `p_cgc_id` INT, IN `p_cur_id` INT, IN `p_cur_codigo` VARCHAR(20), IN `p_cur_descripcion` VARCHAR(200), IN `p_cur_tipo` VARCHAR(4), IN `p_cur_calidad` VARCHAR(4), IN `p_cur_ciclo` INT, IN `p_cur_creditos` INT, IN `p_chc_horas` DECIMAL(10,2), IN `p_chc_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	IF p_chc_id IS NOT NULL OR p_chc_id <> 0 THEN
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA_CURSO SET
            cgc_id = p_cgc_id,
            cur_id = p_cur_id,
            cur_codigo = p_cur_codigo,
            cur_descripcion = p_cur_descripcion,
            cur_tipo = p_cur_tipo,
            cur_calidad = p_cur_calidad,
            cur_ciclo = p_cur_ciclo,
            cur_creditos = p_cur_creditos,
            chc_horas = p_chc_horas,
            chc_estado = p_chc_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE chc_id = p_chc_id;
        
        SELECT 1 as respuesta, 'Se actualizó correctamente el curso.' as mensaje, p_chc_id as chc_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_UpdateDocenteByGrupo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateDocenteByGrupo` (IN `p_cgd_id` INT, IN `p_ccg_id` INT, IN `p_cgd_titular` BIT, IN `p_cgd_horas` DECIMAL(10,2), IN `p_cgd_fecha_inicio` DATE, IN `p_cgd_fecha_fin` DATE, IN `p_doc_grado` VARCHAR(4), IN `p_doc_condicion` VARCHAR(25), IN `p_doc_id` INT, IN `p_doc_codigo` VARCHAR(10), IN `p_doc_documento` VARCHAR(15), IN `p_doc_nombres` VARCHAR(180), IN `p_doc_celular` VARCHAR(180), IN `p_doc_email` VARCHAR(180), IN `p_cgd_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	IF p_cgd_id IS NOT NULL OR p_cgd_id <> 0 THEN
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA_CURSO_GRUPO_DOCENTE SET
            ccg_id = p_ccg_id,
            cgd_titular = p_cgd_titular,
            cgd_horas = p_cgd_horas,
            cgd_fecha_inicio = p_cgd_fecha_inicio,
            cgd_fecha_fin = p_cgd_fecha_fin,
            doc_condicion = p_doc_condicion,
            doc_grado = p_doc_grado,
            doc_id = p_doc_id,
            doc_documento = p_doc_documento,
            doc_codigo = p_doc_codigo,
            doc_nombres = p_doc_nombres,
            doc_celular = p_doc_celular,
            doc_email = p_doc_email,
            cgd_estado = p_cgd_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE cgd_id = p_cgd_id;
        
        SELECT 1 as respuesta, 'Se actualizaron correctamente los datos del docente.' as mensaje, p_cgd_id as cgd_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_UpdateFechaByGrupo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateFechaByGrupo` (IN `p_cgf_id` INT, IN `p_ccg_id` INT, IN `p_cgf_fecha` DATE, IN `p_cgf_hora_inicio` INT, IN `p_cgf_hora_fin` INT, IN `p_cgf_horas` DECIMAL(10,2), IN `p_cgf_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	IF p_cgf_id IS NOT NULL OR p_cgf_id <> 0 THEN
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA_CURSO_GRUPO_FECHA SET
            ccg_id = p_ccg_id,
            cgf_fecha = p_cgf_fecha,
            cgf_hora_inicio = p_cgf_hora_inicio,
            cgf_hora_fin = p_cgf_hora_fin,
            cgf_horas = p_cgf_horas,
            cgf_estado = p_cgf_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE cgf_id = p_cgf_id;
        
        SELECT 1 as respuesta, 'Se actualizo el registro correctamente.' as mensaje, p_cgf_id as cgf_id;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_UpdateGrupoByCurso`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateGrupoByCurso` (IN `p_ccg_id` INT, IN `p_chc_id` INT, IN `p_sem_id` INT, IN `p_prg_id` INT, IN `p_ccg_grupo` INT, IN `p_ccg_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))  BEGIN
	IF p_ccg_id IS NOT NULL OR p_ccg_id <> 0 THEN
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA_CURSO_GRUPO SET
            chc_id = p_chc_id,
            sem_id = p_sem_id,
            prg_id = p_prg_id,
            ccg_grupo = p_ccg_grupo,
            ccg_estado = p_ccg_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE ccg_id = p_ccg_id;
        
        SELECT 1 as respuesta, 'Se actualizó correctamente el grupo.' as mensaje, p_ccg_id as ccg_id;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria`
--

DROP TABLE IF EXISTS `carga_horaria`;
CREATE TABLE IF NOT EXISTS `carga_horaria` (
  `cgh_id` int(11) NOT NULL AUTO_INCREMENT,
  `cgh_codigo` varchar(10) DEFAULT NULL,
  `sem_id` int(11) DEFAULT NULL,
  `sem_codigo` varchar(12) DEFAULT NULL,
  `sem_descripcion` varchar(100) DEFAULT NULL,
  `sec_id` int(11) DEFAULT NULL,
  `sec_descripcion` varchar(100) DEFAULT NULL,
  `prg_id` int(11) DEFAULT NULL,
  `prg_mencion` varchar(500) DEFAULT NULL,
  `cgh_estado` varchar(4) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgh_id`)
) ENGINE=MyISAM AUTO_INCREMENT=83 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria`
--

INSERT INTO `carga_horaria` (`cgh_id`, `cgh_codigo`, `sem_id`, `sem_codigo`, `sem_descripcion`, `sec_id`, `sec_descripcion`, `prg_id`, `prg_mencion`, `cgh_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, '', 69, 'SMTR58592023', '2023-I', 2, 'CIENCIAS ECONÓMICAS', 73, 'ADMINISTRACIÓN DE NEGOCIOS', '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, 1020, '2023-10-24 14:21:27', '10.0.100.42'),
(2, '', 69, 'SMTR58592023', '2023-I', 2, 'CIENCIAS ECONÓMICAS', 97, 'FINANZAS', '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(3, '', 70, 'SMTR52062023', '2023-II', 8, 'FARMACIA Y BIOQUÍMICA', 55, 'FARMACIA CLINÍCA', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(4, '', 70, 'SMTR52062023', '2023-II', 8, 'FARMACIA Y BIOQUÍMICA', 40, 'FARMACOLOGÍA', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(5, '', 70, 'SMTR52062023', '2023-II', 8, 'FARMACIA Y BIOQUÍMICA', 78, 'BIOQUÍMICA CLÍNICA', '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(6, '', 70, 'SMTR52062023', '2023-II', 8, 'FARMACIA Y BIOQUÍMICA', 71, 'PRODUCTOS NATURALES TERAPÉUTICOS', '0001', 1021, '2023-11-10 12:23:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(7, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 235, 'DOCTORADO EN FARMACIA Y BIOQUÍMICA', '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(8, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 85, 'ADMINISTRACIÓN Y DIRECCIÓN DE TECNOLOGÍAS DE LA INFORMACIÓN', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(9, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 179, 'DIRECCIÓN DE PROYECTOS', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(10, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 49, 'GERENCIA DE OPERACIONES', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(11, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 143, 'ORGANIZACIÓN Y DIRECCIÓN DE RECURSOS HUMANOS', '0001', 1021, '2023-11-13 09:45:21', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(12, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 223, 'GESTIÓN DE SEGURIDAD MINERA', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(13, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 114, 'GESTIÓN DE RIESGOS AMBIENTALES Y DE SEGURIDAD EN LAS EMPRESAS', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(14, '', 70, 'SMTR52062023', '2023-II', 9, 'INGENIERÍA', 195, 'SISTEMAS INTEGRADOS DE GESTIÓN DE LA CALIDAD, AMBIENTE, SEGURIDAD Y RESPONSABILIDAD SOCIAL CORPORATIVA', '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(15, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 148, 'DOCTORADO EN CIENCIAS E INGENIERÍA', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(16, '', 70, 'SMTR52062023', '2023-II', 1, 'CIENCIAS BIOLÓGICAS', 128, 'MICROBIOLOGÍA CLÍNICA', '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(17, '', 70, 'SMTR52062023', '2023-II', 1, 'CIENCIAS BIOLÓGICAS', 192, 'BIOTECNOLOGÍA AGROINDUSTRIAL Y AMBIENTAL', '0001', 1021, '2023-11-13 11:32:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(18, '', 70, 'SMTR52062023', '2023-II', 1, 'CIENCIAS BIOLÓGICAS', 58, 'GESTIÓN AMBIENTAL', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(19, '', 70, 'SMTR52062023', '2023-II', 1, 'CIENCIAS BIOLÓGICAS', 187, 'BIOTECNOLOGÍA Y FERMENTACIONES INDUSTRIALES', '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(20, '', 70, 'SMTR52062023', '2023-II', 1, 'CIENCIAS BIOLÓGICAS', 162, 'MICROBIOLOGÍA Y TECNOLOGÍA DE ALIMENTOS', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(21, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 196, 'DOCTORADO EN CIENCIAS AMBIENTALES', '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(22, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 202, 'DOCTORADO EN CIENCIAS BIOLÓGICAS', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(23, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 237, 'DOCTORADO EN MICROBIOLOGÍA', '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(24, '', 70, 'SMTR52062023', '2023-II', 10, 'ENFERMERÍA', 134, 'GERENCIA Y POLÍTICAS PÚBLICAS', '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(25, '', 70, 'SMTR52062023', '2023-II', 10, 'ENFERMERÍA', 248, 'MAESTRÍA EN CIENCIAS DE ENFERMERÍA', '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(26, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 213, 'DOCTORADO EN CIENCIAS DE ENFERMERÍA', '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(27, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 241, 'DOCTORADO EN CIENCIAS AGROPECUARIAS', '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(28, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 68, 'INGENIERÍA DE RECURSOS HÍDRICOS', '0001', 1021, '2023-11-13 12:23:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(29, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 89, 'AGROEXPORTACIÓN', '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(30, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 36, 'TECNOLOGÍA DE ALIMENTOS', '0001', 1021, '2023-11-13 12:29:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(31, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 57, 'MANEJO INTEGRADO DE PLAGAS Y ENFERMEDADES EN SISTEMAS AGROECOLÓGICOS', '0001', 1021, '2023-11-13 12:35:00', '10.0.100.98', NULL, NULL, NULL, 1021, '2023-11-13 12:37:05', '10.0.100.98'),
(32, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 57, 'MANEJO INTEGRADO DE PLAGAS Y ENFERMEDADES EN SISTEMAS AGROECOLÓGICOS', '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, 1021, '2023-11-13 12:48:16', '10.0.100.98'),
(33, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 57, 'MANEJO INTEGRADO DE PLAGAS Y ENFERMEDADES EN SISTEMAS AGROECOLÓGICOS', '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(34, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 27, 'PRODUCCIÓN Y SANIDAD ANIMAL', '0001', 1021, '2023-11-13 12:55:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(35, '', 70, 'SMTR52062023', '2023-II', 12, 'CIENCIAS AGROPECUARIAS', 79, 'NUTRICIÓN Y ALIMENTACIÓN ANIMAL', '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(36, '', 70, 'SMTR52062023', '2023-II', 5, 'CIENCIAS SOCIALES', 56, 'ADMINISTRACIÓN Y GESTIÓN DEL DESARROLLO HUMANO', '0001', 1021, '2023-11-13 12:59:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(37, '', 70, 'SMTR52062023', '2023-II', 5, 'CIENCIAS SOCIALES', 96, 'GESTIÓN DEL PATRIMONIO CULTURAL', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', 1021, '2023-11-13 13:44:52', '10.0.100.98', NULL, NULL, NULL),
(38, '', 70, 'SMTR52062023', '2023-II', 5, 'CIENCIAS SOCIALES', 108, 'GERENCIA SOCIAL Y RELACIONES COMUNITARIAS', '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(39, '', 70, 'SMTR52062023', '2023-II', 5, 'CIENCIAS SOCIALES', 136, 'FAMILIA Y REDES SOCIALES', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(40, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 15, 'DOCTORADO EN PLANIFICACIÓN Y GESTIÓN', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(41, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 219, 'DOCTORADO EN CIENCIAS DEL DESARROLLO SOCIAL', '0001', 1021, '2023-11-13 13:52:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(42, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 122, 'ESTOMATOLOGÍA', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(43, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 64, 'PLANIFICACIÓN Y GESTIÓN', '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(44, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 164, 'NUTRICIÓN HUMANA', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', 1020, '2023-11-14 13:02:43', '10.0.100.54', NULL, NULL, NULL),
(45, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 73, 'ADMINISTRACIÓN DE NEGOCIOS', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(46, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 112, 'EPIDEMIOLOGÍA', '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(47, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 150, 'AUDITORÍA', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(48, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 251, 'MAESTRÍA EN MEDICINA', '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(49, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 31, 'MEDICINA', '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(50, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 97, 'FINANZAS', '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(51, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 120, 'TRIBUTACIÓN', '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(52, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 106, 'GESTIÓN EMPRESARIAL', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(53, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 127, 'GESTIÓN PÚBLICA Y DESARROLLO LOCAL', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(54, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 217, 'DOCTORADO EN MEDICINA', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(55, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 184, 'DIRECCIÓN Y ORGANIZACIÓN DEL TALENTO HUMANO', '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(56, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 182, 'DOCTORADO EN SALUD PÚBLICA', '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(57, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 194, 'DIRECCIÓN DE MARKETING Y NEGOCIOS GLOBALES', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(58, '', 70, 'SMTR52062023', '2023-II', 2, 'CIENCIAS ECONÓMICAS', 201, 'MBA DIRECCIÓN BANCARIA Y MERCADO DE CAPITALES', '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(59, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 155, 'DOCTORADO EN ADMINISTRACIÓN', '0001', 1021, '2023-11-15 08:23:57', '10.0.100.26', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL),
(60, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 244, 'DOCTORADO EN GESTIÓN PÚBLICA', '0001', 1021, '2023-11-15 08:40:59', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(61, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 231, 'DOCTORADO EN CONTABILIDAD Y FINANZAS', '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(62, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 52, 'DOCTORADO EN ECONOMÍA Y DESARROLLO INDUSTRIAL', '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(63, '', 70, 'SMTR52062023', '2023-II', 11, 'INGENIERÍA QUÍMICA', 66, 'INGENIERÍA QUÍMICA AMBIENTAL', '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(64, '', 70, 'SMTR52062023', '2023-II', 11, 'INGENIERÍA QUÍMICA', 252, 'MAESTRÍA EN INGENIERÍA QUÍMICA AMBIENTAL', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(65, '', 70, 'SMTR52062023', '2023-II', 7, 'EDUCACIÓN Y CIENCIAS DE LA COMUNICACIÓN', 116, 'GESTIÓN EDUCATIVA Y DESARROLLO REGIONAL', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL),
(66, '', 70, 'SMTR52062023', '2023-II', 11, 'INGENIERÍA QUÍMICA', 172, 'INGENIERÍA DE PROCESOS INDUSTRIALES', '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(67, '', 70, 'SMTR52062023', '2023-II', 7, 'EDUCACIÓN Y CIENCIAS DE LA COMUNICACIÓN', 20, 'PEDAGOGÍA UNIVERSITARIA', '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(68, '', 70, 'SMTR52062023', '2023-II', 7, 'EDUCACIÓN Y CIENCIAS DE LA COMUNICACIÓN', 38, 'PSICOLOGÍA EDUCATIVA', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(69, '', 70, 'SMTR52062023', '2023-II', 7, 'EDUCACIÓN Y CIENCIAS DE LA COMUNICACIÓN', 144, 'EDUCACIÓN INFANTIL', '0001', 1021, '2023-11-15 10:00:40', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(70, '', 70, 'SMTR52062023', '2023-II', 11, 'INGENIERÍA QUÍMICA', 91, 'INGENIERÍA AMBIENTAL', '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(71, '', 70, 'SMTR52062023', '2023-II', 7, 'EDUCACIÓN Y CIENCIAS DE LA COMUNICACIÓN', 133, 'LINGÜÍSTICA Y COMUNICACIÓN', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(72, '', 70, 'SMTR52062023', '2023-II', 7, 'EDUCACIÓN Y CIENCIAS DE LA COMUNICACIÓN', 183, 'RELACIONES PÚBLICAS Y RESPONSABILIDAD SOCIAL', '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(73, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 245, 'DOCTORADO EN CIENCIAS DE LA EDUCACIÓN', '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(74, '', 70, 'SMTR52062023', '2023-II', 6, 'DERECHO Y CIENCIAS POLÍTICAS', 18, 'DERECHO CIVIL Y COMERCIAL', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(75, '', 70, 'SMTR52062023', '2023-II', 6, 'DERECHO Y CIENCIAS POLÍTICAS', 60, 'DERECHO CONSTITUCIONAL Y ADMINISTRATIVO', '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(76, '', 70, 'SMTR52062023', '2023-II', 6, 'DERECHO Y CIENCIAS POLÍTICAS', 35, 'DERECHO PENAL Y CIENCIAS CRIMINOLÓGICAS', '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(77, '', 70, 'SMTR52062023', '2023-II', 6, 'DERECHO Y CIENCIAS POLÍTICAS', 51, 'DERECHO DEL TRABAJO Y DE LA SEGURIDAD SOCIAL', '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(78, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 70, 'DOCTORADO EN DERECHO Y CIENCIAS POLÍTICAS', '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(79, '', 70, 'SMTR52062023', '2023-II', 3, 'CIENCIAS FISICAS Y MATEMÁTICAS', 160, 'ESTADÍSTICA APLICADA', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL),
(80, '', 70, 'SMTR52062023', '2023-II', 3, 'CIENCIAS FISICAS Y MATEMÁTICAS', 115, 'CIENCIAS FÍSICAS', '0001', 1021, '2023-11-17 10:06:38', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(81, '', 70, 'SMTR52062023', '2023-II', 3, 'CIENCIAS FISICAS Y MATEMÁTICAS', 246, 'INGENIERIA MATEMATICA', '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:29', '10.0.100.79', NULL, NULL, NULL),
(82, '', 70, 'SMTR52062023', '2023-II', 13, 'DOCTORADO', 227, 'DOCTORADO EN FÍSICA', '0001', 1021, '2023-11-17 10:51:06', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_ciclo`
--

DROP TABLE IF EXISTS `carga_horaria_ciclo`;
CREATE TABLE IF NOT EXISTS `carga_horaria_ciclo` (
  `cgc_id` int(11) NOT NULL AUTO_INCREMENT,
  `cgh_id` int(11) NOT NULL,
  `cgh_ciclo` int(11) DEFAULT NULL,
  `cgc_estado` varchar(4) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgc_id`),
  KEY `cgh_id` (`cgh_id`)
) ENGINE=MyISAM AUTO_INCREMENT=130 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_ciclo`
--

INSERT INTO `carga_horaria_ciclo` (`cgc_id`, `cgh_id`, `cgh_ciclo`, `cgc_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 1, '0008', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, 1020, '2023-10-24 14:21:27', '10.0.100.42'),
(2, 2, 2, '0008', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', 1020, '2023-11-15 14:07:42', '10.0.100.54'),
(3, 3, 2, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, 4, '0001', 1021, '2023-11-10 11:38:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 4, 2, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 4, 4, '0001', 1021, '2023-11-10 12:08:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 5, 2, '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 5, 4, '0001', 1021, '2023-11-10 12:23:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 6, 4, '0001', 1021, '2023-11-10 12:23:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 7, 2, '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 8, 2, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 8, 4, '0001', 1021, '2023-11-13 09:26:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 9, 2, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 9, 4, '0001', 1021, '2023-11-13 09:32:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 10, 2, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 10, 4, '0001', 1021, '2023-11-13 09:44:07', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 11, 4, '0001', 1021, '2023-11-13 09:45:21', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 12, 2, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 12, 4, '0001', 1021, '2023-11-13 10:29:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 13, 2, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 13, 4, '0001', 1021, '2023-11-13 10:36:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 14, 2, '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(23, 14, 4, '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 15, 2, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 15, 4, '0001', 1021, '2023-11-13 11:22:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 16, 2, '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 16, 4, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 17, 2, '0001', 1021, '2023-11-13 11:32:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 17, 4, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 18, 2, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 18, 4, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 19, 4, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 20, 2, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 21, 4, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 22, 2, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 23, 4, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 24, 2, '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(38, 24, 4, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 25, 2, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 25, 4, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 26, 2, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(42, 26, 4, '0001', 1021, '2023-11-13 12:14:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(43, 27, 4, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 28, 2, '0001', 1021, '2023-11-13 12:23:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(45, 28, 4, '0001', 1021, '2023-11-13 12:25:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 29, 4, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 30, 4, '0001', 1021, '2023-11-13 12:29:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(48, 31, 2, '0008', 1021, '2023-11-13 12:35:00', '10.0.100.98', NULL, NULL, NULL, 1021, '2023-11-13 12:37:05', '10.0.100.98'),
(49, 32, 2, '0008', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, 1021, '2023-11-13 12:48:16', '10.0.100.98'),
(50, 33, 2, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 33, 4, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 34, 4, '0001', 1021, '2023-11-13 12:55:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 35, 4, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 36, 4, '0001', 1021, '2023-11-13 12:59:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(55, 37, 2, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 37, 4, '0001', 1021, '2023-11-13 13:04:52', '10.0.100.98', 1021, '2023-11-13 13:44:52', '10.0.100.98', NULL, NULL, NULL),
(57, 38, 2, '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 38, 4, '0001', 1021, '2023-11-13 13:10:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 39, 2, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 39, 4, '0001', 1021, '2023-11-13 13:38:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 40, 2, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 40, 4, '0001', 1021, '2023-11-13 13:51:49', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 41, 4, '0001', 1021, '2023-11-13 13:52:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(64, 42, 2, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(65, 42, 4, '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(66, 43, 2, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 43, 4, '0001', 1020, '2023-11-14 12:52:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 44, 2, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 44, 4, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:43', '10.0.100.54', NULL, NULL, NULL),
(70, 45, 2, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(71, 45, 4, '0001', 1021, '2023-11-14 13:06:30', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 46, 2, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(73, 46, 4, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(74, 47, 2, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 48, 2, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 49, 4, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 50, 2, '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 51, 2, '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 47, 4, '0001', 1021, '2023-11-14 13:40:16', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 52, 2, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 52, 4, '0001', 1021, '2023-11-14 13:44:47', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 53, 2, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 53, 4, '0001', 1021, '2023-11-14 13:51:20', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 54, 2, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(85, 54, 4, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 55, 2, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 56, 2, '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 57, 2, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 57, 4, '0001', 1021, '2023-11-15 08:18:30', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 58, 2, '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 59, 2, '0001', 1021, '2023-11-15 08:23:57', '10.0.100.26', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL),
(92, 56, 4, '0001', 1020, '2023-11-15 08:31:03', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(93, 60, 2, '0001', 1021, '2023-11-15 08:40:59', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 60, 4, '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 60, 6, '0001', 1021, '2023-11-15 08:44:32', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 61, 2, '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 61, 6, '0001', 1021, '2023-11-15 08:51:04', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 62, 4, '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 63, 4, '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 64, 2, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 65, 2, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(102, 66, 4, '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(103, 65, 4, '0001', 1021, '2023-11-15 09:15:10', '10.0.100.79', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL),
(104, 67, 2, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(105, 67, 4, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 68, 2, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 68, 4, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 69, 2, '0001', 1021, '2023-11-15 10:00:40', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(109, 70, 4, '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 71, 2, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 71, 4, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 72, 2, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(113, 72, 4, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 73, 2, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(115, 73, 4, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(116, 74, 2, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(117, 74, 4, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(118, 75, 2, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(119, 75, 4, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(120, 76, 2, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(121, 76, 4, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(122, 77, 2, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 77, 4, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(124, 78, 2, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(125, 79, 2, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(126, 79, 4, '0001', 1021, '2023-11-17 10:02:22', '10.0.100.79', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL),
(127, 80, 2, '0001', 1021, '2023-11-17 10:06:38', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(128, 81, 2, '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:29', '10.0.100.79', NULL, NULL, NULL),
(129, 82, 4, '0001', 1021, '2023-11-17 10:51:06', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso`
--

DROP TABLE IF EXISTS `carga_horaria_curso`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso` (
  `chc_id` int(11) NOT NULL AUTO_INCREMENT,
  `cgc_id` int(11) NOT NULL,
  `cur_id` int(11) DEFAULT NULL,
  `cur_codigo` varchar(20) DEFAULT NULL,
  `cur_descripcion` varchar(500) DEFAULT NULL,
  `cur_tipo` varchar(4) DEFAULT NULL,
  `cur_calidad` varchar(4) DEFAULT NULL,
  `cur_ciclo` int(11) DEFAULT NULL,
  `cur_creditos` int(11) DEFAULT NULL,
  `chc_horas` decimal(10,2) DEFAULT NULL,
  `chc_estado` varchar(4) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chc_id`),
  KEY `cgc_id` (`cgc_id`)
) ENGINE=MyISAM AUTO_INCREMENT=259 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_curso`
--

INSERT INTO `carga_horaria_curso` (`chc_id`, `cgc_id`, `cur_id`, `cur_codigo`, `cur_descripcion`, `cur_tipo`, `cur_calidad`, `cur_ciclo`, `cur_creditos`, `chc_horas`, `chc_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 1531, 'P99IS501A', 'ACREDITACIÓN Y LEGISLACIÓN', '0002', '0002', 1, 4, '12.00', '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, 1572, 'P14IS510A', 'ACREDITACIÓN Y LEGISLACIÓN AMBIENTAL', '0001', '0001', 2, 3, '48.00', '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(3, 3, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, 4041, 'P13FC402A', 'BASES QUÍMICAS DE LAS REACCIONES ADVERSAS E INTERACCIONES DE MEDICAMENTOS', '0001', '0002', 2, 3, '64.00', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 3, 154, 'P37BM509C', 'NUTRICIÓN ARTIFICIAL', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 4, 8276, 'FCFARMC', 'FARMACOTERAPEUTICA AVANZADA', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-10 11:38:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 5, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 5, 4027, 'P13FC412A', 'FARMACOCINÉTICA GENERAL', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 5, 3394, 'P61FL505C', 'FARMACOLOGÍA EXPERIMENTAL', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 6, 8276, 'FCFARMC', 'FARMACOTERAPEUTICA AVANZADA', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-10 12:08:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 7, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 7, 1259, 'P37QB526A', 'ENZIMOLOGÍA CLÍNICA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 8, 8279, 'FB0323', 'NEUROQUIMICA', '0002', '0001', 4, 4, '48.00', '0001', 1021, '2023-11-10 12:23:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 9, 8276, 'FCFARMC', 'FARMACOTERAPEUTICA AVANZADA', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-10 12:23:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 10, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 10, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '144.00', '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 11, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 11, 326, 'P83IS546A', 'SISTEMAS DE INFORMACIÓN Y ORGANIZACIÓN', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 11, 3924, 'P92GI112B', 'COMERCIO ELECTRÓNICO Y REDES DE NEGOCIOS', '0001', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 12, 1713, 'P83SI504A', 'SEGURIDAD Y AUDITORÍA DE SISTEMAS', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 09:26:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 13, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 13, 1534, 'P81ID100A', 'GERENCIA DE PROYECTOS II', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(23, 13, 3352, 'P81ID104C', 'EVALUACIÓN Y ANÁLISIS DE RIESGOS', '0001', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 14, 2065, 'P44IS549A', 'LOGÍSTICA EMPRESARIAL', '0002', '0001', 3, 3, '64.00', '0001', 1021, '2023-11-13 09:32:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 15, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 15, 3630, 'P44IS544A', 'GESTIÓN TÁCTICA DE LAS OPERACIONES', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 15, 2065, 'P44IS549A', 'LOGÍSTICA EMPRESARIAL', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 15, 2139, 'P44IS526A', 'EVALUACIÓN Y GESTIÓN ECONÓMICA Y FINANCIERA DE PROYECTOS', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 16, 1816, 'P60MP671D', 'EVALUACIÓN Y GESTIÓN ECONÓMICA Y FINANCIERA DE PROYECTOS', '0001', '0002', 3, 4, '64.00', '0001', 1021, '2023-11-13 09:44:07', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 17, 8290, 'IGRH0123', 'GESTION ESTRATEGICA EMPRESARIAL', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-13 09:45:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 18, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 18, 127, 'P165M202A', 'GERENCIA DE SEGURIDAD Y SALUD OCUPACIONAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 18, 4169, 'P93IS506A', 'PREVENCIÓN DE RADIACIONES, INCENDIOS Y EXPLOSIONES', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 19, 3819, 'P165M401A', 'IMPLANTACIÓN DE SISTEMAS DE GESTIÓN DE SEGURIDAD Y SALUD OCUPACIONAL', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 10:29:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 20, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 20, 3923, 'P93IS508A', 'ERGONOMÍA Y OPTIMIZACIÓN DEL TRABAJO', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 20, 3780, 'P93IS537A', 'EVALUACIÓN DEL IMPACTO AMBIENTAL Y LA ADMINISTRACIÓN DE PROYECTO', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(38, 21, 3922, 'P93IS507A', 'SISTEMAS INTEGRADOS DE GESTIÓN', '0002', '0002', 3, 4, '64.00', '0001', 1021, '2023-11-13 10:36:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 22, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(40, 22, 180, 'P01GP105A', 'EVALUACION DEL IMPACTO AMBIENTAL', '0002', '0001', 1, 3, '48.00', '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 22, 3718, 'P13SI402A', 'IMPLANTACIÓN DE SISTEMAS DE GESTIÓN DE CALIDAD ', '0002', '0001', 1, 3, '48.00', '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(42, 22, 1207, 'P93IS601A', 'AUDITORIA DE SISTEMAS INTEGRADOS DE GESTIÓN', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(43, 23, 2057, 'P80CS108A', 'HERRAMIENTAS PARA LA MEJORA CONTINUA', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 24, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(45, 24, 3155, 'P76DO557A', 'LEAN SIX SIGMA', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 24, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '112.00', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 25, 2002, 'P76DO551A', 'SISTEMAS INTEGRADOS DE GESTIÓN', '0002', '0001', 1, 3, '48.00', '0001', 1021, '2023-11-13 11:22:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(48, 26, 1975, 'P39MP548A', 'VIROLOGÍA E INMUNOLOGÍA APLICADA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(49, 26, 3527, 'P74DO521A', 'BIOLOGÍA MOLECULAR', '0002', '0001', 1, 3, '48.00', '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 26, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 27, 3150, 'P39MP577A', 'MICOLOGÍA CLÍNICA', '0001', '0001', 3, 4, '64.00', '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 28, 2313, 'P97BA504A', 'BIORREMEDIACIÓN AMBIENTAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:32:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 28, 3789, 'P97BA522A', 'MÉTODOS DE EVALUACIÓN DE FLORA Y FAUNA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 28, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(55, 29, 4052, 'P97BA506A', 'BIORREACTORES PARA RESIDUOS Y DESECHOS AGROINDUSTRIALES', '0002', '0001', 2, 4, '48.00', '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 30, 1058, 'P20IS554A', 'ORGANIZACIÓN Y GESTIÓN AMBIENTAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(57, 30, 4035, 'P20JP501A', 'LEGISLACIÓN AMBIENTAL', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 30, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 31, 1320, 'P20CB616A', 'SEGURIDAD AMBIENTAL Y LABORAL', '0002', '0001', 4, 4, '48.00', '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 32, 8291, 'CBBF0213', 'OPERACIONES UNITARIAS DE BIOPROCESOS', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 33, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 33, 2697, 'P60MP532C', 'MICROBIOLOGÍA ALIMENTARIA', '0002', '0002', 3, 3, '48.00', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 33, 8293, 'CBGC0123', 'GESTION DE CALIDAD EN LA INDUSTRIA ALIMENTARIA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(64, 34, 3627, 'P63DO563B', 'EVALUACIÓN DE PROYECTOS', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 35, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 35, 3892, 'P74DO527C', 'BIOTECNOLOGÍA Y RECURSOS POTENCIALES', '0002', '0001', 5, 3, '48.00', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 35, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 36, 3660, 'P88DO578B', 'INMUNOLOGÍA Y VIROLOGÍA APLICADAS', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 37, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 37, 2234, 'P87SP582A', 'POBREZA, POLÍTICAS SOCIALES, SALUD Y ENFERMERÍA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 38, 6240, 'OP00222', 'SALUD FAMILIAR Y PROGRAMAS SOCIALES', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 39, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 39, 4044, 'P82CE530A', 'VIOLENCIA, SALUD Y ENFERMERÍA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(74, 39, 1018, 'P82SF518A', 'SALUD FAMILIAR', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 40, 1415, 'P82CE560A', 'CONCEPCIONES TEÓRICA-FILOSÓFICAS DE ENFERMERÍA', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 41, 3461, 'P71DO548A', 'ENFERMERÍA EN EL CONTEXTO SOCIOPOLÍTICO, ECONÓMICO Y GLOBALIZACIÓN', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 41, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 41, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 42, 120, 'P71DO574A', 'HISTORIA DE ENFERMERÍA', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-13 12:14:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 43, 6253, 'P90DO622A', 'MANEJO DE CUENCAS HIDROGRÁFICAS', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 44, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 12:23:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 44, 2626, 'P79IQ553B', 'HIDRÁULICAS FLUVIALES', '0002', '0001', 1, 3, '48.00', '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 44, 3833, 'P79IQ548B', 'HIDROLOGÍA ESTOCÁSTICA Y ESTADÍSTICA SUPERFICIAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 45, 6260, 'P00062022', 'REDES DE ABASTECIMIENTO Y DRENAJE, OPERACIÓN MANTENIMIENTO Y MONITOREO', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 12:25:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(85, 46, 1778, 'P89IS588A', 'PROCEDIMIENTOS BANCARIOS', '0002', '0001', 2, 4, '64.00', '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 47, 4097, 'P94IS508A', 'TECNOLOGÍA DE ALIMENTOS AVANZADA', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 12:29:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 48, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 12:35:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 49, 2682, 'P00AG501B', 'MANEJO INTEGRADO DE PLAGAS II', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 50, 2682, 'P00AG501B', 'MANEJO INTEGRADO DE PLAGAS II', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 50, 727, 'P00AG504A', 'MANEJO INTEGRADO DE MALEZAS', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 51, 1010, 'P00AG527A', 'MANEJO DE AGRICULTURA SOSTENIBLE', '0001', '0001', 4, 4, '48.00', '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 52, 3362, 'P01SA400A', 'PATOLOGÍA AVIAR', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 12:55:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 53, 109, 'P13NA104A', 'ECONOMÍA PECUARIA Y PLANEAMIENTO ESTRATÉGICO', '0001', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 54, 6238, 'P95AA522A', 'POLITICAS DEL DESARROLLO HUMANO', '0002', '0001', 4, 4, '48.00', '0001', 1021, '2023-11-13 12:59:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 55, 3812, 'P98AA566A', 'GLOBALIZACIÓN, CULTURA Y DESARROLLO', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 55, 1279, 'P96AA562A', 'PATRIMONIO CULTURAL INMATERIAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 55, 3380, 'P96AA580A', 'MUSEOLOGÍA Y CONSERVACIÓN', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 56, 2511, 'P96AA566A', 'MARKETING CULTURAL', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-13 13:04:52', '10.0.100.98', 1021, '2023-11-13 13:44:52', '10.0.100.98', NULL, NULL, NULL),
(99, 57, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 57, 2586, 'P95AA576A', 'GESTIÓN CULTURAL Y NEGOCIACIÓN DE CONFLICTOS SOCIOAMBIENTALES', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 57, 358, 'P95AA578A', 'POLÍTICAS SOCIALES, INVERSIÓN SOCIAL Y PARTICIPACIÓN COMUNITARIA EN EL PERÚ', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 58, 1709, 'P95AA582A', 'INTERCULTURALIDAD Y COMUNICACIÓN INTERPERSONAL', '0001', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-13 13:10:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(103, 59, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 59, 390, 'P95TS302A', 'PERSPECTIVA SISTÉMICA Y REDES SOCIALES EN EL TRABAJO SOCIAL', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 59, 1271, 'P95TS318A', 'INTERVENCIÓN FAMILIAR CON INFANCIA Y ADOLESCENCIA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 60, 3498, 'P35TS315A', 'REDES SOCIALES E INTERVENCIÓN FAMILIAR', '0001', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 13:38:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 61, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 61, 2924, 'P62DO575B', 'CALIDAD TOTAL Y PRODUCTIVIDAD', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 61, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 62, 1972, 'P86DO511A', 'SISTEMAS DE INFORMACIÓN GERENCIAL', '0002', '0001', 1, 3, '48.00', '0001', 1021, '2023-11-13 13:51:49', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 63, 8285, 'DCS0123', 'NACIONALIDADES E IDENTIDADES CULTURALES', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-13 13:52:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 64, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(113, 64, 2118, 'P01SA102A', 'EPIDEMIOLOGÍA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(114, 64, 4129, 'P66OD502B', 'AVANCES EN ESTOMATOLOGÍA I', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(115, 65, 3064, 'P66OD504A', 'AVANCES EN ESTOMATOLOGÍA III', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(116, 66, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(117, 66, 3440, 'P34MD502A', 'GERENCIA EN SALUD', '0002', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(118, 66, 1297, 'P33MS517C', 'POLÍTICAS SOCIALES Y LEGISLACIÓN EN SALUD', '0001', '0001', 3, 3, '48.00', '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(119, 67, 3492, 'P65MS516A', 'PLANIFICACIÓN ESTRATÉGICA EN SALUD', '0002', '0002', 2, 4, '64.00', '0001', 1020, '2023-11-14 12:52:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(120, 68, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(121, 68, 2863, 'P42BM505A', 'BIOQUÍMICA DE LA NUTRICIÓN', '0001', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(122, 68, 307, 'P42MD505A', 'PATOLOGÍA NUTRICIONAL', '0002', '0002', 3, 3, '48.00', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 69, 6237, 'P42ND122A', 'NUTRICIÓN CLÍNICA ALTERNATIVA Y COMPLEMENTARIA', '0001', '0001', 4, 4, '64.00', '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:43', '10.0.100.54', NULL, NULL, NULL),
(124, 70, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(125, 70, 1865, 'P30AD522A', 'FINANZAS CORPORATIVAS', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(126, 70, 4122, 'P30AD541B', 'ADMINISTRACIÓN DE PROYECTOS DE INVERSIÓN', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(127, 71, 3138, 'P12AD528A', 'GERENCIA AVANZADA', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-14 13:06:30', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(128, 72, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0002', '0002', 2, 4, '64.00', '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(129, 72, 3539, 'P65MS518A', 'EPIDEMIOLOGÍA APLICADA AVANZADA', '0002', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(130, 72, 1165, 'P65MS525B', 'ENFERMEDADES INFECCIOSAS Y NO INFECCIOSAS', '0001', '0001', 2, 3, '48.00', '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(131, 73, 3888, 'P65MS524A', 'EPIDEMIOLOGÍA DE CAMPO', '0002', '0002', 4, 4, '64.00', '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(132, 74, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(133, 74, 1209, 'P92CA102A', 'AUDITORÍA TRIBUTARIA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(134, 74, 618, 'P92CA110A', 'AUDITORÍA DE GESTIÓN DE RIESGOS', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(135, 75, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(136, 75, 2888, 'P15MD513A', 'GERENCIA MÉDICA', '0001', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 75, 3933, 'P75DO545A', 'BIOÉTICA', '0002', '0001', 2, 3, '48.00', '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(138, 76, 2257, 'P15FH542A', 'MEDICINA MOLECULAR Y TECNOLOGÍAS APLICADAS EN MEDICINA', '0001', '0002', 4, 4, '64.00', '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(139, 77, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(140, 77, 1926, 'P17AD529A', 'FINANZAS CORPORATIVAS', '0001', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(141, 78, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(142, 78, 1238, 'P45CO506A', 'TRIBUTACIÓN DIRECTA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(143, 79, 3839, 'P45CO515D', 'LEGISLACIÓN ADUANERA', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-14 13:40:16', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(144, 80, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(145, 80, 3703, 'P30AD524B', 'COSTOS Y PRESUPUESTOS', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(146, 80, 4122, 'P30AD541B', 'ADMINISTRACIÓN DE PROYECTOS DE INVERSIÓN', '0002', '0001', 3, 3, '48.00', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(147, 81, 3138, 'P12AD528A', 'GERENCIA AVANZADA', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-14 13:44:47', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(148, 82, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(149, 82, 1809, 'P80EC526A', 'ECONOMÍA URBANA-RURAL Y REGIONAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(150, 82, 1113, 'P80EC545G', 'GESTIÓN PÚBLICA MODERNA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(151, 83, 878, 'P80EC570A', 'DESARROLLO INTEGRAL LOCAL', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-14 13:51:20', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(152, 84, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0002', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(153, 84, 3745, 'P80DO514A', 'ENSEÑANZA EN MEDICINA CLÍNICA', '0001', '0001', 2, 3, '48.00', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(154, 84, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0002', '0002', 2, 9, '150.00', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(155, 85, 3597, 'P80DO518A', 'MEDICINA Y RESPONSABILIDAD SOCIAL', '0002', '0001', 4, 3, '48.00', '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 85, 3954, 'P84DO840A', 'INVESTIGACIÓN IV', '0004', '0002', 4, 12, '150.00', '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(157, 86, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 86, 3813, 'P94TH101D', 'GESTIÓN ESTRATÉGICA DE RECURSOS HUMANOS', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(159, 87, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0001', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(160, 87, 6257, 'P72DO522B', 'ADMINISTRACIÓN Y GERENCIA DE LA SALUD ', '0002', '0001', 2, 3, '48.00', '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(161, 87, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '128.00', '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(162, 88, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(163, 88, 1270, 'P95DM101D', 'GESTIÓN COMERCIAL Y VENTAS', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(164, 88, 3276, 'P95DM107A', 'SOCIAL MEDIA MARKETING', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(165, 89, 8294, 'ADPMO', 'PLAN DE MARKETING ONLINE', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-15 08:18:30', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(166, 90, 2804, 'P01CE434A', 'ECONOMÍA, MERCADO Y SOCIEDAD', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(167, 90, 2729, 'P95DB101D', 'ANÁLISIS Y GESTIÓN DEL RIESGO FINANCIERO', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(168, 91, 2916, 'P77DO549A', 'GESTIÓN DE MICRO, PEQUEÑAS Y MEDIANAS EMPRESAS', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 08:23:57', '10.0.100.26', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL),
(169, 92, 1973, 'P72DO562A', 'LA ATENCIÓN PRIMARIA DE SALUD: EVOLUCIÓN Y TENDENCIAS', '0001', '0001', 4, 3, '48.00', '0001', 1020, '2023-11-15 08:31:03', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(170, 91, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(171, 93, 2678, 'P93DO513B', 'SISTEMA NACIONAL DE RECURSOS HUMANOS EN EL SECTOR PÚBLICO', '0002', '0001', 5, 3, '48.00', '0001', 1021, '2023-11-15 08:40:59', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(172, 93, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '64.00', '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(173, 94, 2678, 'P93DO513B', 'SISTEMA NACIONAL DE RECURSOS HUMANOS EN EL SECTOR PÚBLICO', '0002', '0001', 5, 3, '64.00', '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(174, 94, 3954, 'P84DO840A', 'INVESTIGACIÓN IV', '0004', '0002', 4, 12, '128.00', '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(175, 95, 4165, 'P72DO860A', 'INVESTIGACIÓN VI', '0004', '0002', 6, 15, '128.00', '0001', 1021, '2023-11-15 08:44:32', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(176, 96, 1865, 'P30AD522A', 'FINANZAS CORPORATIVAS', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(177, 96, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0004', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(178, 97, 3954, 'P84DO840A', 'INVESTIGACIÓN IV', '0004', '0002', 4, 12, '128.00', '0001', 1021, '2023-11-15 08:51:04', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(179, 92, 3954, 'P84DO840A', 'INVESTIGACIÓN IV', '0004', '0002', 4, 12, '128.00', '0001', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(180, 98, 1865, 'P30AD522A', 'FINANZAS CORPORATIVAS', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(181, 98, 3954, 'P84DO840A', 'INVESTIGACIÓN IV', '0004', '0002', 4, 12, '48.00', '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(182, 99, 3715, 'P48IQ510A', 'PROCESOS DE SEPARACIÓN', '0002', '0002', 4, 4, '64.00', '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(183, 99, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '256.00', '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(184, 100, 692, 'P01GP100A', 'CIENCIA Y DESARROLLO SUSTENTABLE', '0001', '0002', 2, 4, '64.00', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(185, 100, 6228, 'P42ND167A', 'TRATAMIENTO DE RESIDUOS SÓLIDOS Y TÉCNICA DE TRATAMIENTO DE GASES', '0001', '0002', 2, 3, '48.00', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(186, 100, 3897, 'P48IQ508B', 'OPTIMIZACIÓN DE PROCESOS', '0001', '0001', 2, 3, '48.00', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(187, 100, 295, 'P01SA670A', 'TESIS I', '0004', '0002', 2, 5, '160.00', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(188, 101, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(189, 101, 1908, 'P52CP514C', 'EVALUACIÓN DE SISTEMAS EDUCATIVOS', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(190, 101, 295, 'P01SA670A', 'TESIS I', '0002', '0002', 2, 5, '128.00', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL),
(191, 102, 1623, 'P44IS582A', 'SISTEMAS INTEGRADOS DE GESTIÓN: PRODUCTIVIDAD, CALIDAD TOTAL, SEGURIDAD Y MEDIO AMBIENTE', '0002', '0001', 4, 4, '64.00', '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(192, 102, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '352.00', '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(193, 101, 2144, 'P52CP549B', 'POLÍTICAS Y GESTIÓN PÚBLICA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(194, 103, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '128.00', '0001', 1021, '2023-11-15 09:15:10', '10.0.100.79', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL),
(195, 103, 8282, 'CE0123', 'EDUCACION Y DESARROLLO HUMANO', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(196, 104, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(197, 104, 4016, 'P07CE544A', 'CURRÍCULO II', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(198, 104, 2799, 'P07CP550B', 'TEORÍAS DEL APRENDIZAJE Y LA CREATIVIDAD', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(199, 104, 295, 'P01SA670A', 'TESIS I', '0002', '0002', 2, 5, '128.00', '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(200, 105, 8283, 'CE0223', 'PLANIFICACION UNIVERSITARIA Y DESARROLLO NACIONAL', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(201, 105, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '128.00', '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(202, 106, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(203, 106, 2681, 'P08CP507B', 'PSICOLOGÍA EVOLUTIVA Y PEDAGÓGICA DEL ADULTO Y DE LA TERCERA EDAD', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(204, 106, 103, 'P07CP536A', 'PSICOMETRÍA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(205, 106, 295, 'P01SA670A', 'TESIS I', '0004', '0002', 2, 5, '128.00', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(206, 107, 179, 'P08CP504A', 'ESTUDIOS DE CASOS PSICOPEDAGÓGICOS', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(207, 108, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(208, 108, 1897, 'P98EI504A', 'NEUROBIOLOGÍA II', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(209, 108, 1416, 'P98EI506A', 'DESARROLLO AFECTIVO-EMOCIONAL INFANTIL', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(210, 109, 3874, 'P84CB550A', 'TÓPICOS AVANZADOS EN INGENIERÍA AMBIENTAL', '0002', '0002', 4, 4, '64.00', '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(211, 109, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '352.00', '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(212, 110, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(213, 110, 2984, 'P53IL551A', 'SEMINARIO DE ANÁLISIS LINGUÍSTICO', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(214, 110, 6248, 'P0022020', 'INTERNET Y NUEVO ORDEN TECNOLÓGICO CONTEMPORANEO', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(215, 111, 8284, 'CE0323', 'SEMINARIO DE TEMAS ACTUALES DE LINGUISTICA', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(216, 112, 2751, 'P97CS744A', 'CIENCIA Y DESARROLLO SOSTENIBLE', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(217, 112, 197, 'P97CS746A', 'FILOSOFÍA DE LAS CIENCIAS ADMINISTRATIVAS', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(218, 113, 3883, 'P97CS752A', 'ASESORÍA GERENCIAL', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(219, 114, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(220, 114, 3968, 'P78DO580E', 'LAS NEUROCIENCIAS Y LA EDUCACIÓN UNIVERSITARIA', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(221, 114, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0002', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(222, 115, 3817, 'P78DO586E', 'PROYECTOS EDUCATIVOS ACTUALES EN AMÉRICA LATINA Y EL PLANETA SOBRE LA EDUCACIÓN BÁSICA', '0002', '0001', 4, 3, '48.00', '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(223, 112, 3885, 'P97CS748A', 'MÉTODOS ALTERNATIVOS DE RESOLUCIÓN DE CONFLICTOS', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(224, 116, 187, 'P01CJ422A', 'COMUNICACIÓN Y ARGUMENTACIÓN CIENTÍFICA', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(225, 116, 2172, 'P24JS504B', 'CONTRATOS COMERCIALES', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(226, 116, 2316, 'P24JS502A', 'TEORÍA DE LOS CONTRATOS Y OBLIGACIONES', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(227, 117, 3914, 'P24JS536A', 'TÍTULOS VALORES', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(228, 118, 187, 'P01CJ422A', 'COMUNICACIÓN Y ARGUMENTACIÓN CIENTÍFICA', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(229, 118, 2991, 'P47JP516A', 'INSTITUCIONES DEL PROCEDIMIENTO ADMINISTRATIVO', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(230, 118, 1186, 'P47JP537A', 'CONTRATACIONES DEL ESTADO Y SISTEMAS ADMINISTRATIVOS EN EL ESTADO PERUANO', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(231, 119, 2108, 'P47JP522B', 'SISTEMAS CONSTITUCIONALES CONTEMPORÁNEOS', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(232, 120, 187, 'P01CJ422A', 'COMUNICACIÓN Y ARGUMENTACIÓN CIENTÍFICA', '0002', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(233, 121, 1040, 'P36JP545A', 'PSIQUIATRÍA FORENSE: EL DELINCUENTE ANORMAL Y ENFERMO PSÍQUICO', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(234, 122, 187, 'P01CJ422A', 'COMUNICACIÓN Y ARGUMENTACIÓN CIENTÍFICA', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(235, 122, 3469, 'P43JS514B', 'DERECHO PROCESAL DEL TRABAJO COMPARADO', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(236, 122, 3553, 'P43JS512A', 'DERECHO INDIVIDUAL DEL TRABAJO: CONTRATOS ESPECIALES', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(237, 123, 2932, 'P43JT521A', 'CONSTITUCIONALIZACIÓN DEL DERECHO DEL TRABAJO', '0002', '0001', 4, 4, '64.00', '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(238, 124, 4037, 'P84DO404A', 'FILOSOFÍA DE LA CIENCIA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(239, 124, 3403, 'P70DO806A', 'TÓPICOS DE DERECHO EMPRESARIAL Y COMERCIAL', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(240, 124, 3960, 'P78DO820E', 'INVESTIGACIÓN II', '0002', '0002', 2, 9, '128.00', '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(241, 120, 3214, 'P36JP532A', 'DERECHO PENAL: PARTE ESPECIAL', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(242, 120, 4135, 'P36JP534B', 'EL JUZGAMIENTO', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(243, 120, 1950, 'P36JP547A', 'TEORÍA DE LA IMPUGNACIÓN Y PRECEDENTES VINCULANTES', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(244, 124, 4002, 'P70DO552A', 'TÓPICOS DE DERECHO PROCESAL PENAL', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(245, 125, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(246, 125, 4004, 'P38ES519A', 'MUESTREO AVANZADO', '0002', '0002', 1, 3, '48.00', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(247, 125, 1671, 'P81ES518B', 'MÉTODOS ESTADÍSTICOS EN INVESTIGACIÓN DE MERCADOS', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(248, 125, 295, 'P01SA670A', 'TESIS I', '0004', '0002', 2, 5, '64.00', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(249, 126, 1120, 'P81ES540A', 'ANÁLISIS DE DECISIÓN EMPRESARIAL', '0001', '0001', 4, 4, '48.00', '0001', 1021, '2023-11-17 10:02:22', '10.0.100.79', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL),
(250, 126, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '128.00', '0001', 1021, '2023-11-17 10:02:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(251, 126, 1921, 'P94IE690A', 'TESIS III', '0004', '0002', 4, 11, '128.00', '0001', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(252, 127, 1868, 'P01GE620A', 'FUNDAMENTOS TEÓRICOS DE LA COMPUTACIÓN', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-17 10:06:38', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(253, 127, 1697, 'P54FI542D', 'FÍSICA ESTADÍSTICA', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(254, 127, 1912, 'P54FI355A', 'TÓPICOS DE FÍSICA MATEMÁTICA', '0002', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(255, 128, 8280, 'IM0123', 'PROGRAMACION CIENTIFICA', '0001', '0001', 2, 4, '64.00', '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:29', '10.0.100.79', NULL, NULL, NULL),
(256, 128, 562, 'P56MT508A', 'TERMODINÁMICA GENERAL', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(257, 128, 8281, 'IM0223', 'METODOS MATEMATICOS II', '0001', '0001', 2, 3, '48.00', '0001', 1021, '2023-11-17 10:49:08', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(258, 129, 1425, 'P83DO514A', 'PRODUCCIÓN Y CARACTERIZACIÓN DE NANOMATERIALES', '0004', '0001', 5, 3, '48.00', '0001', 1021, '2023-11-17 10:51:06', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso_grupo`
--

DROP TABLE IF EXISTS `carga_horaria_curso_grupo`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso_grupo` (
  `ccg_id` int(11) NOT NULL AUTO_INCREMENT,
  `chc_id` int(11) NOT NULL,
  `sem_id` int(11) DEFAULT NULL,
  `prg_id` int(11) DEFAULT NULL,
  `ccg_grupo` int(11) NOT NULL,
  `ccg_estado` varchar(4) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ccg_id`),
  KEY `chc_id` (`chc_id`)
) ENGINE=MyISAM AUTO_INCREMENT=270 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_curso_grupo`
--

INSERT INTO `carga_horaria_curso_grupo` (`ccg_id`, `chc_id`, `sem_id`, `prg_id`, `ccg_grupo`, `ccg_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 69, 73, 1, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, 69, 97, 1, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(3, 3, 70, 55, 1, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 4, 70, 55, 1, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 5, 70, 55, 1, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 6, 70, 55, 1, '0001', 1021, '2023-11-10 11:38:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 7, 70, 40, 1, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 8, 70, 40, 1, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 9, 70, 40, 1, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 10, 70, 40, 1, '0001', 1021, '2023-11-10 12:08:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 11, 70, 78, 1, '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 12, 70, 78, 1, '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 13, 70, 78, 1, '0001', 1021, '2023-11-10 12:23:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 14, 70, 71, 1, '0001', 1021, '2023-11-10 12:23:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 15, 70, 235, 1, '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 16, 70, 235, 1, '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 17, 70, 85, 1, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 18, 70, 85, 1, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 19, 70, 85, 1, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 20, 70, 85, 1, '0001', 1021, '2023-11-13 09:26:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 21, 70, 179, 1, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 22, 70, 179, 1, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(23, 23, 70, 179, 1, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 24, 70, 179, 1, '0001', 1021, '2023-11-13 09:32:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 25, 70, 49, 1, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 25, 70, 49, 2, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 26, 70, 49, 1, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 26, 70, 49, 2, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 27, 70, 49, 1, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 28, 70, 49, 2, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 29, 70, 49, 1, '0001', 1021, '2023-11-13 09:44:07', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 30, 70, 143, 1, '0001', 1021, '2023-11-13 09:45:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 31, 70, 223, 1, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 32, 70, 223, 1, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 33, 70, 223, 1, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 34, 70, 223, 1, '0001', 1021, '2023-11-13 10:29:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 35, 70, 114, 1, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(38, 36, 70, 114, 1, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 37, 70, 114, 1, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 38, 70, 114, 1, '0001', 1021, '2023-11-13 10:36:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 39, 70, 195, 1, '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(42, 39, 70, 195, 2, '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(43, 40, 70, 195, 1, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 41, 70, 195, 1, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(45, 42, 70, 195, 2, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 43, 70, 195, 1, '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 43, 70, 195, 2, '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(48, 44, 70, 148, 1, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(49, 45, 70, 148, 1, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 46, 70, 148, 1, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 47, 70, 148, 1, '0001', 1021, '2023-11-13 11:22:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 48, 70, 128, 1, '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 49, 70, 128, 1, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 50, 70, 128, 1, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(55, 51, 70, 128, 1, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 52, 70, 192, 1, '0001', 1021, '2023-11-13 11:32:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(57, 53, 70, 192, 1, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 54, 70, 192, 1, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 55, 70, 192, 1, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 56, 70, 58, 1, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 57, 70, 58, 1, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 58, 70, 58, 1, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 59, 70, 58, 1, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(64, 60, 70, 187, 1, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 61, 70, 162, 1, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 62, 70, 162, 1, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 63, 70, 162, 1, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 64, 70, 196, 1, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 65, 70, 202, 1, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 66, 70, 202, 1, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 67, 70, 202, 1, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 68, 70, 237, 1, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 69, 70, 134, 1, '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(74, 70, 70, 134, 1, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 71, 70, 134, 1, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 72, 70, 248, 1, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 73, 70, 248, 1, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 74, 70, 248, 1, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 75, 70, 248, 1, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 76, 70, 213, 1, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 77, 70, 213, 1, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 78, 70, 213, 1, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 79, 70, 213, 1, '0001', 1021, '2023-11-13 12:14:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 80, 70, 241, 1, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(85, 81, 70, 68, 1, '0001', 1021, '2023-11-13 12:23:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 82, 70, 68, 1, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 83, 70, 68, 1, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 84, 70, 68, 1, '0001', 1021, '2023-11-13 12:25:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 85, 70, 89, 1, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 86, 70, 36, 1, '0001', 1021, '2023-11-13 12:29:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 87, 70, 57, 1, '0001', 1021, '2023-11-13 12:35:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 88, 70, 57, 1, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 89, 70, 57, 1, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 90, 70, 57, 1, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 91, 70, 57, 1, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 92, 70, 27, 1, '0001', 1021, '2023-11-13 12:55:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 93, 70, 79, 1, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 94, 70, 56, 1, '0001', 1021, '2023-11-13 12:59:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 95, 70, 96, 1, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 96, 70, 96, 1, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 97, 70, 96, 1, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 98, 70, 96, 1, '0001', 1021, '2023-11-13 13:04:52', '10.0.100.98', 1021, '2023-11-13 13:44:52', '10.0.100.98', NULL, NULL, NULL),
(103, 99, 70, 108, 1, '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 100, 70, 108, 1, '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 101, 70, 108, 1, '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 102, 70, 108, 1, '0001', 1021, '2023-11-13 13:10:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 103, 70, 136, 1, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 104, 70, 136, 1, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 105, 70, 136, 1, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 106, 70, 136, 1, '0001', 1021, '2023-11-13 13:38:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 107, 70, 15, 1, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 108, 70, 15, 1, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 109, 70, 15, 1, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 110, 70, 15, 1, '0001', 1021, '2023-11-13 13:51:49', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(115, 111, 70, 219, 1, '0001', 1021, '2023-11-13 13:52:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(116, 112, 70, 122, 1, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(117, 113, 70, 122, 1, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(118, 114, 70, 122, 1, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(119, 115, 70, 122, 1, '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(120, 116, 70, 64, 1, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(121, 117, 70, 64, 1, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(122, 118, 70, 64, 1, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 119, 70, 64, 1, '0001', 1020, '2023-11-14 12:52:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(124, 120, 70, 164, 1, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(125, 121, 70, 164, 1, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(126, 122, 70, 164, 1, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(127, 123, 70, 164, 1, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:43', '10.0.100.54', NULL, NULL, NULL),
(128, 124, 70, 73, 1, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(129, 125, 70, 73, 1, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(130, 126, 70, 73, 1, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(131, 127, 70, 73, 1, '0001', 1021, '2023-11-14 13:06:30', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(132, 128, 70, 112, 1, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(133, 129, 70, 112, 1, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(134, 130, 70, 112, 1, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(135, 131, 70, 112, 1, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(136, 132, 70, 150, 1, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 133, 70, 150, 1, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(138, 134, 70, 150, 1, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(139, 135, 70, 251, 1, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(140, 136, 70, 251, 1, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(141, 137, 70, 251, 1, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(142, 138, 70, 31, 1, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(143, 139, 70, 97, 1, '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(144, 140, 70, 97, 1, '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(145, 141, 70, 120, 1, '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(146, 142, 70, 120, 1, '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(147, 143, 70, 150, 1, '0001', 1021, '2023-11-14 13:40:16', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(148, 144, 70, 106, 1, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(149, 145, 70, 106, 1, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(150, 146, 70, 106, 1, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(151, 147, 70, 106, 1, '0001', 1021, '2023-11-14 13:44:47', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(152, 148, 70, 127, 1, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(153, 148, 70, 127, 2, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(154, 149, 70, 127, 1, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(155, 149, 70, 127, 2, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 150, 70, 127, 1, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(157, 150, 70, 127, 2, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 151, 70, 127, 1, '0001', 1021, '2023-11-14 13:51:20', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(159, 152, 70, 217, 1, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(160, 153, 70, 217, 1, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(161, 154, 70, 217, 1, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(162, 155, 70, 217, 1, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(163, 156, 70, 217, 1, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(164, 157, 70, 184, 1, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(165, 158, 70, 184, 1, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(166, 158, 70, 184, 2, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(167, 159, 70, 182, 1, '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(168, 160, 70, 182, 1, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(169, 161, 70, 182, 1, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(170, 162, 70, 194, 1, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(171, 163, 70, 194, 1, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(172, 164, 70, 194, 1, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(173, 165, 70, 194, 1, '0001', 1021, '2023-11-15 08:18:30', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(174, 166, 70, 201, 1, '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(175, 167, 70, 201, 1, '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(176, 168, 70, 155, 1, '0001', 1021, '2023-11-15 08:23:57', '10.0.100.26', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL),
(177, 169, 70, 182, 1, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(178, 170, 70, 155, 1, '0001', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(179, 171, 70, 244, 1, '0001', 1021, '2023-11-15 08:40:59', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(180, 172, 70, 244, 1, '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(181, 173, 70, 244, 1, '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(182, 174, 70, 244, 1, '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(183, 175, 70, 244, 1, '0001', 1021, '2023-11-15 08:44:32', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(184, 176, 70, 231, 1, '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(185, 177, 70, 231, 1, '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(186, 178, 70, 231, 1, '0001', 1021, '2023-11-15 08:51:04', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(187, 179, 70, 182, 1, '0001', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(188, 180, 70, 52, 1, '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(189, 181, 70, 52, 1, '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(190, 182, 70, 66, 1, '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(191, 183, 70, 66, 1, '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(192, 184, 70, 252, 1, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(193, 185, 70, 252, 1, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(194, 186, 70, 252, 1, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(195, 187, 70, 252, 1, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(196, 188, 70, 116, 1, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(197, 189, 70, 116, 1, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(198, 190, 70, 116, 1, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL),
(199, 191, 70, 172, 1, '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(200, 192, 70, 172, 1, '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(201, 193, 70, 116, 1, '0001', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(202, 194, 70, 116, 1, '0001', 1021, '2023-11-15 09:15:10', '10.0.100.79', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL),
(203, 195, 70, 116, 1, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(204, 196, 70, 20, 1, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(205, 197, 70, 20, 1, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(206, 198, 70, 20, 1, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(207, 199, 70, 20, 1, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(208, 200, 70, 20, 1, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(209, 201, 70, 20, 1, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(210, 202, 70, 38, 1, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(211, 203, 70, 38, 1, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(212, 204, 70, 38, 1, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(213, 205, 70, 38, 1, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(214, 206, 70, 38, 1, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(215, 207, 70, 144, 1, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(216, 208, 70, 144, 1, '0001', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(217, 209, 70, 144, 1, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(218, 210, 70, 91, 1, '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(219, 211, 70, 91, 1, '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(220, 212, 70, 133, 1, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(221, 213, 70, 133, 1, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(222, 214, 70, 133, 1, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(223, 215, 70, 133, 1, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(224, 216, 70, 183, 1, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(225, 217, 70, 183, 1, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(226, 218, 70, 183, 1, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(227, 219, 70, 245, 1, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(228, 220, 70, 245, 1, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(229, 221, 70, 245, 1, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(230, 222, 70, 245, 1, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(231, 223, 70, 183, 1, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(232, 224, 70, 18, 1, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(233, 225, 70, 18, 1, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(234, 226, 70, 18, 1, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(235, 227, 70, 18, 1, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(236, 228, 70, 60, 1, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(237, 229, 70, 60, 1, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(238, 229, 70, 60, 2, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(239, 230, 70, 60, 2, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(240, 231, 70, 60, 1, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(241, 232, 70, 35, 1, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(242, 232, 70, 35, 2, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(243, 233, 70, 35, 1, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(244, 234, 70, 51, 1, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(245, 235, 70, 51, 1, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(246, 236, 70, 51, 1, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(247, 237, 70, 51, 1, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(248, 238, 70, 70, 1, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(249, 239, 70, 70, 1, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(250, 240, 70, 70, 1, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(251, 241, 70, 35, 2, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(252, 242, 70, 35, 1, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(253, 228, 70, 60, 2, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(254, 241, 70, 35, 1, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(255, 243, 70, 35, 2, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(256, 244, 70, 70, 1, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(257, 245, 70, 160, 1, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(258, 246, 70, 160, 1, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(259, 247, 70, 160, 1, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(260, 248, 70, 160, 1, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(261, 249, 70, 160, 1, '0001', 1021, '2023-11-17 10:02:22', '10.0.100.79', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL),
(262, 251, 70, 160, 1, '0001', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(263, 252, 70, 115, 1, '0001', 1021, '2023-11-17 10:06:38', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(264, 253, 70, 115, 1, '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(265, 254, 70, 115, 1, '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(266, 255, 70, 246, 1, '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:29', '10.0.100.79', NULL, NULL, NULL),
(267, 256, 70, 246, 1, '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(268, 257, 70, 246, 1, '0001', 1021, '2023-11-17 10:49:08', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(269, 258, 70, 227, 1, '0001', 1021, '2023-11-17 10:51:06', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso_grupo_docente`
--

DROP TABLE IF EXISTS `carga_horaria_curso_grupo_docente`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso_grupo_docente` (
  `cgd_id` int(11) NOT NULL AUTO_INCREMENT,
  `ccg_id` int(11) NOT NULL,
  `cgd_titular` bit(1) NOT NULL,
  `cgd_horas` decimal(10,2) DEFAULT NULL,
  `cgd_fecha_inicio` datetime DEFAULT NULL,
  `cgd_fecha_fin` datetime DEFAULT NULL,
  `doc_condicion` varchar(25) DEFAULT NULL,
  `doc_grado` varchar(45) DEFAULT NULL,
  `doc_id` int(11) DEFAULT NULL,
  `doc_codigo` varchar(10) DEFAULT NULL,
  `doc_documento` varchar(15) DEFAULT NULL,
  `doc_nombres` varchar(180) DEFAULT NULL,
  `doc_celular` varchar(180) DEFAULT NULL,
  `doc_email` varchar(180) DEFAULT NULL,
  `cgd_estado` varchar(4) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgd_id`),
  KEY `ccg_id` (`ccg_id`)
) ENGINE=MyISAM AUTO_INCREMENT=293 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_curso_grupo_docente`
--

INSERT INTO `carga_horaria_curso_grupo_docente` (`cgd_id`, `ccg_id`, `cgd_titular`, `cgd_horas`, `cgd_fecha_inicio`, `cgd_fecha_fin`, `doc_condicion`, `doc_grado`, `doc_id`, `doc_codigo`, `doc_documento`, `doc_nombres`, `doc_celular`, `doc_email`, `cgd_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, b'1', NULL, NULL, NULL, '0001', '0001', 303, 'AGGA5044', '18161457', 'AGREDA GAMBOA EVERSON DAVID', '966243289', 'eagreda@unitru.edu.pe', '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, b'1', NULL, NULL, NULL, '0001', '0001', 6938, 'ADAS3227', '00000000', 'ADRIAN ASCON SHEYLA TATIANA', '', '', '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(3, 3, b'1', NULL, NULL, NULL, '0001', '0002', 408, 'GAVA5933', '17815670', 'GAVIDIA VALENCIA JOSE GILBERTO', '949704800', 'jgavidiav@unitru.edu.pe', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, b'0', NULL, NULL, NULL, '0001', '0002', 158, 'REPE3503', '17818229', 'RENGIFO PENADILLOS ROGER ANTONIO', '', 'rrengifo@unitru.edu.pe', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 4, b'1', NULL, NULL, NULL, '0001', '0002', 411, 'SAGU8356', '17816655', 'SAGASTEGUI GUARNIZ WILLIAM ANTONIO', '', 'wsagastegui@unitru.edu.pe', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 4, b'0', NULL, NULL, NULL, '0001', '0002', 167, 'VILA1715', '70323118', 'VILLARREAL LA TORRE VICTOR EDUARDO', '', 'vvillarreal@unitru.edu.pe', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 5, b'1', NULL, NULL, NULL, '0002', '0001', 414, 'SAZA8486', '06560611', 'SAMAME ZATTA TERESA LIBERTAD', '975286415', 'telisza2007@gmail.com', '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 6, b'1', NULL, NULL, NULL, '0001', '0003', 400, 'ARFA7773', '17895424', 'ARMAS FAVA LOURDES ADELAIDA', '', 'larmasf@unitru.edu.pe', '0001', 1021, '2023-11-10 11:38:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 7, b'1', NULL, NULL, NULL, '0001', '0002', 408, 'GAVA5933', '17815670', 'GAVIDIA VALENCIA JOSE GILBERTO', '949704800', 'jgavidiav@unitru.edu.pe', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 7, b'0', NULL, NULL, NULL, '0001', '0002', 158, 'REPE3503', '17818229', 'RENGIFO PENADILLOS ROGER ANTONIO', '', 'rrengifo@unitru.edu.pe', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 8, b'1', NULL, NULL, NULL, '0001', '0002', 160, 'ALPL8363', '18036605', 'ALVA PLASENCIA PEDRO MARCELO', '966209979', 'palva@unitru.edu.pe', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 9, b'1', NULL, NULL, NULL, '0001', '0002', 6832, 'YBJU5872', '18159512', 'YBAÑEZ JULCA ROBERTO OSMUNDO', '976345993', 'rybanez@unitru.edu.pe', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 9, b'0', NULL, NULL, NULL, '0001', '0002', 170, 'QUDI4933', '42221001', 'QUISPE DIAZ IVAN MIGUEL', '', 'iquispe@unitru.edu.pe', '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 10, b'1', NULL, NULL, NULL, '0001', '0003', 400, 'ARFA7773', '17895424', 'ARMAS FAVA LOURDES ADELAIDA', '', 'larmasf@unitru.edu.pe', '0001', 1021, '2023-11-10 12:08:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 11, b'1', NULL, NULL, NULL, '0001', '0001', 408, 'GAVA5933', '17815670', 'GAVIDIA VALENCIA JOSE GILBERTO', '949704800', 'jgavidiav@unitru.edu.pe', '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 11, b'0', NULL, NULL, NULL, '0001', '0001', 158, 'REPE3503', '17818229', 'RENGIFO PENADILLOS ROGER ANTONIO', '', 'rrengifo@unitru.edu.pe', '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 12, b'1', NULL, NULL, NULL, '0001', '0001', 171, 'PANI1015', '00000000', 'NIRALDO      PAULINO', '', 'diretoria@medlex.com.br', '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 13, b'1', NULL, NULL, NULL, '0001', '0002', 171, 'PANI1015', '00000000', 'NIRALDO      PAULINO', '', 'diretoria@medlex.com.br', '0001', 1021, '2023-11-10 12:23:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 14, b'1', NULL, NULL, NULL, '0001', '0001', 400, 'ARFA7773', '17895424', 'ARMAS FAVA LOURDES ADELAIDA', '', 'larmasf@unitru.edu.pe', '0001', 1021, '2023-11-10 12:23:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 15, b'1', NULL, NULL, NULL, '0001', '0001', 468, 'AGMA3141', '18071385', 'AGUILAR MARIN PABLO', '964056070', 'paguilar@unitru.edu.pe', '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 16, b'1', NULL, NULL, NULL, '0001', '0001', 159, 'GAYU9676', '18220172', 'GANOZA YUPANQUI MAYAR LUIS', '958822250', 'mganoza@unitru.edu.pe', '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 16, b'0', NULL, NULL, NULL, '0001', '0001', 175, 'VECA5556', '17971934', 'VENEGAS CASANOVA EDMUNDO ARTURO', '996363642', 'evenegas@unitru.edu.pe', '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(23, 17, b'1', NULL, NULL, NULL, '0001', '0001', 301, 'MERI4147', '18070765', 'MENDOZA RIVERA RICARDO DARIO', '949511552', 'rmendoza@unitru.edu.pe', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 18, b'1', NULL, NULL, NULL, '0001', '0001', 302, 'GATO1157', '18123489', 'GASTAÑADUI TORRES CONSTANTE', '949705600', 'cgastanudi@unitru.edu.pe', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 19, b'1', NULL, NULL, NULL, '0001', '0001', 303, 'AGGA5044', '18161457', 'AGREDA GAMBOA EVERSON DAVID', '966243289', 'eagreda@unitru.edu.pe', '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 20, b'1', NULL, NULL, NULL, '0001', '0001', 431, 'MEDE6380', '17434055', 'MENDOZA DE LOS SANTOS ALBERTO CARLOS', '', 'amendozad@unitru.edu.pe', '0001', 1021, '2023-11-13 09:26:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 21, b'1', NULL, NULL, NULL, '0001', '0002', 332, 'ALQU6330', '17906050', 'ALVARADO QUINTANA HERNÁN MARTÍN', '944367102', 'halvarado@unitru.edu.pe', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 22, b'1', NULL, NULL, NULL, '0001', '0002', 5708, 'RONO9315', '17883457', 'RODRIGUEZ NOVOA FRANCISCO ELIAS', '', 'frodriguez@unitru.edu.pe', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 23, b'1', NULL, NULL, NULL, '0001', '0002', 3549, 'BEGU8179', '17852866', 'BENITES GUTIERREZ LUIS ALBERTO', '949992846', 'lbenites@unitru.edu.pe', '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 24, b'1', NULL, NULL, NULL, '0001', '0001', 7004, 'ROCO4808', '00000000', 'ROJAS CORONEL JUAN CARLOS', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 09:32:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 25, b'1', NULL, NULL, NULL, '0001', '0001', 304, 'DIDI4592', '40584500', 'DIAZ DIAZ ALEX FABIAN', '957239951', 'adiazd@unitru.edu.pe', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 26, b'1', NULL, NULL, NULL, '0001', '0001', 308, 'VIQU7448', '40132759', 'VILLAR QUIROZ JOSUALDO CARLOS', '999933155', 'jvillar@unitru.edu.pe', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 27, b'1', NULL, NULL, NULL, '0001', '0001', 433, 'VELU7674', '32974419', 'VEGA LUJAN SANTOS CLEBER', '994077088', 'cleber_vlc@hotmail.com', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 28, b'1', NULL, NULL, NULL, '0001', '0001', 323, 'RACO9500', '17924015', 'RAMIREZ CORDOVA SEGUNDO MIGUEL', '999100858', 'sramirez@unitru.edu.pe', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 29, b'1', NULL, NULL, NULL, '0001', '0001', 7004, 'ROCO4808', '00000000', 'ROJAS CORONEL JUAN CARLOS', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 30, b'1', NULL, NULL, NULL, '0001', '0001', 322, 'VIBA9216', '17932651', 'VILLAR BAZAN CARLOS ALBERTO', '999933400', 'cvillar@unitru.edu.pe', '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 31, b'1', NULL, NULL, NULL, '0001', '0001', 3551, 'BABE4540', '08602678', 'BARBARAN BENITES NELSON', '943225656', 'nelsonbarbaran12@gmail.com', '0001', 1021, '2023-11-13 09:44:07', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(38, 32, b'1', NULL, NULL, NULL, '0001', '0001', 324, 'BUPE9087', '19227350', 'BUCHELLI PERALES ORIVEL JACKSON', '', 'jbuchelli@unitru.edu.pe', '0001', 1021, '2023-11-13 09:45:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 33, b'1', NULL, NULL, NULL, '0001', '0001', 345, 'COTE1799', '41872247', 'COTRINA TEATINO MARCO ANTONIO', '989747200', 'marco.cotrina@hotmail.com', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 34, b'1', NULL, NULL, NULL, '0001', '0001', 348, 'ARRE5456', '26733726', 'ARANGO RETAMOZO SOLIO MARINO', '', 'sarango@unitru.edu.pe', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 35, b'1', NULL, NULL, NULL, '0001', '0001', 5701, 'ROCA6205', '32770121', 'ROBLES CASTILLO HEBER MAX', '949162071', 'hrobles@unitru.edu.pe', '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(42, 36, b'1', NULL, NULL, NULL, '0001', '0001', 328, 'CICA1046', '08017699', 'CIUDAD CAMPOS ANDRES GRIMALDO', '993152929', 'aciudad.sopeso@gmail.com', '0001', 1021, '2023-11-13 10:29:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(43, 37, b'1', NULL, NULL, NULL, '0001', '0001', 438, 'SACH3270', '43724409', 'SAAVEDRA CHUMACERO LOURDES EULALIA', '923559246', 'lsaavedrach@unitru.edu.pe', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 38, b'1', NULL, NULL, NULL, '0001', '0001', 334, 'MERO9119', '17894163', 'MEDINA RODRIGUEZ JORGE ENRIQUE', '943168280', 'jmedina@unitru.edu.pe', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(45, 39, b'1', NULL, NULL, NULL, '0001', '0001', 5818, 'ELSI3543', '16885225', 'ELIAS  SILUPU JORGE WILMER ', '993015242', 'eliassilupu15@gmail.com', '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 40, b'1', NULL, NULL, NULL, '0001', '0001', 342, 'PEPA1841', '09158237', 'PEÑA PAJUELO SIMEÓN RAIMUNDO', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 10:36:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 41, b'1', NULL, NULL, NULL, '0001', '0001', 326, 'BAQU4650', '17858339', 'BACILIO QUIROZ AVELINO JAVIER', '949154454', 'abacilio@unitru.edu.pe', '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(48, 42, b'1', NULL, NULL, NULL, '0001', '0001', 7005, 'ARAR3188', '40889077', 'AREVALO ARANDA CESAR POL', '', 'carevalo@unitru.edu.pe', '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(49, 43, b'1', NULL, NULL, NULL, '0001', '0001', 439, 'BOGA1058', '17813976', 'BOCANEGRA GARCÍA CARLOS ALFREDO', '', 'cbocanegra@unitru.edu.pe', '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 44, b'1', NULL, NULL, NULL, '0001', '0001', 339, 'GRDE6473', '06235251', 'GRADOS DEL MAR MIGUEL ANGEL', '991733112', 'mgradosm@yahoo.com', '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 45, b'1', NULL, NULL, NULL, '0001', '0001', 343, 'BAUR1764', '00000000', 'BARAHOMA URBANO EMERSON DAVID', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 46, b'1', NULL, NULL, NULL, '0001', '0001', 320, 'CACA3562', '18195941', 'CASTAÑEDA CARRANZA JULIO ALBERTO', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 47, b'1', NULL, NULL, NULL, '0001', '0001', 333, 'GOVA6236', '18021980', 'GONZÁLEZ VÁSQUEZ JOE ALEXIS', '976825908', 'jgonzalezv@unitru.edu.pe', '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 48, b'1', NULL, NULL, NULL, '0001', '0001', 310, 'ALAL2240', '17923116', 'ALCANTARA ALZA VICTOR MANUEL', '', 'valcantara@unitru.edu.pe', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(55, 49, b'1', NULL, NULL, NULL, '0001', '0001', 2533, 'CAVA7575', '18005275', 'CASTILLO VASQUEZ LUIS JOSE', '993398066', 'lujocasvas53@hotmail.com', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 50, b'1', NULL, NULL, NULL, '0001', '0001', 2539, 'BEGU6512', '17832794', 'BENITES GUTIERREZ MIGUEL ARMANDO', '990203554', 'mbenites@unitru.edu.pe', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(57, 50, b'0', NULL, NULL, NULL, '0001', '0001', 3575, 'MAVA6178', '17806640', 'MACO VASQUEZ WILSON ARCENIO', '', 'wmaco@unitru.edu.pe', '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 51, b'1', NULL, NULL, NULL, '0001', '0001', 5720, 'LILU8420', '40026086', 'LINARES LUJAN GUILLERMO ALBERTO', '', 'glinares@unitru.edu.pe', '0001', 1021, '2023-11-13 11:22:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 52, b'1', NULL, NULL, NULL, '0001', '0001', 443, 'CAAN1694', '70411316', 'CASTRO ANGULO RAUL ERICSON', '980438301', 'rcastroa@unitru.edu.pe', '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 53, b'1', NULL, NULL, NULL, '0001', '0001', 444, 'QUJA1785', '41152469', 'QUIJANO JARA CARLOS HELI', '990278409', 'carlos_qj@hotmail.com', '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 54, b'1', NULL, NULL, NULL, '0001', '0001', 447, 'CHRE1038', '17890546', 'CHARCAPE RAVELO JESUS MANUEL', '949571799', 'jcharcaper@unitru.edu.pe', '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 55, b'1', NULL, NULL, NULL, '0001', '0001', 445, 'WIKR1702', '17801240', 'WILSON KRUGG JUAN HÉCTOR', '949335239', 'jwilson@unitru.edu.pe', '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 56, b'1', NULL, NULL, NULL, '0002', '0002', 50, 'LECA1052', '46248657', 'LEIVA CABRERA FRANS ALLINSON', '961616331', 'fleiva@unitru.edu.pe', '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(64, 57, b'1', NULL, NULL, NULL, '0002', '0002', 41, 'DECA9342', '47691182', 'DE LA CRUZ CASTILLO ANTHONY JORDAN', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 58, b'1', NULL, NULL, NULL, '0002', '0002', 447, 'CHRE1038', '17890546', 'CHARCAPE RAVELO JESUS MANUEL', '949571799', 'jcharcaper@unitru.edu.pe', '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 59, b'1', NULL, NULL, NULL, '0001', '0001', 51, 'LETO1756', '18146806', 'LEÓN TORRES CARLOS ALBERTO', '999798991', 'cleon@unitru.edu.pe', '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 60, b'1', NULL, NULL, NULL, '0001', '0003', 3584, 'GOVE3558', '47141613', 'GONZALES VELÁSQUEZ CARMEN LIZBETH YURAC', '951773279', 'cgonzalesv@unitru.edu.pe', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 61, b'1', NULL, NULL, NULL, '0001', '0003', 451, 'META9030', '18109733', 'MEDINA TAFUR CESAR AUGUSTO', '949686451', 'cmedinae@unitru.edu.pe', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 62, b'1', NULL, NULL, NULL, '0001', '0003', 58, 'ROES9022', '17860628', 'RODRIGUEZ ESPEJO MARLENE RENE', '990956810', 'mrodrigueze@unitru.edu.pe', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 62, b'0', NULL, NULL, NULL, '0001', '0003', 451, 'META9030', '18109733', 'MEDINA TAFUR CESAR AUGUSTO', '949686451', 'cmedinae@unitru.edu.pe', '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 63, b'1', NULL, NULL, NULL, '0001', '0001', 452, 'DÍSÁ2494', '43749140', 'DÍAZ SÁNCHEZ CÉSAR NARCÉS', '991831571', 'cdiazsa@unitru.edu.pe', '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 64, b'1', NULL, NULL, NULL, '0001', '0001', 5701, 'ROCA6205', '32770121', 'ROBLES CASTILLO HEBER MAX', '949162071', 'hrobles@unitru.edu.pe', '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 65, b'1', NULL, NULL, NULL, '0001', '0002', 3583, 'CAZA5137', '42727009', 'CASTILLO ZAVALA JOSE LUIS', '', 'jlcastilloz@unitru.edu.pe', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(74, 66, b'1', NULL, NULL, NULL, '0001', '0001', 52, 'QUDI3269', '17802714', 'QUINTANA DÍAZ ANÍBAL ', '940216916', 'aquintana@unitru.edu.pe', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 67, b'1', NULL, NULL, NULL, '0001', '0002', 5673, 'PEHU6604', '46588675', 'PEDRO HUAMAN JUAN JAVIER', '986112991', 'jpedro@unitru.edu.pe', '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 68, b'1', NULL, NULL, NULL, '0001', '0001', 474, 'MOLE2102', '17859395', 'MOSTACERO LEON JOSE', '943271017', 'JMOSTACERO@UNITRU.EDU.PE', '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 68, b'0', NULL, NULL, NULL, '0001', '0001', 41, 'DECA9342', '47691182', 'DE LA CRUZ CASTILLO ANTHONY JORDAN', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 69, b'1', NULL, NULL, NULL, '0001', '0001', 5671, 'MICH3048', '17875720', 'MIRANDA CHAVEZ ALCIBIADES HELI', '987075068', 'HMIRANDCH@gmail.com', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 70, b'1', NULL, NULL, NULL, '0001', '0001', 42, 'GIRI4554', '70815319', 'GIL RIVERO ARMANDO EFRAÍN', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 71, b'1', NULL, NULL, NULL, '0001', '0001', 474, 'MOLE2102', '17859395', 'MOSTACERO LEON JOSE', '943271017', 'JMOSTACERO@UNITRU.EDU.PE', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 71, b'0', NULL, NULL, NULL, '0001', '0001', 3602, 'LÓME1822', '17865684', 'LÓPEZ MEDINA SEGUNDO ELOY', '949581627', 'slopezm@unitru.edu.pe', '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 72, b'1', NULL, NULL, NULL, '0001', '0001', 43, 'MUGA3520', '18841383', 'MUÑOZ GANOZA EDUARDO JOSÉ', '937188700', 'eganoza@unitru.edu.pe', '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 73, b'0', NULL, NULL, NULL, '0001', '0001', 5800, 'CAVE1227', '17932890', 'CASTILLO VEREAU DOLORES ESMILDA', '978369750', 'dcastillo@unitru.edu.pe', '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 74, b'1', NULL, NULL, NULL, '0001', '0001', 6833, 'ROLO6999', '80865523', 'RODRIGUEZ LOPEZ JAVIER ISIDRO', '573112667903', 'javierisidrorodriguezl@gmail.com', '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(85, 75, b'1', NULL, NULL, NULL, '0001', '0001', 77, 'GOGO5259', '17881385', 'GONZALEZ Y GONZALEZ VIOLETA FREDESMINDA', '', 'vgonzalez@unitru.edu.pe', '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 76, b'1', NULL, NULL, NULL, '0001', '0001', 5796, 'PESH8450', '17861644', 'PESANTES SHIMAJUKO SOLEDAD MARLENE', '', 'spesantes@unitru.edu.pe', '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 76, b'0', NULL, NULL, NULL, '0001', '0001', 428, 'FEFI2644', '45941307', 'FERNANDEZ FIGUEROA ANTONIO MANFREDI', '902033517', 'afernandezf@unitru.edu.pe', '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 77, b'1', NULL, NULL, NULL, '0001', '0003', 74, 'ROAR3255', '17998396', 'RODRÍGUEZ ARGOMEDO MARCELA LIDUVINA', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 78, b'1', NULL, NULL, NULL, '0001', '0003', 5794, 'ROSA7543', '18831684', 'RODRIGUEZ SANCHEZ MERCEDES TERESA', '', 'mrodriguezs@unitru.edu.pe', '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 79, b'1', NULL, NULL, NULL, '0001', '0003', 5798, 'LEES5880', '17933464', 'LEITON ESPINOZA ZOILA ESPERANZA', '944470350', 'zeleiton@unitru.edu.pe', '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 79, b'0', NULL, NULL, NULL, '0003', '0003', 87, 'LAHU4180', '17867593', 'LAVADO HUARCAYA SOFIA SABINA', '968451184', 'giescasofia@gmail.com', '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 80, b'1', NULL, NULL, NULL, '0001', '0003', 5808, 'LUMO9444', '17924512', 'LUNA VICTORIA MORI FLOR MARLENE', '948960930', 'flunavictoria@unitru.edu.pe', '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 81, b'1', NULL, NULL, NULL, '0001', '0003', 89, 'RAPE5531', 'GF698781', 'RAMOS PEREIRA ELIANE ', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 82, b'1', NULL, NULL, NULL, '0001', '0003', 90, 'HUAN1028', '17802202', 'HUERTAS ANGULO FLOR MARÍA DEL ROSARIO', '949013650', 'huertas.rosario@gmail.com', '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 83, b'1', NULL, NULL, NULL, '0001', '0003', 91, 'COAN9084', '00320489', 'COSTA ROSA ANDRADE SILVA ROSE MARY', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 12:14:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 84, b'1', NULL, NULL, NULL, '0002', '0003', 2536, 'CAGA2195', '005747750', 'CARDENAS GAUDRY MARIA MAGDALENA', '99999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 85, b'1', NULL, NULL, NULL, '0002', '0001', 263, 'DAVA7884', '47665624', 'DAMIANO VÁSQUEZ BEATRIZ', '956335800', 'bedamvas@gmail.com', '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 86, b'1', NULL, NULL, NULL, '0002', '0001', 1494, 'RIPA1083', '45490857', 'RIOS PACHECO RONNY', '992722811', 'ronmatsa@gmail.com', '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 87, b'1', NULL, NULL, NULL, '0001', '0001', 378, 'CAAG4678', '80247224', 'CABANILLAS AGREDA CARLOS ALBERTO', '949798928', 'ccabanillas@unitru.edu.pe', '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 88, b'1', NULL, NULL, NULL, '0001', '0003', 383, 'GARO5139', 'G37536256', 'GARCÍA ROMERO LILIANA', '', 'liliana.romero@umich.mx', '0001', 1021, '2023-11-13 12:25:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 88, b'0', NULL, NULL, NULL, '0001', '0002', 384, 'MABA3298', '00000000', 'MADRIGAL BARRERA JOSÉ JAIME', '', 'jose.madrigal@umich.mx', '0001', 1021, '2023-11-13 12:25:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 89, b'1', NULL, NULL, NULL, '0003', '0001', 387, 'MESÁ6159', '17899049', 'MEDINA SÁNCHEZ BETHOVEN', '947935924', 'bemedina3@yahoo.es', '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(103, 90, b'1', NULL, NULL, NULL, '0002', '0002', 388, 'ARTI4142', '47028321', 'AREDO TISNADO VICTOR JESUS', '989855807', 'vj.aredo@gmail.com', '0001', 1021, '2023-11-13 12:29:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 93, b'1', NULL, NULL, NULL, '0001', '0001', 391, 'GAFI2505', '01204866162', 'GARCÉS FIALLOS FELIPE RAFAEL', '', 'felipegarces23@yahoo.com', '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 93, b'0', NULL, NULL, NULL, '0001', '0001', 393, 'CHTO8735', '00000000', 'CHIRINOS TORRES DORYS', '', 'dorys.chirinos@utm.edu.ec', '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 94, b'1', NULL, NULL, NULL, '0001', '0001', 394, 'PECO6161', '00000000', 'PEÑAHERRERA COLINA LUIS ANTONIO', '', 'anpeco2000@yahoo.com', '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 95, b'1', NULL, NULL, NULL, '0004', '0002', 395, 'PRBE4444', '00000000', 'PRIETO BENAVIDES OSCAR', '', 'oprieto@uteq.edu.ec', '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 96, b'1', NULL, NULL, NULL, '0001', '0001', 398, 'ELIC8648', '09161133', 'ELIANA ICOCHEA MARÍA', '952959488', 'micochead@unmsm.edu.pe', '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 97, b'1', NULL, NULL, NULL, '0003', '0001', 7003, 'DECA2568', '40057428', 'DEZA CASTILLO MIGUEL', '', 'jdezac@unitru.edu.pe', '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 98, b'1', NULL, NULL, NULL, '0003', '0001', 354, 'MOSA9010', '18136590', 'MONTENEGRO SALDAÑA CECILIA FABIOLA', '960829647', 'cecimontenegro3@hotmail.com', '0001', 1021, '2023-11-13 12:59:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 99, b'1', NULL, NULL, NULL, '0001', '0001', 365, 'BRCA5234', '41916985', 'BRAVO CARRE MANUEL ALBERTO', '979792641', 'mbravoc@unitru.edu.pe', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 100, b'1', NULL, NULL, NULL, '0001', '0001', 356, 'YERA7584', '40064653', 'YEPJÉN RAMOS ALEJANDRO ELJOV', '', 'ayepjen@unitru.edu.pe', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 101, b'1', NULL, NULL, NULL, '0001', '0002', 358, 'COTE3321', '17832222', 'CORONADO TELLO LUIS ENRIQUE', '', 'lcoronado@unitru.edu.pe', '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 102, b'1', NULL, NULL, NULL, '0001', '0001', 352, 'PETA8005', '41028199', 'PEREDA TAPIA SONIA LILIANA', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-13 13:04:52', '10.0.100.98', 1021, '2023-11-13 13:44:52', '10.0.100.98', NULL, NULL, NULL),
(115, 103, b'1', NULL, NULL, NULL, '0003', '0002', 1512, 'GOGO2256', '17889722', 'GONZALEZ GONZALEZ DIONICIO GODOFREDO', '949999189', 'dggonzalez@unitru.edu.pe', '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(116, 104, b'1', NULL, NULL, NULL, '0002', '0002', 449, 'TOLA5179', '40728952', 'TORRES LARA MARCO ANTONIO', '949521100', 'marcotorrreslara@hotmail.com', '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(117, 105, b'1', NULL, NULL, NULL, '0001', '0002', 73, 'PIRA9828', '18167441', 'PINCHI RAMÍREZ WADSON ', '994455055', 'wpinchi@unitru.edu.pe', '0001', 1021, '2023-11-13 13:08:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(118, 106, b'1', NULL, NULL, NULL, '0002', '0001', 368, 'PEVI1193', '18164722', 'PELAEZ VINCES EDGARD JOSE', '', 'epelaez@unitru.edu.pe', '0001', 1021, '2023-11-13 13:10:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(119, 107, b'1', NULL, NULL, NULL, '0003', '0002', 1512, 'GOGO2256', '17889722', 'GONZALEZ GONZALEZ DIONICIO GODOFREDO', '949999189', 'dggonzalez@unitru.edu.pe', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(120, 108, b'1', NULL, NULL, NULL, '0001', '0003', 366, 'AGPA7427', '17906288', 'AGUILAR PAREDES OREALIS MARÍA DEL SOCORRO', '933688230', 'oaguilar@gmail.com', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(121, 109, b'1', NULL, NULL, NULL, '0001', '0003', 367, 'VEBA7465', '17837233', 'VEGA BAZÁN  RONCAL DELIA', '948890191', 'dvega@unitru.edu.pe', '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(122, 110, b'1', NULL, NULL, NULL, '0001', '0003', 369, 'URCA1455', '43650457', 'URIOL CASTILLO GAUDY TERESA', '', 'guriolc@unitru.edu.pe', '0001', 1021, '2023-11-13 13:38:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 111, b'1', NULL, NULL, NULL, '0001', '0002', 468, 'AGMA3141', '18071385', 'AGUILAR MARIN PABLO', '964056070', 'paguilar@unitru.edu.pe', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(124, 112, b'1', NULL, NULL, NULL, '0002', '0002', 1480, 'VAMO4014', '16475600', 'VASQUEZ MORALES ARMANDO', '948112893', 'arvasquezm@unitru.edu.pe', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(125, 113, b'1', NULL, NULL, NULL, '0001', '0003', 349, 'FLPE9855', '40280312', 'FLORES PEREZ YOYA BETZABE', '984545459', 'yflores@unitru.edu.pe', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(126, 113, b'0', NULL, NULL, NULL, '0001', '0002', 360, 'VIMU1122', '18066726', 'VIGO MURGA EVERT ARTURO', '970006013', 'evigom@unitru.edu.pe', '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(127, 114, b'1', NULL, NULL, NULL, '0003', '0002', 1514, 'VISÁ6580', '18071079', 'VILLANUEVA SÁNCHEZ GROVER EDUARDO', '949288758', 'gvillanuevas@unitru.edu.pe', '0001', 1021, '2023-11-13 13:51:49', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(128, 115, b'1', NULL, NULL, NULL, '0001', '0002', 2534, 'HUVI4007', '16796773', 'HURTADO VILLANUEVA ABELARDO', '950006983', 'ahurtadov@unitru.edu.pe', '0001', 1021, '2023-11-13 13:52:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(129, 116, b'1', NULL, NULL, NULL, '0003', '0003', 376, 'OBSO6708', '00000000', 'OBESSO SOLIS EYFIM SONNY ', '', 'eobesso@unitru.edu.pe', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(130, 117, b'1', NULL, NULL, NULL, '0001', '0003', 147, 'ROGO1864', '9325223', 'ROMERO GOICOCHEA CECILIA VICTORIA', '995960400', 'cromerog@unitru.edu.pe', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(131, 118, b'1', NULL, NULL, NULL, '0002', '0003', 377, 'GARU1829', '00000000', 'GARCÍA RUPAYA CARMEN ROSA', '', 'crgarcia@unitru.edu.pe', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL),
(132, 119, b'1', NULL, NULL, NULL, '0001', '0003', 150, 'RICA3044', '07622440', 'RIOS CARO TERESA ETELVINA', '996967602', 'trios@unitru.edu.pe', '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(133, 119, b'0', NULL, NULL, NULL, '0001', '0002', 151, 'AGAG2658', '18217212', 'AGUIRRE AGUILAR ANTONIO ARMANDO', '949563835', 'aaguirrea@unitru.edu.pe', '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(134, 120, b'1', NULL, NULL, NULL, '0001', '0002', 6804, 'ESWO2763', '06975953', 'ESPINOZA WONG CESAR AUGUSTO', '955309408', 'cesarespinozawongmd@gmail.com', '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(135, 121, b'1', NULL, NULL, NULL, '0001', '0002', 134, 'ALCA6813', '17880794', 'ALVARADO CACERES VICTOR MANUEL', '949933999', 'valvarado@unitru.edu.pe', '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(136, 122, b'1', NULL, NULL, NULL, '0001', '0002', 402, 'RÍCA8901', '18037609', 'RÍOS CARO MARCO CESAR', '949675132', 'rioscaromc@hotmail.com', '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 123, b'1', NULL, NULL, NULL, '0001', '0001', 140, 'JASA8594', '00000000', 'JARAMILLO SAAVEDRA ALICIA ANGELICA', '949432000', 'ajaramillos@unitru.edu.pe', '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(138, 124, b'1', NULL, NULL, NULL, '0001', '0001', 6804, 'ESWO2763', '06975953', 'ESPINOZA WONG CESAR AUGUSTO', '955309408', 'cesarespinozawongmd@gmail.com', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(139, 125, b'1', NULL, NULL, NULL, '0001', '0001', 136, 'PLAL5231', '26696405', 'PLASENCIA ALVAREZ JORGE OMAR', '920681169', 'jplasencia@unitru.edu.pe', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(140, 126, b'1', NULL, NULL, NULL, '0001', '0001', 400, 'ARFA7773', '17895424', 'ARMAS FAVA LOURDES ADELAIDA', '', 'larmasf@unitru.edu.pe', '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(141, 127, b'1', NULL, NULL, NULL, '0001', '0001', 7007, 'OLBA5490', '00000000', 'OLIVEIRA BARDALES GISELA', '', '', '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(142, 128, b'1', NULL, NULL, NULL, '0001', '0002', 6818, 'ASAL2695', '17813682', 'ASMAT ALVA ALBERTO RAMIRO', '', 'aasmat@unitru.edu.pe', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(143, 129, b'1', NULL, NULL, NULL, '0001', '0001', 198, 'MUDI8390', '17824838', 'MUÑOZ DIAZ LUIS ALBERTO', '', 'lmudiaz@unitru.edu.pe', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(144, 130, b'1', NULL, NULL, NULL, '0003', '0001', 5645, 'QUMA3677', '18120181', 'QUIÑONES  MARTINEZ PAÚL ALEXANDER ', '', 'pquinones@unitru.edu.pe', '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(145, 131, b'1', NULL, NULL, NULL, '0003', '0001', 5644, 'LILI5228', '07616498', 'LIY LION ROGER DANIEL', '994113338', 'rlion@unitru.edu.pe', '0001', 1021, '2023-11-14 13:06:30', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(146, 132, b'1', NULL, NULL, NULL, '0001', '0002', 6804, 'ESWO2763', '06975953', 'ESPINOZA WONG CESAR AUGUSTO', '955309408', 'cesarespinozawongmd@gmail.com', '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(147, 133, b'1', NULL, NULL, NULL, '0001', '0003', 139, 'LUFA1069', '17921306', 'LUNA FARRO MARIA ELENA', '949674217', 'mlunaf@unitru.edu.pe', '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(148, 134, b'1', NULL, NULL, NULL, '0001', '0002', 143, 'MAVA4195', '08015620', 'MAGUIÑA VARGAS CIRO PEREGRINO', '994699439', 'ciro.maguina@upch.pe', '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(149, 134, b'0', NULL, NULL, NULL, '0001', '0003', 7008, 'LENA3508', '00000000', 'LEYVA NATALY NATALY', '', '', '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(150, 135, b'1', NULL, NULL, NULL, '0001', '0001', 392, 'POCA2192', '18099999', 'POLO CAMPOS FREDY HERNÁN', '996960865', 'fpolo@unitru.edu.pe', '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(151, 136, b'1', NULL, NULL, NULL, '0001', '0003', 210, 'MOCO4851', '19082740', 'MONTOYA COLMENARES PATRICIA CLEMENTINA', '', 'pmontoya@unitru.edu.pe', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(152, 137, b'1', NULL, NULL, NULL, '0001', '0002', 205, 'PATE8908', '18198856', 'PAREDES TEJADA RAFAEL EDUARDO', '933553942', 'rparedes@unitru.edu.pe', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(153, 138, b'1', NULL, NULL, NULL, '0001', '0001', 194, 'URCU7155', '17800268', 'URQUIZO CUELLAR JUAN ISMAEL', '', 'jurquizo@unitru.edu.pe', '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(154, 139, b'1', NULL, NULL, NULL, '0001', '0002', 6804, 'ESWO2763', '06975953', 'ESPINOZA WONG CESAR AUGUSTO', '955309408', 'cesarespinozawongmd@gmail.com', '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(155, 140, b'1', NULL, NULL, NULL, '0001', '0003', 1487, 'LLSÁ7908', '17907759', 'LLAQUE SÁNCHEZ MARÍA ROCÍO DEL PILAR', '949421085', 'rociollaque1@gmail.com', '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 141, b'1', NULL, NULL, NULL, '0001', '0003', 3605, 'MEDE2232', '18182946', 'MEJIA DELGADO ELVA MANUELA', '984319291', 'emejia@unitru.edu.pe', '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(157, 142, b'1', NULL, NULL, NULL, '0001', '0003', 381, 'EVMO2160', '40171086', 'EVANGELISTA MONTOYA FLOR DE MARÍA', '948687115', 'fevangelistam@unitru.edu.pe', '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 143, b'1', NULL, NULL, NULL, '0001', '0002', 305, 'CAUR9471', '17869141', 'CANO URBINA EDUARDO ANDRES', '954005710', 'ecano@unitru.edu.pe', '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(159, 144, b'1', NULL, NULL, NULL, '0001', '0002', 187, 'MORE6454', '17846188', 'MONCADA REYES VICTOR ESTUARDO', '947911656', 'vmoncada@unitru.edu.pe', '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(160, 145, b'1', NULL, NULL, NULL, '0001', '0002', 208, 'JAQU1063', '28604108', 'JAULIS QUISPE DAVID', '955651660', 'djaulis@unitru.edu.pe', '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(161, 146, b'1', NULL, NULL, NULL, '0002', '0001', 203, 'PAVE6232', '07823920', 'PANTIGOSO VELLOSO DA SILVEIRA FRANCISCO MANUEL', '', 'fpantigosov@unitru.edu.pe', '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(162, 147, b'1', NULL, NULL, NULL, '0001', '0002', 232, 'RORO4668', '18141932', 'ROEDER ROSALES FRANCISCO JOSE', '977126414', 'froeder@unitru.edu.pe', '0001', 1021, '2023-11-14 13:40:16', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(163, 148, b'1', NULL, NULL, NULL, '0001', '0002', 6818, 'ASAL2695', '17813682', 'ASMAT ALVA ALBERTO RAMIRO', '', 'aasmat@unitru.edu.pe', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(164, 149, b'1', NULL, NULL, NULL, '0001', '0002', 190, 'CHCA1084', '17805660', 'CHOLAN CALDERON ANTONIO ', '', 'acholan@unitru.edu.pe', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(165, 150, b'1', NULL, NULL, NULL, '0001', '0001', 5645, 'QUMA3677', '18120181', 'QUIÑONES  MARTINEZ PAÚL ALEXANDER ', '', 'pquinones@unitru.edu.pe', '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(166, 151, b'1', NULL, NULL, NULL, '0001', '0001', 5644, 'LILI5228', '07616498', 'LIY LION ROGER DANIEL', '994113338', 'rlion@unitru.edu.pe', '0001', 1021, '2023-11-14 13:44:47', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(167, 152, b'1', NULL, NULL, NULL, '0001', '0001', 209, 'ADJI8284', '27715521', 'ADRIANZEN JIMENEZ ALEX EDMUNDO', '949204955', 'aadrianzen@unitru.edu.pe', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(168, 153, b'1', NULL, NULL, NULL, '0001', '0002', 3561, 'COVE4819', '18169063', 'CONCEPCION VELASQUEZ WINSTON ARMANDO', '949399311', 'wconcepcion@unitru.edu.pe', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(169, 154, b'1', NULL, NULL, NULL, '0003', '0001', 63, 'LOLE4907', '40534613', 'LOAYZA LEON NILO JAVIER', '949141886', 'nloayza@unitru.edu.pe', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(170, 155, b'1', NULL, NULL, NULL, '0001', '0003', 215, 'BAZU5515', '18075015', 'BAUTISTA ZÚÑIGA LILY DE LA CONCEPCIÓN', '955884970', 'lilybaunt@gmail.com', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(171, 156, b'1', NULL, NULL, NULL, '0001', '0001', 214, 'GOVE3024', '18025356', 'GORDILLO VEGA ANTONIO ELEODORO', '', 'agordillo@unitru.edu.pe', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(172, 157, b'1', NULL, NULL, NULL, '0001', '0002', 6820, 'AGCR2924', '18156142', 'AGUILAR CRUZ   GENARO ALFREDO', '', 'aguilargenaro6@hotmail.com', '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(173, 158, b'1', NULL, NULL, NULL, '0001', '0002', 4622, 'POCA9648', '17875429', 'POLO CAMPOS ANGEL FRANCISCO', '971314000', 'apolo@unitru.edu.pe', '0001', 1021, '2023-11-14 13:51:20', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(174, 159, b'1', NULL, NULL, NULL, '0001', '0001', 91, 'COAN9084', '00320489', 'COSTA ROSA ANDRADE SILVA ROSE MARY', '', 'mandrades@unitru.edu.pe', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(175, 160, b'1', NULL, NULL, NULL, '0001', '0001', 7009, 'DIPL1093', '00000000', 'DIAZ PLASENCIA JUAN ALBERTO', '', 'jdiazp@unitru.edu.pe', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(176, 161, b'1', NULL, NULL, NULL, '0001', '0001', 1510, 'TRAG7491', '17806296', 'TRESIERRA AGUILAR ALVARO EDMUNDO', '958606533', 'atresierra@unitru.edu.pe', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(177, 161, b'0', NULL, NULL, NULL, '0001', '0001', 1516, 'ROAL6078', '19082949', 'RODRIGUEZ ALONSO DANTE HORACIO', '947917732', 'drodriguezal@unitru.pe.edu', '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(178, 162, b'1', NULL, NULL, NULL, '0001', '0001', 2527, 'GRDU6279', '00000000', 'GRIMALDO DURAN JUAN HUMBERTO', '573132004801', 'jhgrimaldo@unitru.edu.pe', '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(179, 163, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(180, 164, b'1', NULL, NULL, NULL, '0001', '0001', 219, 'DEAL7179', '17848062', 'DEL ROSARIO ALFARO MANUEL JOSE', '', 'mdelrosario@unitru.edu.pe', '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(181, 165, b'1', NULL, NULL, NULL, '0001', '0001', 217, 'CACA9286', '17996364', 'CARRASCAL CABANILLAS JUAN CARLOS', '949907773', 'jcarrascal@unitru.edu.pe', '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(182, 166, b'1', NULL, NULL, NULL, '0001', '0001', 5651, 'HECO7559', '09958195', 'HERNANDEZ CONDORI CARLOS A.', '987958364', 'chernandezcondori@gmail.com', '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(183, 167, b'1', NULL, NULL, NULL, '0001', '0003', 91, 'COAN9084', '00320489', 'COSTA ROSA ANDRADE SILVA ROSE MARY', '', 'mandrades@unitru.edu.pe', '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(184, 168, b'1', NULL, NULL, NULL, '0001', '0001', 380, 'ANTR6062', '17815831', 'TRESIERRA AYALA MIGUEL ANGEL', '949494533', 'mtresierra@unitru.edu.pe', '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(185, 169, b'1', NULL, NULL, NULL, '0001', '0002', 2529, 'CAPA9782', '18115645', 'CABREJO PAREDES JOSÉ ELÍAS ', '949920203', 'jcabrejo@unitru.edu.pe', '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(186, 169, b'0', NULL, NULL, NULL, '0001', '0002', 1525, 'FECO2278', '18850419', 'FERNANDEZ COSAVALENTE HUGO EDUARDO', '949670356', 'hfernandez@unitru.edu.pe', '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(187, 170, b'1', NULL, NULL, NULL, '0001', '0002', 196, 'VEAG2871', '18074679', 'VENTURA AGUILAR HENRY ELDER', '', 'hventura@unitru.edu.pe', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(188, 171, b'1', NULL, NULL, NULL, '0001', '0002', 231, 'MAYA2229', '33335378', 'MARQUEZ YAURI HEYNER YULIANO', '949648748', 'hmarquez@unitru.edu.pe', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(189, 172, b'1', NULL, NULL, NULL, '0001', '0002', 233, 'HEFI3898', '17882388', 'HERBIAS FIGUEROA MARGOT ISABEL', '', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(190, 173, b'1', NULL, NULL, NULL, '0002', '0001', 235, 'ACIS1030', '40073043', 'ACEVEDO ISASI MANUEL ADOLFO', '992528363', 'manuel.acevedo@gmail.com', '0001', 1021, '2023-11-15 08:18:30', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(191, 174, b'1', NULL, NULL, NULL, '0001', '0002', 196, 'VEAG2871', '18074679', 'VENTURA AGUILAR HENRY ELDER', '', 'hventura@unitru.edu.pe', '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(192, 175, b'1', NULL, NULL, NULL, '0001', '0002', 406, 'BEGA7316', '19028062', 'BENITEZ GAMBOA JESUS SIGIFREDO', '992200826', 'jbenitezgamboa@gmail.com', '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(193, 176, b'1', NULL, NULL, NULL, '0001', '0001', 199, 'VAPO4688', '17807451', 'VASQUEZ POLO MIGUEL ABRAHAN', '', 'mvasquezp@unitru.edu.pe', '0001', 1021, '2023-11-15 08:23:57', '10.0.100.26', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL),
(194, 177, b'1', NULL, NULL, NULL, '0001', '0001', 7010, 'LAGO3481', '00000000', 'LAZO GONZALES ANGEL OSWALDO', '', '', '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(195, 178, b'1', NULL, NULL, NULL, '0001', '0001', 230, 'VITA2091', '17936558', 'VILCA TANTAPOMA MANUEL EDUARDO', '949495783', 'lalovilca1@gmail.com', '0001', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(196, 178, b'0', NULL, NULL, NULL, '0001', '0001', 476, 'MOLL8577', '17922799', 'MOSTACERO LLERENA SOLEDAD JANET', '96900941', 'smostacero@unitru.edu.pe', '0001', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(197, 179, b'1', NULL, NULL, NULL, '0001', '0001', 226, 'ROAR3451', '17959787', 'RODRIGUEZ ARMAS ANGELA FREMIOT', '', 'arodriguez@unitru.edu.pe', '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(198, 180, b'1', NULL, NULL, NULL, '0001', '0001', 5752, 'GRVA8996', '18206812', 'GRADOS  VASQUEZ MARTIN MANUEL', '', 'margradosvas@gmail.com', '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(199, 180, b'0', NULL, NULL, NULL, '0001', '0001', 5654, 'QUME8748', '17875462', 'QUISPE MENDOZA ROBERTO', '', 'rquispe@unitru.edu.pe', '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(200, 181, b'1', NULL, NULL, NULL, '0001', '0001', 226, 'ROAR3451', '17959787', 'RODRIGUEZ ARMAS ANGELA FREMIOT', '', 'arodriguez@unitru.edu.pe', '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(201, 182, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(202, 183, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 08:44:32', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(203, 184, b'1', NULL, NULL, NULL, '0001', '0001', 1497, 'COMO9715', '07277407', 'COURT MONTEVERDE EDUARDO JUAN', '', 'eduardocourtm@yahoo.es', '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(204, 185, b'1', NULL, NULL, NULL, '0001', '0001', 2528, 'CAÑA3990', '18859301', 'CABANILLAS ÑAÑO SARA ISABEL', '923526878', 'scabanillas@unitru.edu.pe', '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(205, 185, b'0', NULL, NULL, NULL, '0001', '0001', 318, 'SADA4348', '17897899', 'SALCEDO DAVALOS ROSA AMABLE', '', 'rsalcedod@unitru.edu.pe', '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(206, 186, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 08:51:04', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(207, 187, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(208, 188, b'1', NULL, NULL, NULL, '0004', '0001', 1497, 'COMO9715', '07277407', 'COURT MONTEVERDE EDUARDO JUAN', '', 'eduardocourtm@yahoo.es', '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(209, 189, b'1', NULL, NULL, NULL, '0004', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(210, 190, b'1', NULL, NULL, NULL, '0001', '0002', 255, 'LOCA6652', '17805579', 'LOYOLA CARRANZA WILBER ALAMIRO', '954704856', 'wloyola@unitru.edu.pe', '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `carga_horaria_curso_grupo_docente` (`cgd_id`, `ccg_id`, `cgd_titular`, `cgd_horas`, `cgd_fecha_inicio`, `cgd_fecha_fin`, `doc_condicion`, `doc_grado`, `doc_id`, `doc_codigo`, `doc_documento`, `doc_nombres`, `doc_celular`, `doc_email`, `cgd_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(211, 191, b'1', NULL, NULL, NULL, '0001', '0002', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(212, 192, b'1', NULL, NULL, NULL, '0001', '0001', 247, 'RUBE5828', '17843343', 'RUIZ BENITES SEGUNDO DOMINGO', '', 'sruiz@unitru.edu.pe', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(213, 193, b'1', NULL, NULL, NULL, '0001', '0002', 250, 'ESPE8403', '18057109', 'ESQUERRE PEREYRA PAUL HENRY', '958047214', 'pesquerre@unitru.edu.pe', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(214, 194, b'1', NULL, NULL, NULL, '0001', '0002', 249, 'EVBE1409', '17811823', 'EVANGELISTA BENITES GUILLERMO DAVID', '', 'gevangelista@unitru.edu.pe', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(215, 195, b'1', NULL, NULL, NULL, '0001', '0002', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(216, 196, b'1', NULL, NULL, NULL, '0001', '0002', 120, 'CAAL7645', '19096122', 'CABALLERO ALAYO CARLOS OSWALDO', '', 'ccaballero@unitru.edu.pe', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(217, 197, b'1', NULL, NULL, NULL, '0001', '0002', 105, 'GOPA1031', '46303852', 'GONZALES PACHECO ANTHONY JOEL', '989926225', 'agonzalesp@unitru.edu.pe', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL),
(218, 198, b'1', NULL, NULL, NULL, '0001', '0002', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL),
(219, 199, b'1', NULL, NULL, NULL, '0001', '0001', 253, 'AGRO3313', '18113588', 'AGUILAR ROJAS PERCY DANILO', '926535184', 'paguilarr@unitru.edu.pe', '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(220, 200, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(221, 201, b'1', NULL, NULL, NULL, '0001', '0002', 7011, 'GÁMO1581', '18146378', 'GÁLVEZ MONCADA OSCAR ESTEBAN', '', 'ogalvez@unitru.edu.pe', '0001', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(222, 202, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:15:10', '10.0.100.79', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL),
(223, 203, b'1', NULL, NULL, NULL, '0001', '0003', 5842, 'DIDI2252', ' 17884976', 'DIAZ  DIAZ FLOR DEL ROSARIO', '', 'fdiazd@unitru.edu.pe', '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(224, 204, b'1', NULL, NULL, NULL, '0001', '0001', 107, 'BORO4259', '18834971', 'BOCANEGRA RODRIGUEZ DE CASTRO MARIA DEL PILAR', '', 'mbocanegra@unitru.edu.pe', '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(225, 205, b'1', NULL, NULL, NULL, '0004', '0003', 456, 'MOSÁ6665', '00000000', 'MOQUILLAZA SÁNCHEZ JANINA MIRTHA GLADYS', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(226, 206, b'1', NULL, NULL, NULL, '0004', '0003', 1488, 'VAAL3152', '42289748', 'VASQUEZ ALBURQUEQUE IRIS LILIANA', '969405405', 'ialburqueque@unitru.edu.pe', '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(227, 207, b'1', NULL, NULL, NULL, '0004', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:25', '10.0.100.79', NULL, NULL, NULL),
(228, 208, b'1', NULL, NULL, NULL, '0001', '0002', 5691, 'PEAM2953', ' 32881747', 'PELAEZ AMADO JOSÉ WUALTER', '', 'jpelaez@unitru.edu.pe', '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(229, 209, b'1', NULL, NULL, NULL, '0001', '0002', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(230, 210, b'1', NULL, NULL, NULL, '0001', '0003', 1483, 'VAMO7821', '17919999', 'VASQUEZ MONDRAGON CECILIA DEL PILAR', '', 'cvasquezm@unitru.edu.pe', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(231, 211, b'1', NULL, NULL, NULL, '0001', '0003', 98, 'VACO9990', '17869961', 'VASQUEZ CORREA EDITH LORELEY', '949901920', 'LVASQUEZ@UNITRU.EDU.PE', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(232, 212, b'1', NULL, NULL, NULL, '0003', '0002', 458, 'ARLU1029', '10472445', 'AREVALO LUNA EDMUNDO EUGENIO', '968752783', 'earevalol@unitru.edu.pe', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(233, 213, b'1', NULL, NULL, NULL, '0003', '0002', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(234, 214, b'1', NULL, NULL, NULL, '0001', '0002', 459, 'BACÓ4362', '18196602', 'BAUTISTA CÓNDOR JOSE LEONCIO', '', 'jbautista@unitru.edu.pe', '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(235, 215, b'1', NULL, NULL, NULL, '0001', '0003', 460, 'SIME2027', '42238047', 'SILVA MERCADO YANETH YACKELINE', '920247853', 'ysilva@unitru.edu.pe', '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(236, 216, b'1', NULL, NULL, NULL, '0001', '0002', 7012, 'UGCA8538', '17857572', 'UGAZ CAYAO SIMEÓN IGNACIO', '', 'iugaz@unitru.edu.pe', '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(237, 217, b'1', NULL, NULL, NULL, '0001', '0001', 97, 'BUGO1586', '17861724', 'BURGOS GOICOCHEA SABY ', '', 'sburgos@unitru.edu.pe', '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(238, 218, b'1', NULL, NULL, NULL, '0001', '0001', 2537, 'MOTO4191', '70447778', 'MONCADA TORRES  LUIS DAVID ', '947735960', 'lmoncadat@unitru.edu.pe', '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(239, 219, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(240, 220, b'1', NULL, NULL, NULL, '0001', '0001', 110, 'HEME1699', '18080075', 'HERRERA MEJIA ZORAN EVARISTO', '999395469', 'zherrera@unitru.edu.pe', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(241, 221, b'1', NULL, NULL, NULL, '0001', '0001', 5690, 'CAAL3642', '45562669', 'CARRANZA ALVARADO JOSÉ ELÍAS', '', 'jecarranzaa@unitru.edu.pe', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(242, 222, b'1', NULL, NULL, NULL, '0001', '0003', 463, 'MINA8119', '40051394', 'MIRANDA NARVAEZ SHIRLEY DESIREE', '', 'shmiranda@unitru.edu.pe', '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(243, 223, b'1', NULL, NULL, NULL, '0001', '0001', 119, 'GOLO4752', '17941433', 'GONZALEZ LOPEZ ELMER', '', 'egonzalez@unitru.edu.pe', '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(244, 224, b'1', NULL, NULL, NULL, '0001', '0001', 115, 'GASA7829', '40287812', 'GARCIA SALIRROSAS LIZ MARIBEL', '', 'lgarcias@unitru.edu.pe', '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(245, 225, b'1', NULL, NULL, NULL, '0001', '0001', 127, 'BASI5124', '18132936', 'BAZAN SILVA VICTOR HUGO', '', 'vbazan@unitru.edu.pe', '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL),
(246, 226, b'1', NULL, NULL, NULL, '0001', '0002', 465, 'DIAR7388', '18010989', 'DIAZ ARIAS ALFIERI', '', 'aldiaz@unitru.edu.pe', '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(247, 227, b'1', NULL, NULL, NULL, '0001', '0002', 1511, 'UCDU5025', '17921294', 'UCEDA DUCLOS SANTIAGO ALBERTO', '977486652', 'suceda@unitru.edu.pe', '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(248, 228, b'1', NULL, NULL, NULL, '0001', '0003', 479, 'GUES2565', '17816793', 'GUERRERO ESPINO LUZ MARINA', '949594806', 'lguerrero@unitru.edu.pe', '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(249, 229, b'1', NULL, NULL, NULL, '0001', '0003', 1489, 'MEGÓ9850', '19032278', 'MEREGILDO GÓMEZ MAGNA RUTH', '964855512', 'rmeregildo@unitru.edu.pe', '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(250, 229, b'0', NULL, NULL, NULL, '0004', '0003', 1515, 'GANA6481', '00000000', 'GARCIA NAVARRO XIOMARA', '58073851', 'xgarcian@unitru.edu.pe', '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(251, 230, b'1', NULL, NULL, NULL, '0001', '0003', 5731, 'ORTA9156', ' 17837284', 'ORTIZ TAVARA TERESA MARILU', '949904022', 'tortiz@unitru.edu.pe', '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(252, 231, b'1', NULL, NULL, NULL, '0001', '0001', 124, 'ARCA1071', '10268692', 'ARMAS CASTAÑEDA SEGUNDO ', '', 'armasca@unitru.edu.pe', '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(253, 232, b'1', NULL, NULL, NULL, '0001', '0001', 7, 'LUES1051', '18149321', 'LUJAN ESPINOZA GLADYS MARGARITA', '942730776', 'glujan@unitru.edu.pe', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(254, 233, b'1', NULL, NULL, NULL, '0002', '0001', 2, 'PORI5035', '16769683', 'PORRO RIVADENEIRA MANUEL FRANCISCO', '965860500', 'mfpr76@gmail.com', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(255, 234, b'1', NULL, NULL, NULL, '0002', '0001', 3, 'SACO5095', '41216213', 'SÁNCHEZ CORONADO CARLOS ALBERTO', '978403131', 'casanchezc@unitru.edu.pe', '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(256, 235, b'1', NULL, NULL, NULL, '0001', '0001', 4, 'NIPE2273', '18196993', 'NIEVES PEÑA PAMELA ', '949780508', 'pnieves@unitru.edu.pe', '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(257, 236, b'1', NULL, NULL, NULL, '0001', '0002', 15, 'AGBA3680', '40985081', 'AGUIRRE BAZAN LUIS ALBERTO', '', 'laguirreb@unitru.edu.pe', '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(258, 237, b'1', NULL, NULL, NULL, '0001', '0002', 11, 'PICH4320', '17863707', 'PISFIL CHAVESTA EULOGIO ', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(259, 238, b'1', NULL, NULL, NULL, '0001', '0003', 13, 'AGVE5870', '18202511', 'AGUILAR VENTURA LEYLI JENY', '969609766', 'laguilarv@unitru.edu.pe', '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(260, 239, b'1', NULL, NULL, NULL, '0001', '0003', 20, 'DICA9396', '42845936', 'DIAZ CABRERA MELISSA FIORELLA', '', 'mdiazc@unitru.edu.pe', '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(261, 240, b'1', NULL, NULL, NULL, '0001', '0002', 17, 'ROAL2227', '18076079', 'RODRIGUEZ ALBAN SEGUNDO MIGUEL', '949674913', 'srodriguezal@unitru.edu.pe', '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(262, 241, b'1', NULL, NULL, NULL, '0001', '0002', 27, 'CUZA8901', '17832845', 'CUEVA ZAVALETA JORGE LUIS', '949741055', 'jcueva@unitru.edu.pe', '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(263, 242, b'1', NULL, NULL, NULL, '0001', '0002', 413, 'ALHE8383', '18099065', 'ALDAVE HERRERA RAFAEL FERNANDO', '948501141', 'faldave@unitru.edu.pe', '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(264, 243, b'1', NULL, NULL, NULL, '0001', '0001', 417, 'VAPO9574', '17838104', 'PONCE MALAVER MOISÉS VALDEMAR', '', 'drponcemalaver@gmail.com', '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(265, 244, b'1', NULL, NULL, NULL, '0003', '0002', 33, 'RUYZ3586', '32827926', 'RUBIÑOS YZAGUIRRE HERMES', '949907240', 'ruminahui3579@gmail.com', '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(266, 245, b'1', NULL, NULL, NULL, '0001', '0001', 39, 'RERO1075', '18120596', 'REYES RODRIGUEZ JOSÉ RAYMUNDO', '949997822', 'jreyesr@unitru.edu.pe', '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(267, 246, b'1', NULL, NULL, NULL, '0002', '0002', 40, 'BUZA8266', '17934799', 'BURGOS ZAVALETA JOSÉ MARTÍN', '945150001', 'jmartinburgos@gmail.com', '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(268, 247, b'1', NULL, NULL, NULL, '0003', '0002', 38, 'JOBR5495', '17873937', 'JONDEC BRIONES HOMERO PRACEDES', '949622379', 'hjondecb@hotmail.com', '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(269, 248, b'1', NULL, NULL, NULL, '0001', '0002', 5768, 'SACR9395', '17929684', 'SANTOS CRUZ TEODULO JENARO', '', 'tsantos@unitru.edu.pe', '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(270, 249, b'1', NULL, NULL, NULL, '0001', '0002', 407, 'CEAR4140', '17864056', 'CELI AREVALO MARCO ALFONSO', '989757723', 'mceli@unitru.edu.pe', '0001', 1021, '2023-11-16 12:18:54', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(271, 250, b'1', NULL, NULL, NULL, '0001', '0003', 1, 'NEAL8474', '17903337', 'NEYRA ALVARADO CARMEN OLINDA', '996869108', 'cneyra@unitru.edu.pe', '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(272, 250, b'0', NULL, NULL, NULL, '0002', '0003', 1517, 'GOGU1420', '18168973', 'GOMEZ GUEVARA AMALIA MAGDALENA', '941150103', 'amaliagomezguevara@hotmail.com', '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(273, 251, b'1', NULL, NULL, NULL, '0003', '0002', 25, 'VAYS6720', '42191585', 'VARGAS YSLA ROGER RENATO', '955845087', 'renato_vargas_ysla@hotmail.com', '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(274, 252, b'1', NULL, NULL, NULL, '0003', '0001', 415, 'HUHU4768', '17910976', 'GUAYAN HUACCHA LEA', '955761696', 'lhuayanh@unitru.edu.pe', '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(275, 253, b'1', NULL, NULL, NULL, '0003', '0002', 7014, 'ALRE8009', '16436848', 'ALARCON REQUEJO GILMER', '947450909', 'agilmer@hotmail.com', '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(276, 254, b'1', NULL, NULL, NULL, '0003', '0001', 7015, 'ESCA1257', '18182673', 'ESPINOLA CARRILLO CÉSAR GUSTAVO', '949913070', 'cguesea@gmail.com', '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(277, 255, b'1', NULL, NULL, NULL, '0003', '0001', 7016, 'LOFL6343', '18206857', 'LOYOLA FLORIAN MANUEL FEDERICO', '936536191', 'loyola_manuel@yahoo.es', '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(278, 248, b'0', NULL, NULL, NULL, '0003', '0002', 7017, 'BAAZ6492', '17914391', 'BALTODANO AZABACHE VICTOR HIPOLITO', '949928014', 'uvbaltodano@unitru.edu.pe', '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(279, 256, b'1', NULL, NULL, NULL, '0001', '0002', 7018, 'VABO5152', '17938864', 'VASQUEZ BOYER CARLOS ALBERTO', '949674400', 'cvasquezb@unitru.edu.pe', '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(280, 257, b'1', NULL, NULL, NULL, '0001', '0001', 1499, 'DILE5391', '17821030', 'DIAZ LEIVA JOSE LEVI', '939339872', 'Jdiazl@unitru.edu.pe', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(281, 258, b'1', NULL, NULL, NULL, '0001', '0001', 81, 'NEOB7485', '17911612', 'NECIOSUP OBANDO JORGE EDUARDO', '956386878', 'jorgeneciosup@gmail.com', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(282, 259, b'1', NULL, NULL, NULL, '0001', '0001', 1482, 'IPCE1421', '18012316', 'IPANAQUE CENTENO ENRIQUE', '949858528', 'EIPANAQUE@UNITRU.EDU.PE', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(283, 260, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(284, 261, b'1', NULL, NULL, NULL, '0001', '0001', 246, 'MIME6882', '17873625', 'MINCHON MEDINA CARLOS ALBERTO', '950002310', 'cminchon@unitru.edu.pe', '0001', 1021, '2023-11-17 10:02:22', '10.0.100.79', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL),
(285, 262, b'1', NULL, NULL, NULL, '0001', '0001', 0, 'ZZZZ9999', '99999999', 'ASESORADO', '999999999', 'sn@unitru.edu.pe', '0001', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(286, 263, b'1', NULL, NULL, NULL, '0001', '0002', 7019, 'CATO2837', '00000000', 'CACHAY TORRES ROBERTH', '', 'rcachay@unitru.edu.pe', '0001', 1021, '2023-11-17 10:06:38', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(287, 264, b'1', NULL, NULL, NULL, '0001', '0002', 455, 'ROLÓ5814', '32919145', 'ROLDAN LOPEZ JOSE ANGEL', '948307263', 'jroldanl@yahoo.es', '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(288, 265, b'1', NULL, NULL, NULL, '0001', '0002', 240, 'ROBE6083', '44095020', 'RODRIGUEZ BENITES CARLOS EDGARDO', '', 'cerodriguez@unitru.edu.pe', '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(289, 266, b'1', NULL, NULL, NULL, '0001', '0001', 1496, 'RULO4922', '19027387', 'RUBIO LOPEZ FRANCO MODESTO', '949623266', 'frubio@unitru.edu.pe', '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(290, 267, b'1', NULL, NULL, NULL, '0001', '0001', 1498, 'DEAR9207', '42154250', 'DE LA CRUZ ARAUJO RONAL', '992452521', 'ronal.delacruz@unat.edu.pe', '0001', 1021, '2023-11-17 10:49:08', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(291, 268, b'1', NULL, NULL, NULL, '0001', '0001', 7020, 'AVRO4080', '42166366', 'AVALOS RODRIGUEZ JESUS PASCUAL', '', 'javalos@unitru.edu.pe', '0001', 1021, '2023-11-17 10:49:08', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(292, 269, b'1', NULL, NULL, NULL, '0001', '0001', 3579, 'JARO9096', '18062800', 'JAUREGUI ROSAS SEGUNDO ROSALI', '', 'sjauregui@unitru.edu.pe', '0001', 1021, '2023-11-17 10:51:06', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso_grupo_fecha`
--

DROP TABLE IF EXISTS `carga_horaria_curso_grupo_fecha`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso_grupo_fecha` (
  `cgf_id` int(11) NOT NULL AUTO_INCREMENT,
  `ccg_id` int(11) NOT NULL,
  `cgf_fecha` date DEFAULT NULL,
  `cgf_hora_inicio` int(11) DEFAULT NULL,
  `cgf_hora_fin` int(11) DEFAULT NULL,
  `cgf_horas` decimal(10,2) DEFAULT NULL,
  `cgf_estado` varchar(4) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgf_id`),
  KEY `ccg_id` (`ccg_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1064 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_curso_grupo_fecha`
--

INSERT INTO `carga_horaria_curso_grupo_fecha` (`cgf_id`, `ccg_id`, `cgf_fecha`, `cgf_hora_inicio`, `cgf_hora_fin`, `cgf_horas`, `cgf_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, '2023-10-28', NULL, NULL, NULL, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, '2023-10-29', NULL, NULL, NULL, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, '2023-11-04', NULL, NULL, NULL, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, '2023-11-05', NULL, NULL, NULL, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 1, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 2, '2023-11-11', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(8, 2, '2023-11-12', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(9, 2, '2023-11-18', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(10, 2, '2023-11-19', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(11, 2, '2023-11-25', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(12, 2, '2023-11-26', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(13, 2, '2023-12-02', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(14, 2, '2023-12-03', NULL, NULL, NULL, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
(15, 3, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 3, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 4, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 4, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 5, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:35:13', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 6, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:38:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 7, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 7, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(23, 8, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 9, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 11:55:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 10, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:08:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 11, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 12, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:20:08', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 13, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:23:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 14, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:23:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 15, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 16, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-10 12:29:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 17, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 17, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 18, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 19, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:25:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 20, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:26:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 21, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(38, 21, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 22, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 23, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:29:24', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 24, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:32:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(42, 25, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(43, 26, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 27, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(45, 28, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 29, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 30, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:38:55', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(48, 31, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:44:07', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(49, 32, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 09:45:22', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 33, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 34, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 35, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 35, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:27:42', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 36, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:29:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(55, 36, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:29:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 37, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(57, 38, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 38, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 39, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:33:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 40, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:36:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 40, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 10:36:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 41, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(63, 42, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:11:24', '10.0.100.98', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL),
(64, 43, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 43, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 44, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 44, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 45, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:15:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 46, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 47, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:17:47', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 48, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 49, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 50, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:20:50', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(74, 51, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:22:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 52, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 52, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 52, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 52, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 52, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 52, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 53, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 53, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 53, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 53, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(85, 53, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 53, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 54, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 54, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 54, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 54, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 54, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 54, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 54, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 54, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:27:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 55, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 55, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 55, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 55, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 55, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 55, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 55, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 55, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:28:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(103, 56, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 56, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 56, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 56, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 56, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 56, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 57, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 57, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 57, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 57, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 57, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 57, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(115, 58, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(116, 58, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(117, 58, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(118, 58, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(119, 58, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(120, 58, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(121, 58, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(122, 58, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:32:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 59, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(124, 59, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(125, 59, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(126, 59, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(127, 59, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(128, 59, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(129, 59, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(130, 59, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:33:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(131, 60, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(132, 60, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(133, 60, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(134, 60, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(135, 60, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(136, 60, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 61, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(138, 61, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(139, 61, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(140, 61, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(141, 61, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(142, 61, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(143, 62, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(144, 62, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(145, 62, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(146, 62, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(147, 62, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(148, 62, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(149, 62, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(150, 62, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:39:27', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(151, 63, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(152, 63, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(153, 63, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(154, 63, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(155, 63, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 63, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(157, 63, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 63, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:40:29', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(159, 64, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(160, 64, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(161, 64, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(162, 64, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(163, 64, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(164, 64, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(165, 64, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(166, 64, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:41:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(167, 65, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(168, 65, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(169, 65, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(170, 65, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(171, 65, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(172, 65, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(173, 65, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(174, 65, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(175, 66, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(176, 66, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(177, 66, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(178, 66, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(179, 66, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(180, 66, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(181, 67, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(182, 67, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(183, 67, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(184, 67, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(185, 67, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(186, 67, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:45:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(187, 68, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(188, 68, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(189, 68, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(190, 68, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(191, 68, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(192, 68, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:47:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(193, 69, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(194, 69, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(195, 69, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(196, 69, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(197, 69, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(198, 69, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(199, 70, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(200, 70, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(201, 70, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(202, 70, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(203, 70, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(204, 70, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(205, 71, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(206, 71, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(207, 71, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(208, 71, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(209, 71, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(210, 71, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(211, 71, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(212, 71, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(213, 71, '2024-03-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(214, 71, '2024-03-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(215, 71, '2024-03-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(216, 71, '2024-03-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(217, 71, '2024-03-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(218, 71, '2024-03-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(219, 71, '2024-03-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(220, 71, '2024-03-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:57:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(221, 72, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(222, 72, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(223, 72, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(224, 72, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(225, 72, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(226, 72, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 11:58:32', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(227, 73, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(228, 73, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(229, 73, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(230, 73, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(231, 73, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(232, 73, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(233, 73, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(234, 73, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(235, 74, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(236, 74, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(237, 74, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(238, 74, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(239, 74, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(240, 74, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:02:54', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(241, 75, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(242, 75, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(243, 75, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(244, 75, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(245, 75, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(246, 75, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(247, 75, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(248, 75, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:04:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(249, 76, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(250, 76, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(251, 76, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(252, 76, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(253, 76, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(254, 76, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(255, 76, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(256, 76, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:39', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(257, 77, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(258, 77, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(259, 77, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(260, 77, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(261, 77, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(262, 77, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(263, 78, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(264, 78, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(265, 78, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(266, 78, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(267, 78, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(268, 78, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:07:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(269, 79, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(270, 79, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(271, 79, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(272, 79, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(273, 79, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(274, 79, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(275, 79, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(276, 79, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:09:12', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(277, 80, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(278, 80, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(279, 80, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(280, 80, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(281, 80, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(282, 80, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(283, 81, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(284, 81, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(285, 81, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(286, 81, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(287, 81, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(288, 81, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(289, 82, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(290, 82, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(291, 82, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(292, 82, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(293, 82, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(294, 82, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(295, 82, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(296, 82, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(297, 82, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(298, 82, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(299, 82, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(300, 82, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(301, 82, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(302, 82, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(303, 82, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(304, 82, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:12:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(305, 83, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:14:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(306, 83, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:14:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(307, 83, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:14:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(308, 83, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:14:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(309, 83, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:14:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(310, 83, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:14:18', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(311, 84, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(312, 84, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(313, 84, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(314, 84, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(315, 84, '2023-12-23', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(316, 84, '2023-12-30', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:20:31', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(317, 85, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(318, 85, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(319, 85, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(320, 85, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(321, 85, '2024-03-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(322, 85, '2024-03-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(323, 86, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(324, 86, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(325, 86, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(326, 86, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(327, 86, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(328, 86, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(329, 87, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(330, 87, '2023-11-12', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(331, 87, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(332, 87, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(333, 87, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(334, 87, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:23:52', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(335, 88, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:25:43', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(336, 89, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(337, 89, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(338, 89, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(339, 89, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(340, 89, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(341, 89, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(342, 89, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(343, 89, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:27:37', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(344, 90, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:29:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(345, 91, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(346, 91, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(347, 91, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(348, 91, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(349, 91, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(350, 91, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(351, 91, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(352, 91, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:35:01', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(353, 92, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(354, 92, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(355, 92, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(356, 92, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(357, 92, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(358, 92, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:42:26', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(359, 93, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(360, 93, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(361, 93, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(362, 93, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(363, 93, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(364, 93, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(365, 94, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(366, 94, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(367, 94, '2024-03-02', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(368, 94, '2024-03-03', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(369, 94, '2024-03-09', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(370, 94, '2024-03-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:52:40', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(371, 95, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(372, 95, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(373, 95, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(374, 95, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(375, 95, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(376, 95, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:54:05', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(377, 96, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(378, 96, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(379, 96, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(380, 96, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(381, 96, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(382, 96, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:55:30', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(383, 97, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `carga_horaria_curso_grupo_fecha` (`cgf_id`, `ccg_id`, `cgf_fecha`, `cgf_hora_inicio`, `cgf_hora_fin`, `cgf_horas`, `cgf_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(384, 97, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(385, 97, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(386, 97, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(387, 97, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(388, 97, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(389, 97, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(390, 97, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:56:28', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(391, 98, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 12:59:00', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(392, 99, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(393, 100, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(394, 101, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:03:45', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(395, 102, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:04:52', '10.0.100.98', 1021, '2023-11-13 13:44:52', '10.0.100.98', NULL, NULL, NULL),
(396, 103, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(397, 104, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:08:58', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(398, 105, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:08:59', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(399, 106, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:10:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(400, 107, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(401, 108, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(402, 109, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:14:02', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(403, 110, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:38:17', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(404, 111, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(405, 112, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(406, 113, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:50:44', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(407, 114, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:51:49', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(408, 115, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:52:36', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(409, 116, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(410, 117, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL),
(411, 118, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL),
(412, 119, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL),
(413, 120, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(414, 120, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(415, 120, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(416, 120, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(417, 120, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(418, 120, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(419, 120, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(420, 120, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:27', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(421, 121, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(422, 121, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(423, 121, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(424, 121, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(425, 121, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(426, 121, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(427, 122, '2024-02-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(428, 122, '2024-02-04', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(429, 122, '2024-02-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(430, 122, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(431, 122, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(432, 122, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:45:28', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(433, 123, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(434, 123, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(435, 123, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(436, 123, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(437, 123, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(438, 123, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(439, 123, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(440, 123, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:52:33', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(441, 124, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(442, 124, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(443, 124, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(444, 124, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(445, 124, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(446, 124, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(447, 124, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(448, 124, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(449, 125, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(450, 125, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(451, 125, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(452, 125, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(453, 125, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(454, 125, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(455, 126, '2024-02-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(456, 126, '2024-02-04', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(457, 126, '2024-02-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(458, 126, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(459, 126, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(460, 126, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 12:56:53', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(461, 127, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:43', '10.0.100.54', NULL, NULL, NULL),
(462, 127, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(463, 127, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(464, 127, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(465, 127, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(466, 127, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(467, 127, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(468, 127, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:02:10', '10.0.100.54', 1020, '2023-11-14 13:02:44', '10.0.100.54', NULL, NULL, NULL),
(469, 128, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(470, 129, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(471, 130, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:05:43', '10.0.100.34', 1021, '2023-11-14 13:06:45', '10.0.100.34', NULL, NULL, NULL),
(472, 131, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:06:30', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(473, 132, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(474, 132, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(475, 132, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(476, 132, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(477, 132, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(478, 132, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(479, 132, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:58', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(480, 132, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(481, 133, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(482, 133, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(483, 133, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(484, 133, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(485, 133, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(486, 133, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(487, 134, '2024-02-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(488, 134, '2024-02-04', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(489, 134, '2024-02-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(490, 134, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(491, 134, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(492, 134, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:08:59', '10.0.100.54', 1020, '2023-11-14 13:09:48', '10.0.100.54', NULL, NULL, NULL),
(493, 135, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(494, 135, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(495, 135, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(496, 135, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(497, 135, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(498, 135, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(499, 135, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(500, 135, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:10:58', '10.0.100.54', 1020, '2023-11-14 13:32:52', '10.0.100.54', NULL, NULL, NULL),
(501, 136, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(502, 137, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(503, 138, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:27:45', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(504, 139, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(505, 139, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(506, 139, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(507, 139, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(508, 139, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(509, 139, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(510, 139, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(511, 139, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(512, 140, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(513, 140, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(514, 140, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(515, 140, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(516, 140, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(517, 140, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:30', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(518, 141, '2024-02-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(519, 141, '2024-02-04', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(520, 141, '2024-02-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(521, 141, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(522, 141, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(523, 141, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:29:31', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(524, 142, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(525, 142, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(526, 142, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(527, 142, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(528, 142, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(529, 142, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(530, 142, '2024-01-27', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(531, 142, '2024-01-28', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:31:09', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(532, 143, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(533, 144, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:32:38', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(534, 145, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(535, 146, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:39:28', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(536, 116, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(537, 116, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(538, 116, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(539, 116, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(540, 116, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(541, 116, '2023-12-16', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(542, 116, '2023-12-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(543, 117, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(544, 117, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(545, 117, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(546, 117, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(547, 117, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:02', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(548, 118, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(549, 118, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(550, 118, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(551, 118, '2024-02-24', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(552, 118, '2024-02-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:03', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(553, 147, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:40:16', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(554, 119, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(555, 119, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(556, 119, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(557, 119, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(558, 119, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(559, 119, '2023-12-16', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(560, 119, '2023-12-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:40:32', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(561, 148, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(562, 149, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(563, 150, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:44:03', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(564, 151, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:44:47', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(565, 152, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(566, 153, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(567, 154, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(568, 155, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(569, 156, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(570, 157, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:50:21', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(571, 158, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:51:20', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(572, 159, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(573, 159, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(574, 159, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(575, 159, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(576, 159, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(577, 159, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(578, 160, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(579, 160, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(580, 160, '2023-12-16', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(581, 160, '2023-12-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(582, 160, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(583, 160, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(584, 161, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(585, 161, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(586, 161, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(587, 161, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(588, 161, '2024-01-27', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(589, 161, '2024-01-28', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(590, 161, '2024-02-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(591, 161, '2024-02-04', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(592, 161, '2024-02-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(593, 161, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(594, 161, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(595, 161, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(596, 161, '2024-02-24', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(597, 161, '2024-02-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(598, 161, '2024-03-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(599, 161, '2024-03-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:51:23', '10.0.100.54', 1020, '2023-11-14 13:51:56', '10.0.100.54', NULL, NULL, NULL),
(600, 162, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(601, 162, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(602, 162, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(603, 162, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(604, 162, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(605, 162, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(606, 163, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 13:56:24', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(607, 164, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(608, 165, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(609, 166, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-14 13:58:54', '10.0.100.34', NULL, NULL, NULL, NULL, NULL, NULL),
(610, 167, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(611, 167, '2023-11-19', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(612, 167, '2023-11-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:34', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(613, 167, '2023-11-26', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(614, 167, '2023-12-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(615, 167, '2023-12-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(616, 168, '2023-12-09', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(617, 168, '2023-12-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(618, 168, '2023-12-16', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(619, 168, '2023-12-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(620, 168, '2024-01-06', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(621, 168, '2024-01-07', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(622, 169, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(623, 169, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(624, 169, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(625, 169, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(626, 169, '2024-01-27', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(627, 169, '2024-01-28', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(628, 169, '2024-02-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(629, 169, '2024-02-04', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(630, 169, '2024-02-10', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(631, 169, '2024-02-11', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(632, 169, '2024-02-17', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(633, 169, '2024-02-18', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(634, 169, '2024-02-24', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(635, 169, '2024-02-25', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(636, 169, '2024-03-02', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(637, 169, '2024-03-03', NULL, NULL, NULL, '0001', 1020, '2023-11-14 14:00:35', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(638, 170, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(639, 171, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(640, 172, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:17:26', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(641, 173, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:18:30', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(642, 174, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(643, 175, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:20:47', '10.0.100.26', NULL, NULL, NULL, NULL, NULL, NULL),
(644, 176, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:23:57', '10.0.100.26', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL),
(645, 177, '2024-01-13', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(646, 177, '2024-01-14', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(647, 177, '2024-01-20', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(648, 177, '2024-01-21', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(649, 177, '2024-01-27', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(650, 177, '2024-01-28', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:31:04', '10.0.100.54', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL),
(651, 178, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:34:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(652, 179, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(653, 180, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:41:00', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(654, 181, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(655, 182, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:42:22', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(656, 183, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:44:32', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(657, 184, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(658, 185, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:50:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(659, 186, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 08:51:04', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(660, 187, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 08:53:39', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(661, 188, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(662, 189, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:01:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(663, 190, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(664, 191, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:03:56', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(665, 192, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(666, 193, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(667, 194, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(668, 195, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:07:49', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(669, 196, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(670, 196, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(671, 196, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(672, 196, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(673, 196, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(674, 196, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(675, 196, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(676, 196, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(677, 197, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(678, 197, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(679, 197, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(680, 197, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(681, 197, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(682, 197, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:32', '10.0.100.79', NULL, NULL, NULL),
(683, 198, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:12:35', '10.0.100.79', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL),
(684, 199, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(685, 200, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 09:13:05', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(686, 201, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:14:33', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(687, 202, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:15:10', '10.0.100.79', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL),
(688, 203, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(689, 203, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(690, 203, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(691, 203, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(692, 203, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(693, 203, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(694, 203, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(695, 203, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:17:01', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(696, 204, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(697, 204, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(698, 204, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(699, 204, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(700, 204, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(701, 204, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(702, 204, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(703, 204, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(704, 205, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(705, 205, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(706, 205, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(707, 205, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(708, 205, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(709, 205, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:43', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(710, 206, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(711, 206, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(712, 206, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(713, 206, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(714, 206, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(715, 206, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(716, 207, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:24:44', '10.0.100.79', 1021, '2023-11-15 09:29:24', '10.0.100.79', NULL, NULL, NULL),
(717, 208, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(718, 208, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(719, 208, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(720, 208, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(721, 208, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(722, 208, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(723, 208, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(724, 208, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(725, 209, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:28:47', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(726, 210, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(727, 210, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(728, 210, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(729, 210, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(730, 210, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(731, 210, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(732, 210, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(733, 210, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(734, 211, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(735, 211, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(736, 211, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(737, 211, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(738, 211, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(739, 211, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(740, 212, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(741, 212, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `carga_horaria_curso_grupo_fecha` (`cgf_id`, `ccg_id`, `cgf_fecha`, `cgf_hora_inicio`, `cgf_hora_fin`, `cgf_horas`, `cgf_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(742, 212, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(743, 212, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(744, 212, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(745, 212, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(746, 213, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:33:35', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(747, 214, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(748, 214, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(749, 214, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(750, 214, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(751, 214, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(752, 214, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(753, 214, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(754, 214, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 09:54:44', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(755, 215, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(756, 215, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(757, 215, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(758, 215, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(759, 215, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(760, 215, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(761, 215, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(762, 215, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:00:41', '10.0.100.79', 1021, '2023-11-15 10:11:07', '10.0.100.79', NULL, NULL, NULL),
(763, 216, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(764, 216, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(765, 216, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(766, 216, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(767, 216, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(768, 216, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(769, 217, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(770, 217, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(771, 217, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(772, 217, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(773, 217, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(774, 217, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:11:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(775, 218, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(776, 219, '2023-11-18', NULL, NULL, NULL, '0001', 1020, '2023-11-15 10:20:14', '10.0.100.54', NULL, NULL, NULL, NULL, NULL, NULL),
(777, 220, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(778, 220, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(779, 220, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(780, 220, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(781, 220, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(782, 220, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(783, 220, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(784, 220, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(785, 221, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(786, 221, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(787, 221, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(788, 221, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(789, 221, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(790, 221, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(791, 222, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(792, 222, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(793, 222, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(794, 222, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(795, 222, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(796, 222, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:20:41', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(797, 223, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(798, 223, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(799, 223, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(800, 223, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(801, 223, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(802, 223, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(803, 223, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(804, 223, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:21:53', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(805, 224, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(806, 224, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(807, 224, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(808, 224, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(809, 224, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(810, 224, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(811, 224, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(812, 224, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(813, 225, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(814, 225, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(815, 225, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(816, 225, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(817, 225, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:33', '10.0.100.98', NULL, NULL, NULL),
(818, 225, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:01', '10.0.100.79', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL),
(819, 226, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(820, 226, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(821, 226, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(822, 226, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(823, 226, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(824, 226, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(825, 226, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(826, 226, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:27:58', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(827, 227, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(828, 227, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(829, 227, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(830, 227, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(831, 227, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:44', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(832, 227, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(833, 228, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(834, 228, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(835, 228, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(836, 228, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(837, 228, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(838, 228, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(839, 229, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(840, 229, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(841, 229, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(842, 229, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(843, 229, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(844, 229, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(845, 229, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(846, 229, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(847, 229, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(848, 229, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(849, 229, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(850, 229, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(851, 229, '2024-03-02', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(852, 229, '2024-03-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(853, 229, '2024-03-09', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(854, 229, '2024-03-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:33:45', '10.0.100.79', 1021, '2023-11-15 12:18:32', '10.0.100.98', NULL, NULL, NULL),
(855, 230, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(856, 230, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(857, 230, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(858, 230, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(859, 230, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(860, 230, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-15 10:34:45', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(861, 231, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(862, 231, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(863, 231, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(864, 231, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(865, 231, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(866, 231, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-15 12:16:34', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(867, 232, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(868, 232, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(869, 232, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(870, 232, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(871, 232, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(872, 232, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(873, 232, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(874, 232, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(875, 233, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(876, 233, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(877, 233, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(878, 233, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(879, 233, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(880, 233, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(881, 234, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(882, 234, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(883, 234, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(884, 234, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(885, 234, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(886, 234, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:03', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(887, 235, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(888, 235, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(889, 235, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(890, 235, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(891, 235, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(892, 235, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(893, 235, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(894, 235, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:43:54', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(895, 236, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(896, 236, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(897, 236, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(898, 236, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(899, 236, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(900, 236, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(901, 236, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:42', '10.0.100.79', NULL, NULL, NULL),
(902, 236, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(903, 237, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(904, 237, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(905, 237, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(906, 237, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(907, 237, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(908, 237, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(909, 238, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(910, 238, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(911, 238, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(912, 238, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(913, 238, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:32', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(914, 238, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(915, 239, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(916, 239, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(917, 239, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(918, 239, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(919, 239, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(920, 239, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:55:33', '10.0.100.79', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL),
(921, 240, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(922, 240, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(923, 240, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(924, 240, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(925, 240, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(926, 240, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(927, 240, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(928, 240, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 11:57:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(929, 241, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(930, 241, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(931, 241, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(932, 241, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(933, 241, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(934, 241, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(935, 241, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(936, 241, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:51', '10.0.100.79', NULL, NULL, NULL),
(937, 242, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(938, 242, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(939, 242, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(940, 242, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(941, 242, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(942, 242, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(943, 242, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(944, 242, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:04:50', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(945, 243, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(946, 243, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(947, 243, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(948, 243, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(949, 243, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(950, 243, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(951, 243, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(952, 243, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:06:17', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(953, 244, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(954, 244, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(955, 244, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(956, 244, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(957, 244, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(958, 244, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(959, 244, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(960, 244, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(961, 245, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(962, 245, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(963, 245, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(964, 245, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(965, 245, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(966, 245, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(967, 246, '2023-11-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:07', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(968, 246, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(969, 246, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(970, 246, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(971, 246, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(972, 246, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(973, 246, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:10:08', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(974, 247, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(975, 247, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(976, 247, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(977, 247, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(978, 247, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(979, 247, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(980, 247, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(981, 247, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:11:12', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(982, 248, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(983, 248, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(984, 248, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(985, 248, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(986, 248, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(987, 248, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(988, 249, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:53', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(989, 249, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:54', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(990, 249, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:54', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(991, 249, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:54', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(992, 249, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:54', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(993, 249, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:18:54', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(994, 250, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(995, 250, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(996, 250, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(997, 250, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(998, 250, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(999, 250, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1000, 250, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1001, 250, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:34', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1002, 250, '2024-02-10', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1003, 250, '2024-02-11', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1004, 250, '2024-02-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1005, 250, '2024-02-18', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1006, 250, '2024-02-24', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1007, 250, '2024-02-25', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1008, 250, '2024-03-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1009, 250, '2024-03-04', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:20:35', '10.0.100.79', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL),
(1010, 251, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1011, 251, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1012, 251, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1013, 251, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1014, 251, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1015, 251, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1016, 252, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1017, 252, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1018, 252, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1019, 252, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1020, 252, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1021, 252, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-16 12:41:59', '10.0.100.79', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL),
(1022, 253, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1023, 253, '2023-11-19', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1024, 253, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1025, 253, '2023-11-26', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1026, 253, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1027, 253, '2023-12-03', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1028, 253, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1029, 253, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:16:43', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1030, 254, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1031, 254, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1032, 254, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1033, 254, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1034, 254, '2024-01-13', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1035, 254, '2024-01-14', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1036, 255, '2024-01-20', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1037, 255, '2024-01-21', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1038, 255, '2024-01-27', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1039, 255, '2024-01-28', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1040, 255, '2024-02-03', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1041, 255, '2024-02-04', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:19:52', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1042, 256, '2023-12-09', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1043, 256, '2023-12-10', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1044, 256, '2023-12-16', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1045, 256, '2023-12-17', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1046, 256, '2024-01-06', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1047, 256, '2024-01-07', NULL, NULL, NULL, '0001', 1021, '2023-11-17 08:24:46', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1048, 257, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1049, 257, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1050, 257, '2023-11-25', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1051, 257, '2023-12-02', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1052, 258, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1053, 259, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1054, 260, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:00:34', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1055, 261, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:02:22', '10.0.100.79', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL),
(1056, 262, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:03:18', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1057, 263, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:06:38', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1058, 264, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1059, 265, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:06:39', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL),
(1060, 266, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:29', '10.0.100.79', NULL, NULL, NULL),
(1061, 267, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:49:07', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(1062, 268, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:49:08', '10.0.100.79', 1021, '2023-11-17 10:49:30', '10.0.100.79', NULL, NULL, NULL),
(1063, 269, '2023-11-11', NULL, NULL, NULL, '0001', 1021, '2023-11-17 10:51:06', '10.0.100.79', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_envio_credenciales`
--

DROP TABLE IF EXISTS `carga_horaria_envio_credenciales`;
CREATE TABLE IF NOT EXISTS `carga_horaria_envio_credenciales` (
  `chec_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sem_id` int(11) DEFAULT NULL,
  `sec_id` int(11) DEFAULT NULL,
  `prg_id` int(11) DEFAULT NULL,
  `chec_doc_nombre` varchar(180) DEFAULT NULL,
  `chec_doc_correo` varchar(180) DEFAULT NULL,
  `chec_envio` bit(1) DEFAULT NULL,
  `chec_envio_fecha` datetime DEFAULT NULL,
  `chec_envio_error` varchar(180) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chec_id`)
) ENGINE=MyISAM AUTO_INCREMENT=98 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_envio_credenciales`
--

INSERT INTO `carga_horaria_envio_credenciales` (`chec_id`, `sem_id`, `sec_id`, `prg_id`, `chec_doc_nombre`, `chec_doc_correo`, `chec_envio`, `chec_envio_fecha`, `chec_envio_error`, `usuario`, `fechahora`, `dispositivo`) VALUES
(1, 70, 6, NULL, 'BURGOS ZAVALETA JOSÉ MARTÍN', 'jmartinburgos@gmail.com', b'1', '2023-11-20 11:33:57', '', 1021, '2023-11-20 11:33:57', '10.0.100.79'),
(2, 70, 6, NULL, 'CUEVA ZAVALETA JORGE LUIS', 'jcueva@unitru.edu.pe', b'1', '2023-11-20 11:36:23', '', 1021, '2023-11-20 11:37:17', '10.0.100.79'),
(3, 70, 6, NULL, 'DIAZ CABRERA MELISSA FIORELLA', 'mdiazc@unitru.edu.pe', b'1', '2023-11-20 11:36:49', '', 1021, '2023-11-20 11:37:17', '10.0.100.79'),
(4, 70, 6, NULL, 'ESPINOLA CARRILLO CÉSAR GUSTAVO', 'cguesea@gmail.com', b'1', '2023-11-20 11:37:17', '', 1021, '2023-11-20 11:37:17', '10.0.100.79'),
(5, 70, 6, NULL, 'GUAYAN HUACCHA LEA', 'lhuayanh@unitru.edu.pe', b'1', '2023-11-20 11:38:21', '', 1021, '2023-11-20 11:38:48', '10.0.100.79'),
(6, 70, 6, NULL, 'JONDEC BRIONES HOMERO PRACEDES', 'hjondecb@hotmail.com', b'1', '2023-11-20 11:38:48', '', 1021, '2023-11-20 11:38:48', '10.0.100.79'),
(7, 70, 6, NULL, 'AGUIRRE BAZAN LUIS ALBERTO', 'laguirreb@unitru.edu.pe', b'1', '2023-11-20 11:51:56', NULL, 1021, '2023-11-20 11:51:56', '10.0.100.79'),
(8, 70, 6, NULL, 'AGUILAR VENTURA LEYLI JENY', 'laguilarv@unitru.edu.pe', b'1', '2023-11-20 11:53:21', NULL, 1021, '2023-11-20 11:53:21', '10.0.100.79'),
(9, 70, 6, NULL, 'ALDAVE HERRERA RAFAEL FERNANDO', 'faldave@unitru.edu.pe', b'1', '2023-11-20 11:53:41', NULL, 1021, '2023-11-20 11:53:41', '10.0.100.79'),
(10, 70, 6, NULL, 'ALARCON REQUEJO GILMER', 'agilmer@hotmail.com', b'1', '2023-11-20 11:53:58', NULL, 1021, '2023-11-20 11:53:58', '10.0.100.79'),
(11, 70, 6, NULL, 'LOYOLA FLORIAN MANUEL FEDERICO', 'loyola_manuel@yahoo.es', b'1', '2023-11-20 11:55:33', '', 1021, '2023-11-20 11:56:26', '10.0.100.79'),
(12, 70, 6, NULL, 'LUJAN ESPINOZA GLADYS MARGARITA', 'glujan@unitru.edu.pe', b'1', '2023-11-20 11:56:01', '', 1021, '2023-11-20 11:56:26', '10.0.100.79'),
(13, 70, 6, NULL, 'NIEVES PEÑA PAMELA ', 'pnieves@unitru.edu.pe', b'1', '2023-11-20 11:56:26', '', 1021, '2023-11-20 11:56:26', '10.0.100.79'),
(14, 70, 6, NULL, 'PORRO RIVADENEIRA MANUEL FRANCISCO', 'mfpr76@gmail.com', b'1', '2023-11-20 11:57:34', '', 1021, '2023-11-20 11:57:34', '10.0.100.79'),
(15, 70, 6, NULL, 'REYES RODRIGUEZ JOSÉ RAYMUNDO', 'jreyesr@unitru.edu.pe', b'1', '2023-11-20 11:58:31', '', 1021, '2023-11-20 11:59:26', '10.0.100.79'),
(16, 70, 6, NULL, 'RODRIGUEZ ALBAN SEGUNDO MIGUEL', 'srodriguezal@unitru.edu.pe', b'1', '2023-11-20 11:59:00', '', 1021, '2023-11-20 11:59:26', '10.0.100.79'),
(17, 70, 6, NULL, 'RUBIÑOS YZAGUIRRE HERMES', 'ruminahui3579@gmail.com', b'1', '2023-11-20 11:59:26', '', 1021, '2023-11-20 11:59:26', '10.0.100.79'),
(18, 70, 6, NULL, 'SÁNCHEZ CORONADO CARLOS ALBERTO', 'casanchezc@unitru.edu.pe', b'1', '2023-11-20 12:00:04', '', 1021, '2023-11-20 12:00:33', '10.0.100.79'),
(19, 70, 6, NULL, 'PONCE MALAVER MOISÉS VALDEMAR', 'drponcemalaver@gmail.com', b'1', '2023-11-20 12:00:33', '', 1021, '2023-11-20 12:00:33', '10.0.100.79'),
(20, 70, 6, NULL, 'VARGAS YSLA ROGER RENATO', 'renato_vargas_ysla@hotmail.com', b'1', '2023-11-20 12:01:12', '', 1021, '2023-11-20 12:01:13', '10.0.100.79'),
(21, 70, 1, NULL, 'CASTRO ANGULO RAUL ERICSON', 'rcastroa@unitru.edu.pe', b'1', '2023-11-20 12:05:01', '', 1021, '2023-11-20 12:05:55', '10.0.100.79'),
(22, 70, 1, NULL, 'CASTILLO ZAVALA JOSE LUIS', 'jlcastilloz@unitru.edu.pe', b'1', '2023-11-20 12:05:28', '', 1021, '2023-11-20 12:05:55', '10.0.100.79'),
(23, 70, 1, NULL, 'CHARCAPE RAVELO JESUS MANUEL', 'jcharcaper@unitru.edu.pe', b'1', '2023-11-20 12:05:55', '', 1021, '2023-11-20 12:05:55', '10.0.100.79'),
(24, 70, 1, NULL, 'DÍAZ SÁNCHEZ CÉSAR NARCÉS', 'cdiazsa@unitru.edu.pe', b'1', '2023-11-20 12:06:52', '', 1021, '2023-11-20 12:06:52', '10.0.100.79'),
(25, 70, 1, NULL, 'GONZALES VELÁSQUEZ CARMEN LIZBETH YURAC', 'cgonzalesv@unitru.edu.pe', b'1', '2023-11-20 12:07:43', '', 1021, '2023-11-20 12:08:40', '10.0.100.79'),
(26, 70, 1, NULL, 'LEIVA CABRERA FRANS ALLINSON', 'fleiva@unitru.edu.pe', b'1', '2023-11-20 12:08:11', '', 1021, '2023-11-20 12:08:40', '10.0.100.79'),
(27, 70, 1, NULL, 'LEÓN TORRES CARLOS ALBERTO', 'cleon@unitru.edu.pe', b'1', '2023-11-20 12:08:40', '', 1021, '2023-11-20 12:08:40', '10.0.100.79'),
(28, 70, 1, NULL, 'MEDINA TAFUR CESAR AUGUSTO', 'cmedinae@unitru.edu.pe', b'1', '2023-11-20 12:09:26', '', 1021, '2023-11-20 12:09:56', '10.0.100.79'),
(29, 70, 1, NULL, 'PEDRO HUAMAN JUAN JAVIER', 'jpedro@unitru.edu.pe', b'1', '2023-11-20 12:09:56', '', 1021, '2023-11-20 12:09:56', '10.0.100.79'),
(30, 70, 1, NULL, 'QUINTANA DÍAZ ANÍBAL ', 'aquintana@unitru.edu.pe', b'1', '2023-11-20 12:10:44', '', 1021, '2023-11-20 12:11:37', '10.0.100.79'),
(31, 70, 1, NULL, 'QUIJANO JARA CARLOS HELI', 'carlos_qj@hotmail.com', b'1', '2023-11-20 12:11:11', '', 1021, '2023-11-20 12:11:37', '10.0.100.79'),
(32, 70, 1, NULL, 'ROBLES CASTILLO HEBER MAX', 'hrobles@unitru.edu.pe', b'1', '2023-11-20 12:11:37', '', 1021, '2023-11-20 12:11:37', '10.0.100.79'),
(33, 70, 1, NULL, 'RODRIGUEZ ESPEJO MARLENE RENE', 'mrodrigueze@unitru.edu.pe', b'1', '2023-11-20 12:13:09', '', 1021, '2023-11-20 12:13:38', '10.0.100.79'),
(34, 70, 1, NULL, 'WILSON KRUGG JUAN HÉCTOR', 'jwilson@unitru.edu.pe', b'1', '2023-11-20 12:13:38', '', 1021, '2023-11-20 12:13:38', '10.0.100.79'),
(35, 70, 2, NULL, 'ACEVEDO ISASI MANUEL ADOLFO', 'manuel.acevedo@gmail.com', b'1', '2023-11-20 12:23:05', '', 1021, '2023-11-20 12:24:03', '10.0.100.79'),
(36, 70, 2, NULL, 'ADRIANZEN JIMENEZ ALEX EDMUNDO', 'aadrianzen@unitru.edu.pe', b'1', '2023-11-20 12:23:34', '', 1021, '2023-11-20 12:24:03', '10.0.100.79'),
(37, 70, 2, NULL, 'AGUILAR CRUZ   GENARO ALFREDO', 'aguilargenaro6@hotmail.com', b'1', '2023-11-20 12:24:03', '', 1021, '2023-11-20 12:24:03', '10.0.100.79'),
(38, 70, 2, NULL, 'ASMAT ALVA ALBERTO RAMIRO', 'aasmat@unitru.edu.pe', b'1', '2023-11-20 12:24:45', '', 1021, '2023-11-20 12:25:10', '10.0.100.79'),
(39, 70, 2, NULL, 'BAUTISTA ZÚÑIGA LILY DE LA CONCEPCIÓN', 'lilybaunt@gmail.com', b'1', '2023-11-20 12:25:10', '', 1021, '2023-11-20 12:25:10', '10.0.100.79'),
(40, 70, 2, NULL, 'BENITEZ GAMBOA JESUS SIGIFREDO', 'jbenitezgamboa@gmail.com', b'1', '2023-11-20 12:25:51', '', 1021, '2023-11-20 12:26:41', '10.0.100.79'),
(41, 70, 2, NULL, 'CARRASCAL CABANILLAS JUAN CARLOS', 'jcarrascal@unitru.edu.pe', b'1', '2023-11-20 12:26:16', '', 1021, '2023-11-20 12:26:41', '10.0.100.79'),
(42, 70, 2, NULL, 'CANO URBINA EDUARDO ANDRES', 'ecano@unitru.edu.pe', b'1', '2023-11-20 12:26:41', '', 1021, '2023-11-20 12:26:41', '10.0.100.79'),
(43, 70, 2, NULL, 'CHOLAN CALDERON ANTONIO ', 'acholan@unitru.edu.pe', b'1', '2023-11-20 12:28:27', '', 1021, '2023-11-20 12:28:53', '10.0.100.79'),
(44, 70, 2, NULL, 'CONCEPCION VELASQUEZ WINSTON ARMANDO', 'wconcepcion@unitru.edu.pe', b'1', '2023-11-20 12:28:53', '', 1021, '2023-11-20 12:28:53', '10.0.100.79'),
(45, 70, 2, NULL, 'DEL ROSARIO ALFARO MANUEL JOSE', 'mdelrosario@unitru.edu.pe', b'1', '2023-11-20 12:30:54', '', 1021, '2023-11-20 12:31:53', '10.0.100.79'),
(46, 70, 2, NULL, 'GORDILLO VEGA ANTONIO ELEODORO', 'agordillo@unitru.edu.pe', b'1', '2023-11-20 12:31:24', '', 1021, '2023-11-20 12:31:53', '10.0.100.79'),
(47, 70, 2, NULL, 'HERNANDEZ CONDORI CARLOS A.', 'chernandezcondori@gmail.com', b'1', '2023-11-20 12:31:52', '', 1021, '2023-11-20 12:31:53', '10.0.100.79'),
(48, 70, 2, NULL, 'JAULIS QUISPE DAVID', 'djaulis@unitru.edu.pe', b'1', '2023-11-20 12:33:11', '', 1021, '2023-11-20 12:33:40', '10.0.100.79'),
(49, 70, 2, NULL, 'LIY LION ROGER DANIEL', 'rlion@unitru.edu.pe', b'1', '2023-11-20 12:33:40', '', 1021, '2023-11-20 12:33:40', '10.0.100.79'),
(50, 70, 2, NULL, 'LOAYZA LEON NILO JAVIER', 'nloayza@unitru.edu.pe', b'1', '2023-11-20 12:35:15', '', 1021, '2023-11-20 12:36:08', '10.0.100.79'),
(51, 70, 2, NULL, 'MARQUEZ YAURI HEYNER YULIANO', 'hmarquez@unitru.edu.pe', b'1', '2023-11-20 12:35:42', '', 1021, '2023-11-20 12:36:08', '10.0.100.79'),
(52, 70, 2, NULL, 'MONTOYA COLMENARES PATRICIA CLEMENTINA', 'pmontoya@unitru.edu.pe', b'1', '2023-11-20 12:36:08', '', 1021, '2023-11-20 12:36:08', '10.0.100.79'),
(53, 70, 2, NULL, 'MONCADA REYES VICTOR ESTUARDO', 'vmoncada@unitru.edu.pe', b'1', '2023-11-20 12:36:50', '', 1021, '2023-11-20 12:37:18', '10.0.100.79'),
(54, 70, 2, NULL, 'MUÑOZ DIAZ LUIS ALBERTO', 'lmudiaz@unitru.edu.pe', b'1', '2023-11-20 12:37:18', '', 1021, '2023-11-20 12:37:18', '10.0.100.79'),
(55, 70, 2, NULL, 'PAREDES TEJADA RAFAEL EDUARDO', 'rparedes@unitru.edu.pe', b'1', '2023-11-20 12:38:26', '', 1021, '2023-11-20 12:39:23', '10.0.100.79'),
(56, 70, 2, NULL, 'PANTIGOSO VELLOSO DA SILVEIRA FRANCISCO MANUEL', 'fpantigosov@unitru.edu.pe', b'1', '2023-11-20 12:38:56', '', 1021, '2023-11-20 12:39:23', '10.0.100.79'),
(57, 70, 2, NULL, 'POLO CAMPOS ANGEL FRANCISCO', 'apolo@unitru.edu.pe', b'1', '2023-11-20 12:39:23', '', 1021, '2023-11-20 12:39:23', '10.0.100.79'),
(58, 70, 2, NULL, 'QUIÑONES  MARTINEZ PAÚL ALEXANDER ', 'pquinones@unitru.edu.pe', b'1', '2023-11-20 12:43:23', '', 1021, '2023-11-20 12:43:51', '10.0.100.79'),
(59, 70, 2, NULL, 'ROEDER ROSALES FRANCISCO JOSE', 'froeder@unitru.edu.pe', b'1', '2023-11-20 12:43:51', '', 1021, '2023-11-20 12:43:51', '10.0.100.79'),
(60, 70, 2, NULL, 'URQUIZO CUELLAR JUAN ISMAEL', 'jurquizo@unitru.edu.pe', b'1', '2023-11-20 12:46:41', '', 1021, '2023-11-20 12:47:09', '10.0.100.79'),
(61, 70, 2, NULL, 'VENTURA AGUILAR HENRY ELDER', 'hventura@unitru.edu.pe', b'1', '2023-11-20 12:47:09', '', 1021, '2023-11-20 12:47:09', '10.0.100.79'),
(62, 70, 3, NULL, 'AVALOS RODRIGUEZ JESUS PASCUAL', 'javalos@unitru.edu.pe', b'1', '2023-11-20 12:51:17', '', 1021, '2023-11-20 12:52:12', '10.0.100.79'),
(63, 70, 3, NULL, 'DE LA CRUZ ARAUJO RONAL', 'ronal.delacruz@unat.edu.pe', b'1', '2023-11-20 12:51:45', '', 1021, '2023-11-20 12:52:12', '10.0.100.79'),
(64, 70, 3, NULL, 'DIAZ LEIVA JOSE LEVI', 'Jdiazl@unitru.edu.pe', b'1', '2023-11-20 12:52:12', '', 1021, '2023-11-20 12:52:12', '10.0.100.79'),
(65, 70, 3, NULL, 'IPANAQUE CENTENO ENRIQUE', 'EIPANAQUE@UNITRU.EDU.PE', b'1', '2023-11-20 12:52:57', '', 1021, '2023-11-20 12:53:30', '10.0.100.79'),
(66, 70, 3, NULL, 'MINCHON MEDINA CARLOS ALBERTO', 'cminchon@unitru.edu.pe', b'1', '2023-11-20 12:53:30', '', 1021, '2023-11-20 12:53:30', '10.0.100.79'),
(67, 70, 3, NULL, 'NECIOSUP OBANDO JORGE EDUARDO', 'jorgeneciosup@gmail.com', b'1', '2023-11-20 12:55:11', '', 1021, '2023-11-20 12:56:06', '10.0.100.79'),
(68, 70, 3, NULL, 'RODRIGUEZ BENITES CARLOS EDGARDO', 'cerodriguez@unitru.edu.pe', b'1', '2023-11-20 12:55:38', '', 1021, '2023-11-20 12:56:06', '10.0.100.79'),
(69, 70, 3, NULL, 'ROLDAN LOPEZ JOSE ANGEL', 'jroldanl@yahoo.es', b'1', '2023-11-20 12:56:06', '', 1021, '2023-11-20 12:56:06', '10.0.100.79'),
(70, 70, 3, NULL, 'RUBIO LOPEZ FRANCO MODESTO', 'frubio@unitru.edu.pe', b'1', '2023-11-20 12:56:42', '', 1021, '2023-11-20 12:56:42', '10.0.100.79'),
(71, 70, 4, NULL, 'ALVARADO CACERES VICTOR MANUEL', 'valvarado@unitru.edu.pe', b'1', '2023-11-20 13:09:44', '', 1021, '2023-11-20 13:10:38', '10.0.100.79'),
(72, 70, 4, NULL, 'ARMAS FAVA LOURDES ADELAIDA', 'larmasf@unitru.edu.pe', b'1', '2023-11-20 13:10:09', '', 1021, '2023-11-20 13:10:38', '10.0.100.79'),
(73, 70, 4, NULL, 'ESPINOZA WONG CESAR AUGUSTO', 'cesarespinozawongmd@gmail.com', b'1', '2023-11-20 13:10:38', '', 1021, '2023-11-20 13:10:38', '10.0.100.79'),
(74, 70, 4, NULL, 'EVANGELISTA MONTOYA FLOR DE MARÍA', 'fevangelistam@unitru.edu.pe', b'1', '2023-11-20 13:11:18', '', 1021, '2023-11-20 13:11:45', '10.0.100.79'),
(75, 70, 4, NULL, 'LLAQUE SÁNCHEZ MARÍA ROCÍO DEL PILAR', 'rociollaque1@gmail.com', b'1', '2023-11-20 13:11:44', '', 1021, '2023-11-20 13:11:45', '10.0.100.79'),
(76, 70, 4, NULL, 'LUNA FARRO MARIA ELENA', 'mlunaf@unitru.edu.pe', b'1', '2023-11-20 13:18:23', '', 1021, '2023-11-20 13:19:21', '10.0.100.79'),
(77, 70, 4, NULL, 'MAGUIÑA VARGAS CIRO PEREGRINO', 'ciro.maguina@upch.pe', b'1', '2023-11-20 13:18:54', '', 1021, '2023-11-20 13:19:21', '10.0.100.79'),
(78, 70, 4, NULL, 'MEJIA DELGADO ELVA MANUELA', 'emejia@unitru.edu.pe', b'1', '2023-11-20 13:19:21', '', 1021, '2023-11-20 13:19:21', '10.0.100.79'),
(79, 70, 4, NULL, 'PLASENCIA ALVAREZ JORGE OMAR', 'jplasencia@unitru.edu.pe', b'1', '2023-11-20 13:26:23', '', 1021, '2023-11-20 13:26:50', '10.0.100.79'),
(80, 70, 4, NULL, 'POLO CAMPOS FREDY HERNÁN', 'fpolo@unitru.edu.pe', b'1', '2023-11-20 13:26:50', '', 1021, '2023-11-20 13:26:50', '10.0.100.79'),
(81, 70, 4, NULL, 'RIOS CARO TERESA ETELVINA', 'trios@unitru.edu.pe', b'1', '2023-11-20 13:28:22', '', 1021, '2023-11-20 13:29:21', '10.0.100.79'),
(82, 70, 4, NULL, 'RÍOS CARO MARCO CESAR', 'rioscaromc@hotmail.com', b'1', '2023-11-20 13:28:52', '', 1021, '2023-11-20 13:29:21', '10.0.100.79'),
(83, 70, 4, NULL, 'ROMERO GOICOCHEA CECILIA VICTORIA', 'cromerog@unitru.edu.pe', b'1', '2023-11-20 13:29:21', '', 1021, '2023-11-20 13:29:21', '10.0.100.79'),
(84, 70, 5, NULL, 'AGUILAR PAREDES OREALIS MARÍA DEL SOCORRO', 'oaguilar@gmail.com', b'1', '2023-11-20 13:31:51', '', 1021, '2023-11-20 13:32:48', '10.0.100.79'),
(85, 70, 5, NULL, 'BRAVO CARRE MANUEL ALBERTO', 'mbravoc@unitru.edu.pe', b'1', '2023-11-20 13:32:19', '', 1021, '2023-11-20 13:32:48', '10.0.100.79'),
(86, 70, 5, NULL, 'CORONADO TELLO LUIS ENRIQUE', 'lcoronado@unitru.edu.pe', b'1', '2023-11-20 13:32:48', '', 1021, '2023-11-20 13:32:48', '10.0.100.79'),
(87, 70, 5, NULL, 'GONZALEZ GONZALEZ DIONICIO GODOFREDO', 'dggonzalez@unitru.edu.pe', b'1', '2023-11-20 13:33:25', '', 1021, '2023-11-20 13:33:55', '10.0.100.79'),
(88, 70, 5, NULL, 'MONTENEGRO SALDAÑA CECILIA FABIOLA', 'cecimontenegro3@hotmail.com', b'1', '2023-11-20 13:33:55', '', 1021, '2023-11-20 13:33:55', '10.0.100.79'),
(89, 70, 5, NULL, 'PEREDA TAPIA SONIA LILIANA', 'sn@unitru.edu.pe', b'1', '2023-11-20 13:34:55', '', 1021, '2023-11-20 13:35:50', '10.0.100.79'),
(90, 70, 5, NULL, 'PELAEZ VINCES EDGARD JOSE', 'epelaez@unitru.edu.pe', b'1', '2023-11-20 13:35:21', '', 1021, '2023-11-20 13:35:50', '10.0.100.79'),
(91, 70, 5, NULL, 'PINCHI RAMÍREZ WADSON ', 'wpinchi@unitru.edu.pe', b'1', '2023-11-20 13:35:50', '', 1021, '2023-11-20 13:35:50', '10.0.100.79'),
(92, 70, 5, NULL, 'TORRES LARA MARCO ANTONIO', 'marcotorrreslara@hotmail.com', b'1', '2023-11-20 13:36:34', '', 1021, '2023-11-20 13:37:03', '10.0.100.79'),
(93, 70, 5, NULL, 'URIOL CASTILLO GAUDY TERESA', 'guriolc@unitru.edu.pe', b'1', '2023-11-20 13:37:03', '', 1021, '2023-11-20 13:37:03', '10.0.100.79'),
(94, 70, 5, NULL, 'TORRES LARA MARCO ANTONIO', 'marcotorrreslara@hotmail.com', b'1', '2023-11-20 13:45:10', '', 1021, '2023-11-20 13:46:04', '10.0.100.79'),
(95, 70, 5, NULL, 'URIOL CASTILLO GAUDY TERESA', 'guriolc@unitru.edu.pe', b'1', '2023-11-20 13:45:36', '', 1021, '2023-11-20 13:46:04', '10.0.100.79'),
(96, 70, 5, NULL, 'VEGA BAZÁN  RONCAL DELIA', 'dvega@unitru.edu.pe', b'1', '2023-11-20 13:46:04', '', 1021, '2023-11-20 13:46:04', '10.0.100.79'),
(97, 70, 5, NULL, 'YEPJÉN RAMOS ALEJANDRO ELJOV', 'ayepjen@unitru.edu.pe', b'1', '2023-11-20 13:47:18', '', 1021, '2023-11-20 13:47:18', '10.0.100.79');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multitabla`
--

DROP TABLE IF EXISTS `multitabla`;
CREATE TABLE IF NOT EXISTS `multitabla` (
  `mtb_id` int(11) NOT NULL AUTO_INCREMENT,
  `tbl_id` varchar(4) DEFAULT NULL,
  `mtb_valor` varchar(4) DEFAULT NULL,
  `mtb_nombre` varchar(250) DEFAULT NULL,
  `mtb_descripcion` varchar(250) DEFAULT NULL,
  `mtb_valor1` varchar(4) DEFAULT NULL,
  `mtb_valor2` varchar(4) DEFAULT NULL,
  `mtb_valor3` varchar(4) DEFAULT NULL,
  `mtb_valor4` varchar(4) DEFAULT NULL,
  `mtb_activo` bit(1) DEFAULT NULL,
  `mtb_eliminado` bit(1) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int(11) DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int(11) DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`mtb_id`)
) ENGINE=MyISAM AUTO_INCREMENT=56 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `multitabla`
--

INSERT INTO `multitabla` (`mtb_id`, `tbl_id`, `mtb_valor`, `mtb_nombre`, `mtb_descripcion`, `mtb_valor1`, `mtb_valor2`, `mtb_valor3`, `mtb_valor4`, `mtb_activo`, `mtb_eliminado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, NULL, '0001', 'CONDICION DOCENTE', 'CONDICION DEL DOCENTE EN UPG', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(2, '0001', '0001', 'UNT', 'UNT', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(3, '0001', '0002', 'INVITADO NACIONAL', 'INVITADO NACIONAL', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(4, '0001', '0003', 'INVITADO LOCAL', 'INVITADO LOCAL', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(5, '0001', '0004', 'INVITADO INTERNACIONAL', 'INVITADO INTERNACIONAL', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(6, '0001', '0005', 'EXTERNO', 'EXTERNO', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(7, NULL, '0002', 'GRADO', 'GRADO DEL DOCENTE', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(8, '0002', '0001', 'MAGISTER', 'MAGISTER', 'Mag.', NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(9, '0002', '0002', 'DOCTOR', 'DOCTOR', 'Dr.', NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(10, '0002', '0003', 'DOCTORA', 'DOCTORA', 'Dra.', NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(11, NULL, '0003', 'TIPO DE CURSO', 'TIPO DE CURSO', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(12, '0003', '0001', 'GENERALES', 'GENERALES', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(13, '0003', '0002', 'ESPECÍFICOS', 'ESPECÍFICOS', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(14, '0003', '0003', 'SEMINARIOS', 'SEMINARIOS', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(15, '0003', '0004', 'TESIS', 'TESIS', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(16, NULL, '0004', 'CALIDAD DEL CURSO', 'CALIDAD DEL CURSO', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(17, '0004', '0001', 'ELECTIVO', 'ELECTIVO', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(18, '0004', '0002', 'OBLIGATORIO', 'OBLIGATORIO', NULL, NULL, NULL, NULL, b'1', b'0', 1020, '2023-09-15 12:05:46', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(19, NULL, '0005', 'ESTADOS DE CARGA HORARIA', 'ESTADOS DE CARGA HORARIA', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(20, '0005', '0001', 'CREADO', 'Documento creado.', '0001', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(21, '0005', '0002', 'EN REVISIÓN', 'Documento en proceso de revision.', '0005', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(22, '0005', '0003', 'APROBADO', 'Revisado y aprobado.', '0002', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(23, '0005', '0004', 'VIGENTE', 'Actualmente en uso y aplicable.', '0002', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(24, '0005', '0005', 'OBSOLETO', 'Documento que ya no se utiliza.', '0003', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(25, '0005', '0006', 'ARCHIVADO', 'Documentos ya no usados pero conservados.', '0007', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(26, '0005', '0007', 'ENVIADO', 'Documento enviado para su revisión.', '0004', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(27, '0005', '0008', 'ELIMINADO', 'Documento eliminado de manera segura.', '0003', NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:02:44', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(28, NULL, '0006', 'COLORES', 'COLORES', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(29, '0006', '0001', 'primary', 'Color primario', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(30, '0006', '0002', 'success', 'Color positivo', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(31, '0006', '0003', 'danger', 'Color errores', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(32, '0006', '0004', 'warning', 'Color warning messages', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(33, '0006', '0005', 'info', 'Color informacion', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(34, '0006', '0006', 'light', 'Color menos contraste', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(35, '0006', '0007', 'dark', 'Color contraste alto', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-09-17 10:56:05', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(53, NULL, '0007', 'ESTADOS PARA REGISTROS', 'ESTADOS PARA REGISTROS', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-10-15 16:24:56', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(54, '0007', '0001', 'ACTIVO', 'REGISTRO ACTIVO', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-10-15 16:24:56', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL),
(55, '0007', '0002', 'ELIMINADO', 'REGISTRO ELIMINADO', NULL, NULL, NULL, NULL, b'1', b'1', 1020, '2023-10-15 16:24:56', '10.0.100.56', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_calidad_curso`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_calidad_curso`;
CREATE TABLE IF NOT EXISTS `v_calidad_curso` (
`valor` varchar(4)
,`nombre` varchar(250)
,`descripcion` varchar(250)
,`valor1` varchar(4)
,`valor2` varchar(4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_colores`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_colores`;
CREATE TABLE IF NOT EXISTS `v_colores` (
`valor` varchar(4)
,`nombre` varchar(250)
,`descripcion` varchar(250)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_condicion_docente`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_condicion_docente`;
CREATE TABLE IF NOT EXISTS `v_condicion_docente` (
`idCondicion` varchar(4)
,`condicion` varchar(250)
,`descripcion` varchar(250)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_estados`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_estados`;
CREATE TABLE IF NOT EXISTS `v_estados` (
`idEstado` varchar(4)
,`estado` varchar(250)
,`descripcion_estado` varchar(250)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_estados_carga_horaria`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_estados_carga_horaria`;
CREATE TABLE IF NOT EXISTS `v_estados_carga_horaria` (
`valor` varchar(4)
,`nombre` varchar(250)
,`descripcion` varchar(250)
,`color_id` varchar(4)
,`color` varchar(250)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_tipo_curso`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_tipo_curso`;
CREATE TABLE IF NOT EXISTS `v_tipo_curso` (
`valor` varchar(4)
,`nombre` varchar(250)
,`descripcion` varchar(250)
,`valor1` varchar(4)
,`valor2` varchar(4)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_calidad_curso`
--
DROP TABLE IF EXISTS `v_calidad_curso`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_calidad_curso`  AS  select `multitabla`.`mtb_valor` AS `valor`,`multitabla`.`mtb_nombre` AS `nombre`,`multitabla`.`mtb_descripcion` AS `descripcion`,`multitabla`.`mtb_valor1` AS `valor1`,`multitabla`.`mtb_valor2` AS `valor2` from `multitabla` where `multitabla`.`tbl_id` = '0004' and `multitabla`.`mtb_activo` = 1 and `multitabla`.`mtb_eliminado` = 0 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_colores`
--
DROP TABLE IF EXISTS `v_colores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_colores`  AS  select `multitabla`.`mtb_valor` AS `valor`,`multitabla`.`mtb_nombre` AS `nombre`,`multitabla`.`mtb_descripcion` AS `descripcion` from `multitabla` where `multitabla`.`tbl_id` = '0006' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_condicion_docente`
--
DROP TABLE IF EXISTS `v_condicion_docente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_condicion_docente`  AS  select `multitabla`.`mtb_valor` AS `idCondicion`,`multitabla`.`mtb_nombre` AS `condicion`,`multitabla`.`mtb_descripcion` AS `descripcion` from `multitabla` where `multitabla`.`tbl_id` = '0001' and `multitabla`.`mtb_activo` = 1 and `multitabla`.`mtb_eliminado` = 0 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_estados`
--
DROP TABLE IF EXISTS `v_estados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_estados`  AS  select `multitabla`.`mtb_valor` AS `idEstado`,`multitabla`.`mtb_nombre` AS `estado`,`multitabla`.`mtb_descripcion` AS `descripcion_estado` from `multitabla` where `multitabla`.`tbl_id` = '0007' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_estados_carga_horaria`
--
DROP TABLE IF EXISTS `v_estados_carga_horaria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_estados_carga_horaria`  AS  select `ech`.`mtb_valor` AS `valor`,`ech`.`mtb_nombre` AS `nombre`,`ech`.`mtb_descripcion` AS `descripcion`,`ech`.`mtb_valor1` AS `color_id`,`c`.`nombre` AS `color` from (`multitabla` `ech` join `v_colores` `c` on(`c`.`valor` = `ech`.`mtb_valor1`)) where `ech`.`tbl_id` = '0005' order by `ech`.`mtb_valor` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_tipo_curso`
--
DROP TABLE IF EXISTS `v_tipo_curso`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tipo_curso`  AS  select `multitabla`.`mtb_valor` AS `valor`,`multitabla`.`mtb_nombre` AS `nombre`,`multitabla`.`mtb_descripcion` AS `descripcion`,`multitabla`.`mtb_valor1` AS `valor1`,`multitabla`.`mtb_valor2` AS `valor2` from `multitabla` where `multitabla`.`tbl_id` = '0003' and `multitabla`.`mtb_activo` = 1 and `multitabla`.`mtb_eliminado` = 0 ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
