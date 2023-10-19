DROP procedure IF EXISTS sp_UpdateCargaHorariaCurso;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE sp_UpdateCargaHorariaCurso(
	IN p_chc_id INT, 
    IN p_cgc_id INT,
    IN p_cur_id INT,
    IN p_cur_codigo VARCHAR(20), 
    IN p_cur_descripcion VARCHAR(200), 
    IN p_cur_tipo VARCHAR(4),
    IN p_cur_calidad VARCHAR(4),
    IN p_cur_ciclo INT,
    IN p_cur_creditos INT,
    IN p_chc_horas DECIMAL(10,2),
    IN p_chc_estado VARCHAR(4), 
    IN p_usuario INT, 
    IN p_dispositivo VARCHAR(100)
)
BEGIN
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

DELIMITER ;
;

