DROP PROCEDURE IF EXISTS sp_UpdateCargaHoraria;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE sp_UpdateCargaHoraria (
	IN p_cgh_id INT, 
    IN p_cgh_codigo VARCHAR(10), 
    IN p_sem_id INT, 
    IN p_sem_codigo VARCHAR(12), 
    IN p_sem_descripcion VARCHAR(100),
    IN p_sec_id INT, 
    IN p_sec_descripcion VARCHAR(100),
    IN p_prg_id INT, 
    IN p_prg_mencion VARCHAR(100),
    IN p_cgc_id INT, 
    IN p_cgc_ciclo INT, 
    IN p_cgh_estado VARCHAR(4), 
    IN p_usuario INT, 
    IN p_dispositivo VARCHAR(100)
)
BEGIN
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
END$$
DELIMITER ;