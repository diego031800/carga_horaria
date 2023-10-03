DROP PROCEDURE IF EXISTS sp_SaveCargaHorariaUnidad;

DELIMITER $$
CREATE PROCEDURE sp_SaveCargaHorariaUnidad (
	IN p_chu_id INT, 
    IN p_cgh_id INT,
    IN p_sec_id INT, 
    IN p_sec_descripcion VARCHAR(100), 
    IN p_chu_estado VARCHAR(4), 
    IN p_usuario INT, 
    IN p_dispositivo VARCHAR(100)
)
BEGIN
	DECLARE chu_id INT;
	IF p_chu_id IS NULL OR p_chu_id = 0 THEN
		SET @chu_id = (SELECT 
							CH.chu_id 
						FROM CARGA_HORARIA_UNIDAD CHU
                        INNER JOIN CARGA_HORARIA CGH ON CGH.cgh_id = CHU.cgh_id
                        WHERE CHU.sec_id = p_sec_id
							AND CHU.cgh_id = p_cgh_id
                            AND CHU.chu_estado = '0001'
                        ORDER BY CHU.chu_id DESC
                        LIMIT 1);
        IF @chu_id IS NULL OR @chu_id = 0 THEN
			-- Insertar nuevo registro
			INSERT INTO CARGA_HORARIA_UNIDAD (
				cgh_id, sec_id, sec_descripcion,
				chu_estado, usuario, fechahora, dispositivo 
			) VALUES (
				p_cgh_id, p_sec_id, p_sec_descripcion,
				p_chu_estado, p_usuario, NOW(), p_dispositivo
			);
			
            SET @chu_id = last_insert_id();
			
			SELECT 1 as respuesta, 'Se guardo exitosamente la carga horaria.' as mensaje, @chu_id as chu_id;
        ELSE
			SELECT 1 as respuesta, 'Se obtuvo una carga horaria con los mismos datos.' as mensaje, @chu_id as chu_id;
        END IF;
    ELSE
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA SET
            cgh_id = p_cgh_id,
            sec_id = p_sec_id,
            sec_descripcion = p_sec_descripcion,
            chu_estado = p_chu_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE chu_id = p_chu_id;
        
        SELECT 1 as respuesta, 'Se actualizaron los datos exitosamente.' as mensaje, p_chu_id as chu_id; 
    END IF;
END$$
DELIMITER ;