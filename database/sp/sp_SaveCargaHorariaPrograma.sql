DROP PROCEDURE IF EXISTS sp_SaveCargaHorariaPrograma;

DELIMITER $$
CREATE PROCEDURE `sp_SaveCargaHorariaPrograma` (
	IN p_chp_id INT, 
    IN p_chu_id INT,
    IN p_prg_id INT, 
    IN p_prg_mencion VARCHAR(100), 
    IN p_chp_estado VARCHAR(4), 
    IN p_usuario INT, 
    IN p_dispositivo VARCHAR(100)
)
BEGIN
	DECLARE chp_id INT;
	IF p_chp_id IS NULL OR p_chp_id = 0 THEN
		SET @chp_id = (SELECT 
							CHP.chp_id 
						FROM CARGA_HORARIA_PROGRAMA CHP
                        INNER JOIN CARGA_HORARIA_UNIDAD CHU ON CHU.chu_id = CHP.chu_id
                        WHERE CHP.prg_id = p_prg_id
                            AND CHP.chp_estado = '0001'
                        ORDER BY CHP.chp_id DESC
                        LIMIT 1);
        IF @chp_id IS NULL OR @chp_id = 0 THEN
			-- Insertar nuevo registro
			INSERT INTO CARGA_HORARIA_UNIDAD (
				chu_id, prg_id, prg_mencion,
				chp_estado, usuario, fechahora, dispositivo 
			) VALUES (
				p_chu_id, p_prg_id, p_prg_mencion,
				p_chp_estado, p_usuario, NOW(), p_dispositivo
			);
			
            SET @chp_id = last_insert_id();
			
			SELECT 1 as respuesta, 'Se guardo exitosamente la carga horaria.' as mensaje, @chp_id as chp_id;
        ELSE
			SELECT 1 as respuesta, 'Se obtuvo una carga horaria con los mismos datos.' as mensaje, @chp_id as chp_id;
        END IF;
    ELSE
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA SET
            chu_id = p_chu_id,
            prg_id = p_prg_id,
            prg_mencion = p_prg_mencion,
            chp_estado = p_chp_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE chp_id = p_chp_id;
        
        SELECT 1 as respuesta, 'Se actualizaron los datos exitosamente.' as mensaje, p_chp_id as chp_id; 
    END IF;
END$$
DELIMITER ;