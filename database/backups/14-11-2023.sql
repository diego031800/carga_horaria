-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 14-11-2023 a las 17:31:25
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAsignacionDocenteByPrograma` (IN `p_sem_id` INT, IN `p_sec_id` INT, IN `p_prg_id` INT)  BEGIN  
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
    WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id AND CH.prg_id = p_prg_id
		AND CH.cgh_estado = '0001' AND CGD.cgd_titular = 1
	GROUP BY CGD.cgd_id, CH.sem_codigo, CGC.cgh_ciclo, CHC.cur_codigo, CHC.cur_descripcion,
		CCG.ccg_grupo, CGD.cgd_titular, CGD.doc_condicion, CGD.doc_id, CGD.doc_codigo, 
        CGD.doc_documento, CGD.doc_nombres, CGD.doc_email;
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
	ORDER BY CH.prg_mencion ASC;
    
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
) ENGINE=MyISAM AUTO_INCREMENT=43 DEFAULT CHARSET=latin1;

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
(42, '', 70, 'SMTR52062023', '2023-II', 4, 'CIENCIAS MÉDICAS', 122, 'ESTOMATOLOGÍA', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM AUTO_INCREMENT=66 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `carga_horaria_ciclo`
--

INSERT INTO `carga_horaria_ciclo` (`cgc_id`, `cgh_id`, `cgh_ciclo`, `cgc_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 1, '0008', 1021, '2023-10-24 14:20:26', '10.0.100.68', NULL, NULL, NULL, 1020, '2023-10-24 14:21:27', '10.0.100.42'),
(2, 2, 2, '0001', 2037, '2023-10-25 14:40:49', '10.0.100.25', 2037, '2023-10-25 14:42:02', '10.0.100.25', NULL, NULL, NULL),
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
(64, 42, 2, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 42, 4, '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM AUTO_INCREMENT=116 DEFAULT CHARSET=latin1;

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
(112, 64, 3536, 'P01CE432B', 'METODOLOGÍA DE LA ENSEÑANZA - APRENDIZAJE SUPERIOR', '0001', '0002', 2, 4, '64.00', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 64, 2118, 'P01SA102A', 'EPIDEMIOLOGÍA', '0001', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 64, 4129, 'P66OD502B', 'AVANCES EN ESTOMATOLOGÍA I', '0002', '0002', 2, 3, '48.00', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(115, 65, 3064, 'P66OD504A', 'AVANCES EN ESTOMATOLOGÍA III', '0002', '0002', 4, 4, '64.00', '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM AUTO_INCREMENT=120 DEFAULT CHARSET=latin1;

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
(116, 112, 70, 122, 1, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(117, 113, 70, 122, 1, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(118, 114, 70, 122, 1, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(119, 115, 70, 122, 1, '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM AUTO_INCREMENT=134 DEFAULT CHARSET=latin1;

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
(129, 116, b'1', NULL, NULL, NULL, '0003', '0003', 376, 'OBSO6708', '00000000', 'OBESSO SOLIS EYFIM SONNY ', '', 'eobesso@unitru.edu.pe', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(130, 117, b'1', NULL, NULL, NULL, '0001', '0003', 147, 'ROGO1864', '9325223', 'ROMERO GOICOCHEA CECILIA VICTORIA', '995960400', 'cromerog@unitru.edu.pe', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(131, 118, b'1', NULL, NULL, NULL, '0002', '0003', 377, 'GARU1829', '00000000', 'GARCÍA RUPAYA CARMEN ROSA', '', 'crgarcia@unitru.edu.pe', '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(132, 119, b'1', NULL, NULL, NULL, '0001', '0003', 150, 'RICA3044', '07622440', 'RIOS CARO TERESA ETELVINA', '996967602', 'trios@unitru.edu.pe', '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(133, 119, b'0', NULL, NULL, NULL, '0001', '0002', 151, 'AGAG2658', '18217212', 'AGUIRRE AGUILAR ANTONIO ARMANDO', '949563835', 'aaguirrea@unitru.edu.pe', '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM AUTO_INCREMENT=413 DEFAULT CHARSET=latin1;

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
(409, 116, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(410, 117, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(411, 118, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:56:53', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL),
(412, 119, '2023-11-18', NULL, NULL, NULL, '0001', 1021, '2023-11-13 13:57:51', '10.0.100.98', NULL, NULL, NULL, NULL, NULL, NULL);

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
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

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
