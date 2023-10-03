DROP PROCEDURE IF EXISTS sp_SaveCargaHoraria;

DELIMITER $$
CREATE PROCEDURE sp_SaveCargaHoraria (
	IN p_cgh_id INT, 
    IN p_cgh_codigo VARCHAR(10), 
    IN p_sem_id INT, 
    IN p_sem_codigo VARCHAR(12), 
    IN p_sem_descripcion VARCHAR(100),
    IN p_sec_id INT, 
    IN p_sec_descripcion VARCHAR(100),
    IN p_prg_id INT, 
    IN p_prg_mencion VARCHAR(100),
    IN p_cgc_ciclo INT, 
    IN p_cgh_estado VARCHAR(4), 
    IN p_usuario INT, 
    IN p_dispositivo VARCHAR(100)
)
BEGIN
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
        -- IF @cgh_id IS NULL OR @cgh_id = 0 THEN
        
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
        -- ELSE
			-- SELECT 0 as respuesta, 'Ya existe una carga horaria para esa mención y ciclo.' as mensaje, @cgh_id as cgh_id;
        -- END IF;
    ELSE
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA SET
            cgh_codigo = p_cgh_codigo,
            sem_id = p_sem_id,
            sem_codigo = p_sem_codigo,
            sem_descripcion = p_sem_descripcion,
            sec_id = p_sec_id,
            sec_descripcion = p_sec_descripcion,
            prg_id = p_prg_id,
            prg_mencion = p_prg_mencion,
            cgh_ciclo = p_cgh_ciclo,
            cgh_estado = p_cgh_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE cgh_id = p_cgh_id;
        
        SELECT 1 as respuesta, p_cgh_id as cgh_id; 
    END IF;
END$$
DELIMITER ;