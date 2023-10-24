-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 19-10-2023 a las 06:50:26
-- Versión del servidor: 8.0.31
-- Versión de PHP: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteCargaHoraria` (IN `p_cgh_id` INT, IN `p_cgc_id` INT, IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
	UPDATE CARGA_HORARIA
    SET
		cgh_estado = '0008',
        usuario_eliminacion = p_usuario,
        fechahora_eliminacion = now(),
        dispositivo_eliminacion = p_dispositivo
	WHERE cgh_id = p_cgh_id;
    
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAsignacionDocenteByPrograma` (IN `p_sem_id` INT, IN `p_sec_id` INT, IN `p_prg_id` INT)   BEGIN  
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCargaHoraria` (IN `p_sem_id` INT, IN `p_sec_id` INT)   BEGIN  
	
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
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_FECHA CGF ON CGF.ccg_id = CCG.ccg_id
    WHERE CH.sem_id = p_sem_id 
		AND CH.sec_id = p_sec_id
        AND CH.cgh_estado = '0001'
	ORDER BY CH.sec_descripcion ASC, CH.prg_mencion ASC, CGC.cgh_ciclo ASC, CHC.cur_descripcion ASC,
		CCG.ccg_grupo ASC, CGD.cgd_titular DESC, CGF.cgf_id ASC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetCargaHorariaById`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCargaHorariaById` (IN `p_cgh_id` INT, IN `p_cgc_id` INT)   BEGIN  

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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCicloByCargaHoraria` (IN `p_cgh_id` INT)   BEGIN  
	
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCursosByCiclo` (IN `p_cgc_id` INT)   BEGIN  
	
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDocentesByGrupo` (IN `p_ccg_id` INT)   BEGIN  
	
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetFechasByGrupo` (IN `p_ccg_id` INT)   BEGIN  
	
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetGruposByCurso` (IN `p_chc_id` INT)   BEGIN  
	
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMisCargasHorarias` (IN `p_sem_id` INT, IN `p_sec_id` INT, IN `p_prg_id` INT, IN `p_ciclo` INT, IN `p_usuario` INT)   BEGIN  

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
        CH.cgh_estado as estado_id,
        ECH.nombre as estado,
        ECH.color,
        CGC.usuario,
        CGC.usuario_modificacion
    FROM CARGA_HORARIA CH
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
    INNER JOIN V_ESTADOS_CARGA_HORARIA ECH ON ECH.valor = CH.cgh_estado
    WHERE (CH.sem_id = p_sem_id)
		AND (CH.sec_id = p_sec_id)
		AND (CH.prg_id = p_prg_id OR p_prg_id = '')
        AND (CGC.cgh_ciclo = p_ciclo OR p_ciclo = '')
        -- AND CH.usuario = p_usuario;
	ORDER BY CH.prg_mencion ASC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_GetMisCargasHorariasBySem`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMisCargasHorariasBySem` (IN `p_sem_id` INT, IN `p_sec_id` INT, IN `p_usuario` INT, IN `p_unidades` JSON)   BEGIN  
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
        ECH.color,
        CH.usuario
    FROM CARGA_HORARIA CH
    INNER JOIN V_ESTADOS_CARGA_HORARIA ECH ON ECH.valor = CH.cgh_estado
    INNER JOIN UNIDADES_TEMP UTE ON UTE.sec_id = CH.sec_id
    WHERE (CH.sem_id = p_sem_id OR p_sem_id = '')
		AND (CH.sec_id = p_sec_id OR p_sec_id = '')
	GROUP BY CH.cgh_codigo, CH.sem_id, CH.sem_codigo, CH.sem_descripcion, CH.sec_id, CH.sec_descripcion,
		CH.cgh_estado, ECH.nombre, ECH.color, CH.usuario
	ORDER BY CH.fechahora DESC;
    
END$$

DROP PROCEDURE IF EXISTS `sp_SaveCargaHoraria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveCargaHoraria` (IN `p_cgh_id` INT, IN `p_cgh_codigo` VARCHAR(10), IN `p_sem_id` INT, IN `p_sem_codigo` VARCHAR(12), IN `p_sem_descripcion` VARCHAR(100), IN `p_sec_id` INT, IN `p_sec_descripcion` VARCHAR(100), IN `p_prg_id` INT, IN `p_prg_mencion` VARCHAR(100), IN `p_cgc_id` INT, IN `p_cgc_ciclo` INT, IN `p_cgh_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
	DECLARE cgh_id INT;
	DECLARE cgc_id INT;
	IF p_cgh_id IS NULL OR p_cgh_id = 0 THEN
		SET @cgh_id = (SELECT 
							CH.cgh_id 
						FROM CARGA_HORARIA CH
                        INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
                        WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id 
							AND CH.prg_id = p_prg_id AND CGC.cgh_ciclo = p_cgc_ciclo 
                            AND CH.cgh_estado = '0001'
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveCargaHorariaCurso` (IN `p_chc_id` INT, IN `p_cgc_id` INT, IN `p_cur_id` INT, IN `p_cur_codigo` VARCHAR(20), IN `p_cur_descripcion` VARCHAR(200), IN `p_cur_tipo` VARCHAR(4), IN `p_cur_calidad` VARCHAR(4), IN `p_cur_ciclo` INT, IN `p_cur_creditos` INT, IN `p_chc_horas` DECIMAL(10,2), IN `p_chc_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveDocenteByGrupo` (IN `p_cgd_id` INT, IN `p_ccg_id` INT, IN `p_cgd_titular` BIT, IN `p_cgd_horas` DECIMAL(10,2), IN `p_cgd_fecha_inicio` DATE, IN `p_cgd_fecha_fin` DATE, IN `p_doc_grado` VARCHAR(4), IN `p_doc_condicion` VARCHAR(25), IN `p_doc_id` INT, IN `p_doc_codigo` VARCHAR(10), IN `p_doc_documento` VARCHAR(10), IN `p_doc_nombres` VARCHAR(180), IN `p_doc_celular` VARCHAR(180), IN `p_doc_email` VARCHAR(180), IN `p_cgd_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN  
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveFechaByGrupo` (IN `p_cgf_id` INT, IN `p_ccg_id` INT, IN `p_cgf_fecha` DATE, IN `p_cgf_hora_inicio` INT, IN `p_cgf_hora_fin` INT, IN `p_cgf_horas` DECIMAL(10,2), IN `p_cgf_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN  
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveGrupoByCurso` (IN `p_ccg_id` INT, IN `p_chc_id` INT, IN `p_sem_id` INT, IN `p_prg_id` INT, IN `p_ccg_grupo` INT, IN `p_ccg_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN  
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateCargaHoraria` (IN `p_cgh_id` INT, IN `p_cgh_codigo` VARCHAR(10), IN `p_sem_id` INT, IN `p_sem_codigo` VARCHAR(12), IN `p_sem_descripcion` VARCHAR(100), IN `p_sec_id` INT, IN `p_sec_descripcion` VARCHAR(100), IN `p_prg_id` INT, IN `p_prg_mencion` VARCHAR(100), IN `p_cgc_id` INT, IN `p_cgc_ciclo` INT, IN `p_cgh_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateCargaHorariaCurso` (IN `p_chc_id` INT, IN `p_cgc_id` INT, IN `p_cur_id` INT, IN `p_cur_codigo` VARCHAR(20), IN `p_cur_descripcion` VARCHAR(200), IN `p_cur_tipo` VARCHAR(4), IN `p_cur_calidad` VARCHAR(4), IN `p_cur_ciclo` INT, IN `p_cur_creditos` INT, IN `p_chc_horas` DECIMAL(10,2), IN `p_chc_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateDocenteByGrupo` (IN `p_cgd_id` INT, IN `p_ccg_id` INT, IN `p_cgd_titular` BIT, IN `p_cgd_horas` DECIMAL(10,2), IN `p_cgd_fecha_inicio` DATE, IN `p_cgd_fecha_fin` DATE, IN `p_doc_grado` VARCHAR(4), IN `p_doc_condicion` VARCHAR(25), IN `p_doc_id` INT, IN `p_doc_codigo` VARCHAR(10), IN `p_doc_documento` VARCHAR(10), IN `p_doc_nombres` VARCHAR(180), IN `p_doc_celular` VARCHAR(180), IN `p_doc_email` VARCHAR(180), IN `p_cgd_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateFechaByGrupo` (IN `p_cgf_id` INT, IN `p_ccg_id` INT, IN `p_cgf_fecha` DATE, IN `p_cgf_hora_inicio` INT, IN `p_cgf_hora_fin` INT, IN `p_cgf_horas` DECIMAL(10,2), IN `p_cgf_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateGrupoByCurso` (IN `p_ccg_id` INT, IN `p_chc_id` INT, IN `p_sem_id` INT, IN `p_prg_id` INT, IN `p_ccg_grupo` INT, IN `p_ccg_estado` VARCHAR(4), IN `p_usuario` INT, IN `p_dispositivo` VARCHAR(100))   BEGIN
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
  `cgh_id` int NOT NULL AUTO_INCREMENT,
  `cgh_codigo` varchar(10) DEFAULT NULL,
  `sem_id` int DEFAULT NULL,
  `sem_codigo` varchar(12) DEFAULT NULL,
  `sem_descripcion` varchar(100) DEFAULT NULL,
  `sec_id` int DEFAULT NULL,
  `sec_descripcion` varchar(100) DEFAULT NULL,
  `prg_id` int DEFAULT NULL,
  `prg_mencion` varchar(150) DEFAULT NULL,
  `cgh_estado` varchar(4) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgh_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3;

--
-- Volcado de datos para la tabla `carga_horaria`
--

INSERT INTO `carga_horaria` (`cgh_id`, `cgh_codigo`, `sem_id`, `sem_codigo`, `sem_descripcion`, `sec_id`, `sec_descripcion`, `prg_id`, `prg_mencion`, `cgh_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, '', 69, 'SMTR58592023', '2023-I', 4, 'CIENCIAS MÉDICAS', 64, 'PLANIFICACIÓN Y GESTIÓN', '0001', 1020, '2023-10-16 00:35:01', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(2, '', 69, 'SMTR58592023', '2023-I', 4, 'CIENCIAS MÉDICAS', 164, 'NUTRICIÓN HUMANA', '0001', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_ciclo`
--

DROP TABLE IF EXISTS `carga_horaria_ciclo`;
CREATE TABLE IF NOT EXISTS `carga_horaria_ciclo` (
  `cgc_id` int NOT NULL AUTO_INCREMENT,
  `cgh_id` int NOT NULL,
  `cgh_ciclo` int DEFAULT NULL,
  `cgc_estado` varchar(4) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgc_id`),
  KEY `cgh_id` (`cgh_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4;

--
-- Volcado de datos para la tabla `carga_horaria_ciclo`
--

INSERT INTO `carga_horaria_ciclo` (`cgc_id`, `cgh_id`, `cgh_ciclo`, `cgc_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 1, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, 3, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(3, 2, 1, '0001', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso`
--

DROP TABLE IF EXISTS `carga_horaria_curso`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso` (
  `chc_id` int NOT NULL AUTO_INCREMENT,
  `cgc_id` int NOT NULL,
  `cur_id` int DEFAULT NULL,
  `cur_codigo` varchar(20) DEFAULT NULL,
  `cur_descripcion` varchar(200) DEFAULT NULL,
  `cur_tipo` varchar(4) DEFAULT NULL,
  `cur_calidad` varchar(4) DEFAULT NULL,
  `cur_ciclo` int DEFAULT NULL,
  `cur_creditos` int DEFAULT NULL,
  `chc_horas` decimal(10,2) DEFAULT NULL,
  `chc_estado` varchar(4) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chc_id`),
  KEY `cgc_id` (`cgc_id`)
) ENGINE=MyISAM AUTO_INCREMENT=11;

--
-- Volcado de datos para la tabla `carga_horaria_curso`
--

INSERT INTO `carga_horaria_curso` (`chc_id`, `cgc_id`, `cur_id`, `cur_codigo`, `cur_descripcion`, `cur_tipo`, `cur_calidad`, `cur_ciclo`, `cur_creditos`, `chc_horas`, `chc_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 2796, 'P01CE428A', 'METODOLOGÍA DE LA INVESTIGACIÓN CIENTÍFICA', '0001', '0002', 1, 4, '64.00', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, 3226, 'P86ES533A', 'BIOESTADÍSTICA', '0001', '0002', 1, 4, '64.00', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, 3709, 'P33MS515A', 'EPIDEMIOLOGÍA PARA SALUD PÚBLICA', '0002', '0002', 1, 4, '64.00', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, 3, 'P33MS519A', 'INVESTIGACIÓN EN SALUD PÚBLICA', '0002', '0001', 1, 3, '48.00', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 2, 2383, 'P94TH101A', 'DESARROLLO ORGANIZACIONAL', '0002', '0002', 3, 4, '64.00', '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(6, 2, 1023, 'P33AD534A', 'CONDUCCIÓN Y LIDERAZGO', '0001', '0001', 3, 3, '48.00', '0002', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(7, 3, 2796, 'P01CE428A', 'METODOLOGÍA DE LA INVESTIGACIÓN CIENTÍFICA', '0002', '0002', 1, 4, '64.00', '0002', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-18 17:46:25', '::1', NULL, NULL, NULL),
(8, 3, 3226, 'P86ES533A', 'BIOESTADÍSTICA', '0002', '0002', 1, 4, '64.00', '0001', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(9, 3, 3751, 'P42FH513A', 'FISIOLOGÍA DE LA NUTRICIÓN', '0002', '0002', 1, 4, '64.00', '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(10, 3, 3, 'P33MS519A', 'INVESTIGACIÓN EN SALUD PÚBLICA', '0001', '0001', 1, 3, '48.00', '0002', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso_grupo`
--

DROP TABLE IF EXISTS `carga_horaria_curso_grupo`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso_grupo` (
  `ccg_id` int NOT NULL AUTO_INCREMENT,
  `chc_id` int NOT NULL,
  `sem_id` int DEFAULT NULL,
  `prg_id` int DEFAULT NULL,
  `ccg_grupo` int NOT NULL,
  `ccg_estado` varchar(4) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ccg_id`),
  KEY `chc_id` (`chc_id`)
) ENGINE=MyISAM AUTO_INCREMENT=12;

--
-- Volcado de datos para la tabla `carga_horaria_curso_grupo`
--

INSERT INTO `carga_horaria_curso_grupo` (`ccg_id`, `chc_id`, `sem_id`, `prg_id`, `ccg_grupo`, `ccg_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, 69, 64, 1, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, 69, 64, 1, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 3, 69, 64, 1, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 4, 69, 64, 1, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 5, 69, 64, 1, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(6, 6, 69, 64, 1, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(7, 7, 69, 164, 1, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 8, 69, 164, 1, '0001', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(9, 9, 69, 164, 1, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(10, 10, 69, 164, 1, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(11, 8, 69, 164, 2, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso_grupo_docente`
--

DROP TABLE IF EXISTS `carga_horaria_curso_grupo_docente`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso_grupo_docente` (
  `cgd_id` int NOT NULL AUTO_INCREMENT,
  `ccg_id` int NOT NULL,
  `cgd_titular` bit(1) NOT NULL,
  `cgd_horas` decimal(10,2) DEFAULT NULL,
  `cgd_fecha_inicio` datetime DEFAULT NULL,
  `cgd_fecha_fin` datetime DEFAULT NULL,
  `doc_condicion` varchar(25) DEFAULT NULL,
  `doc_grado` varchar(45) DEFAULT NULL,
  `doc_id` int DEFAULT NULL,
  `doc_codigo` varchar(10) DEFAULT NULL,
  `doc_documento` varchar(10) DEFAULT NULL,
  `doc_nombres` varchar(180) DEFAULT NULL,
  `doc_celular` varchar(180) DEFAULT NULL,
  `doc_email` varchar(180) DEFAULT NULL,
  `cgd_estado` varchar(4) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgd_id`),
  KEY `ccg_id` (`ccg_id`)
) ENGINE=MyISAM AUTO_INCREMENT=13;

--
-- Volcado de datos para la tabla `carga_horaria_curso_grupo_docente`
--

INSERT INTO `carga_horaria_curso_grupo_docente` (`cgd_id`, `ccg_id`, `cgd_titular`, `cgd_horas`, `cgd_fecha_inicio`, `cgd_fecha_fin`, `doc_condicion`, `doc_grado`, `doc_id`, `doc_codigo`, `doc_documento`, `doc_nombres`, `doc_celular`, `doc_email`, `cgd_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, b'1', NULL, NULL, NULL, '0001', '0003', 381, 'EVMO2160', '40271086', 'EVANGELISTA MONTOYA FLOR DE MARÍA', '948687115', 'fevangelistam@unitru.edu.pe', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, b'1', NULL, NULL, NULL, '0002', '0001', 250, 'ESPE8403', '10632743', 'ESQUERRE PEREYRA PAUL HENRY', '958047214', 'pesquerre@unitru.edu.pe', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 3, b'1', NULL, NULL, NULL, '0003', '0002', 131, 'COAR8078', '12345678', 'CORREA ARANGOITIA ALEJANDRO ', '987654321', 'acorreaa@unitru.edu.pe', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 4, b'1', NULL, NULL, NULL, '0003', '0001', 132, 'CRBE6067', '17839712', 'CRUZ BEJARANO SEGUNDO ', '949601465', 'scruzb@unitru.edu.pe', '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 5, b'1', NULL, NULL, NULL, '0002', '0002', 133, 'LILI5699', '12345678', 'LIP LICHAM CESAR ', '987654321', 'clip@unitru.edu.pe', '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(6, 6, b'1', NULL, NULL, NULL, '0002', '0002', 134, 'ALCA6813', '17880794', 'ALVARADO CACERES VICTOR MANUEL', '949933999', 'valvarado@unitru.edu.pe', '0001', 1020, '2023-10-16 00:59:04', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(7, 7, b'1', NULL, NULL, NULL, '0001', '0003', 381, 'EVMO2160', '40271086', 'EVANGELISTA MONTOYA FLOR DE MARÍA', '948687115', 'fevangelistam@unitru.edu.pe', '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 8, b'1', NULL, NULL, NULL, '0002', '0001', 250, 'ESPE8403', '10632743', 'ESQUERRE PEREYRA PAUL HENRY', '958047214', 'pesquerre@unitru.edu.pe', '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(9, 9, b'1', NULL, NULL, NULL, '0002', '0002', 135, 'SASO8444', '16709515', 'SAMILLAN SOTO VICTOR JESUS', '987654321', 'vjsamillan@unitru.edu.pe', '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(10, 10, b'1', NULL, NULL, NULL, '0002', '0001', 132, 'CRBE6067', '17839712', 'CRUZ BEJARANO SEGUNDO ', '949601465', 'scruzb@unitru.edu.pe', '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(11, 8, b'0', NULL, NULL, NULL, '0002', '0001', 209, 'ADJI8284', '17839712', 'ADRIANZEN JIMENEZ ALEX EDMUNDO', '949204955', 'aadrianzen@unitru.edu.pe', '0002', 1020, '2023-10-19 01:48:22', '::1', 1020, '2023-10-19 01:48:44', '::1', NULL, NULL, NULL),
(12, 11, b'1', NULL, NULL, NULL, '0002', '0001', 303, 'AGGA5044', '10632743', 'AGREDA GAMBOA EVERSON DAVID', '966243289', 'eagreda@unitru.edu.pe', '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_curso_grupo_fecha`
--

DROP TABLE IF EXISTS `carga_horaria_curso_grupo_fecha`;
CREATE TABLE IF NOT EXISTS `carga_horaria_curso_grupo_fecha` (
  `cgf_id` int NOT NULL AUTO_INCREMENT,
  `ccg_id` int NOT NULL,
  `cgf_fecha` date DEFAULT NULL,
  `cgf_hora_inicio` int DEFAULT NULL,
  `cgf_hora_fin` int DEFAULT NULL,
  `cgf_horas` decimal(10,2) DEFAULT NULL,
  `cgf_estado` varchar(4) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cgf_id`),
  KEY `ccg_id` (`ccg_id`)
) ENGINE=MyISAM AUTO_INCREMENT=83;

--
-- Volcado de datos para la tabla `carga_horaria_curso_grupo_fecha`
--

INSERT INTO `carga_horaria_curso_grupo_fecha` (`cgf_id`, `ccg_id`, `cgf_fecha`, `cgf_hora_inicio`, `cgf_hora_fin`, `cgf_horas`, `cgf_estado`, `usuario`, `fechahora`, `dispositivo`, `usuario_modificacion`, `fechahora_modificacion`, `dispositivo_modificacion`, `usuario_eliminacion`, `fechahora_eliminacion`, `dispositivo_eliminacion`) VALUES
(1, 1, '2023-06-10', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, '2023-06-11', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, '2023-06-17', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, '2023-06-18', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, '2023-06-24', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 1, '2023-06-25', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 1, '2023-07-01', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 1, '2023-07-02', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 2, '2023-07-08', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 2, '2023-07-09', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 2, '2023-07-15', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 2, '2023-07-16', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 2, '2023-07-22', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 2, '2023-07-23', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 2, '2023-08-05', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 2, '2023-08-06', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 3, '2023-08-12', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 3, '2023-08-13', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 3, '2023-08-19', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 3, '2023-08-20', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 3, '2023-08-26', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 3, '2023-08-27', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(23, 3, '2023-09-02', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 3, '2023-09-03', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 4, '2023-09-09', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 4, '2023-09-10', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 4, '2023-09-16', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 4, '2023-09-17', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 4, '2023-09-23', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 4, '2023-09-24', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:35:01', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 5, '2023-06-17', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(32, 5, '2023-06-18', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(33, 5, '2023-06-24', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(34, 5, '2023-06-25', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(35, 5, '2023-07-01', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(36, 5, '2023-07-02', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(37, 5, '2023-07-08', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(38, 5, '2023-07-09', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(39, 6, '2023-07-15', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:03', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(40, 6, '2023-07-16', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:04', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(41, 6, '2023-07-22', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:04', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(42, 6, '2023-07-23', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:04', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(43, 6, '2023-08-05', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:04', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(44, 6, '2023-08-06', NULL, NULL, NULL, '0001', 1020, '2023-10-16 00:59:04', '::1', 1020, '2023-10-18 19:15:30', '::1', NULL, NULL, NULL),
(45, 7, '2023-06-10', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 7, '2023-06-11', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 7, '2023-06-17', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(48, 7, '2023-06-18', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(49, 7, '2023-06-24', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 7, '2023-06-25', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 7, '2023-07-01', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 7, '2023-07-02', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 8, '2023-07-08', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(54, 8, '2023-07-09', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:52', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(55, 8, '2023-07-15', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(56, 8, '2023-07-16', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(57, 8, '2023-07-22', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(58, 8, '2023-07-23', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(59, 8, '2023-08-05', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(60, 8, '2023-08-06', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(61, 9, '2023-08-12', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(62, 9, '2023-08-13', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(63, 9, '2023-08-19', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(64, 9, '2023-08-20', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(65, 9, '2023-08-26', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(66, 9, '2023-08-27', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(67, 9, '2023-09-02', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(68, 9, '2023-09-03', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL),
(69, 10, '2023-09-09', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(70, 10, '2023-09-10', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(71, 10, '2023-09-16', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(72, 10, '2023-09-17', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(73, 10, '2023-09-23', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(74, 10, '2023-09-24', NULL, NULL, NULL, '0001', 1020, '2023-10-17 19:13:53', '::1', 1020, '2023-10-18 19:13:12', '::1', NULL, NULL, NULL),
(75, 11, '2023-08-12', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 11, '2023-08-13', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 11, '2023-08-19', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 11, '2023-08-20', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 11, '2023-08-26', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 11, '2023-08-27', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 11, '2023-09-02', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 11, '2023-09-03', NULL, NULL, NULL, '0001', 1020, '2023-10-19 01:49:22', '::1', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carga_horaria_envio_credenciales`
--

DROP TABLE IF EXISTS `carga_horaria_envio_credenciales`;
CREATE TABLE IF NOT EXISTS `carga_horaria_envio_credenciales` (
  `chec_id` bigint NOT NULL AUTO_INCREMENT,
  `sem_id` int DEFAULT NULL,
  `sec_id` int DEFAULT NULL,
  `prg_id` int DEFAULT NULL,
  `chec_doc_nombre` varchar(180) DEFAULT NULL,
  `chec_doc_correo` varchar(180) DEFAULT NULL,
  `chec_envio` bit(1) DEFAULT NULL,
  `chec_envio_fecha` datetime DEFAULT NULL,
  `chec_envio_error` varchar(180) DEFAULT NULL,
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chec_id`)
) ENGINE=MyISAM;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multitabla`
--

DROP TABLE IF EXISTS `multitabla`;
CREATE TABLE IF NOT EXISTS `multitabla` (
  `mtb_id` int NOT NULL AUTO_INCREMENT,
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
  `usuario` int DEFAULT NULL,
  `fechahora` datetime DEFAULT NULL,
  `dispositivo` varchar(100) DEFAULT NULL,
  `usuario_modificacion` int DEFAULT NULL,
  `fechahora_modificacion` datetime DEFAULT NULL,
  `dispositivo_modificacion` varchar(100) DEFAULT NULL,
  `usuario_eliminacion` int DEFAULT NULL,
  `fechahora_eliminacion` datetime DEFAULT NULL,
  `dispositivo_eliminacion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`mtb_id`)
) ENGINE=MyISAM AUTO_INCREMENT=56;

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
`descripcion` varchar(250)
,`nombre` varchar(250)
,`valor` varchar(4)
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
`descripcion` varchar(250)
,`nombre` varchar(250)
,`valor` varchar(4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_estados`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_estados`;
CREATE TABLE IF NOT EXISTS `v_estados` (
`descripcion_estado` varchar(250)
,`estado` varchar(250)
,`idEstado` varchar(4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_estados_carga_horaria`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_estados_carga_horaria`;
CREATE TABLE IF NOT EXISTS `v_estados_carga_horaria` (
`color` varchar(250)
,`color_id` varchar(4)
,`descripcion` varchar(250)
,`nombre` varchar(250)
,`valor` varchar(4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_tipo_curso`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `v_tipo_curso`;
CREATE TABLE IF NOT EXISTS `v_tipo_curso` (
`descripcion` varchar(250)
,`nombre` varchar(250)
,`valor` varchar(4)
,`valor1` varchar(4)
,`valor2` varchar(4)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_calidad_curso`
--
DROP TABLE IF EXISTS `v_calidad_curso`;

DROP VIEW IF EXISTS `v_calidad_curso`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_calidad_curso`  AS SELECT `multitabla`.`mtb_valor` AS `valor`, `multitabla`.`mtb_nombre` AS `nombre`, `multitabla`.`mtb_descripcion` AS `descripcion`, `multitabla`.`mtb_valor1` AS `valor1`, `multitabla`.`mtb_valor2` AS `valor2` FROM `multitabla` WHERE ((`multitabla`.`tbl_id` = '0004') AND (`multitabla`.`mtb_activo` = 1) AND (`multitabla`.`mtb_eliminado` = 0))  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_colores`
--
DROP TABLE IF EXISTS `v_colores`;

DROP VIEW IF EXISTS `v_colores`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_colores`  AS SELECT `multitabla`.`mtb_valor` AS `valor`, `multitabla`.`mtb_nombre` AS `nombre`, `multitabla`.`mtb_descripcion` AS `descripcion` FROM `multitabla` WHERE (`multitabla`.`tbl_id` = '0006')  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_estados`
--
DROP TABLE IF EXISTS `v_estados`;

DROP VIEW IF EXISTS `v_estados`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_estados`  AS SELECT `multitabla`.`mtb_valor` AS `idEstado`, `multitabla`.`mtb_nombre` AS `estado`, `multitabla`.`mtb_descripcion` AS `descripcion_estado` FROM `multitabla` WHERE (`multitabla`.`tbl_id` = '0007')  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_estados_carga_horaria`
--
DROP TABLE IF EXISTS `v_estados_carga_horaria`;

DROP VIEW IF EXISTS `v_estados_carga_horaria`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_estados_carga_horaria`  AS SELECT `ech`.`mtb_valor` AS `valor`, `ech`.`mtb_nombre` AS `nombre`, `ech`.`mtb_descripcion` AS `descripcion`, `ech`.`mtb_valor1` AS `color_id`, `c`.`nombre` AS `color` FROM (`multitabla` `ech` join `v_colores` `c` on((`c`.`valor` = `ech`.`mtb_valor1`))) WHERE (`ech`.`tbl_id` = '0005') ORDER BY `ech`.`mtb_valor` ASC  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_tipo_curso`
--
DROP TABLE IF EXISTS `v_tipo_curso`;

DROP VIEW IF EXISTS `v_tipo_curso`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tipo_curso`  AS SELECT `multitabla`.`mtb_valor` AS `valor`, `multitabla`.`mtb_nombre` AS `nombre`, `multitabla`.`mtb_descripcion` AS `descripcion`, `multitabla`.`mtb_valor1` AS `valor1`, `multitabla`.`mtb_valor2` AS `valor2` FROM `multitabla` WHERE ((`multitabla`.`tbl_id` = '0003') AND (`multitabla`.`mtb_activo` = 1) AND (`multitabla`.`mtb_eliminado` = 0))  ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
