DROP PROCEDURE IF EXISTS sp_deleteCargaHoraria;

DELIMITER $$
CREATE PROCEDURE sp_deleteCargaHoraria (
	IN p_cgh_id INT,
    IN p_cgc_id INT,
    IN p_usuario INT,
    IN p_dispositivo VARCHAR(100)
)
BEGIN
	UPDATE CARGA_HORARIA_CICLO
    SET
		cgc_estado = '0008',
        usuario_eliminacion = p_usuario,
        fechahora_eliminacion = now(),
        dispositivo_eliminacion = p_dispositivo
    WHERE cgc_id = p_cgc_id;
    
    SELECT 1 as respuesta, 'Se eliminó el registro correctamente.' as mensaje, p_cgh_id as cgh_id;
END$$
DELIMITER ;