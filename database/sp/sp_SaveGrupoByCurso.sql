DROP PROCEDURE IF EXISTS sp_SaveGrupoByCurso;

DELIMITER $$
CREATE PROCEDURE sp_SaveGrupoByCurso (
	IN p_ccg_id INT, 
    IN p_chc_id INT, 
    IN p_sem_id INT, 
    IN p_prg_id INT, 
    IN p_ccg_grupo INT, 
    IN p_ccg_estado VARCHAR(4), 
    IN p_usuario INT,
    IN p_dispositivo VARCHAR(100)
) 
BEGIN  
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
    ELSE
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
        WHERE chf_id = p_chf_id;
        
        SELECT 1 as respuesta, 'Se actualizó correctamente el grupo.' as mensaje, p_chf_id as ccg_id;
    END IF;
END$$

DELIMITER ;