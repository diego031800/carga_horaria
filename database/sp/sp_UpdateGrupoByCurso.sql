DROP procedure IF EXISTS sp_UpdateGrupoByCurso;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE sp_UpdateGrupoByCurso(
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
;

