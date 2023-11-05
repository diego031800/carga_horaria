DROP PROCEDURE IF EXISTS sp_SaveCargaHorariaCurso;

DELIMITER $$
CREATE PROCEDURE sp_SaveCargaHorariaCurso(
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
DELIMITER ;