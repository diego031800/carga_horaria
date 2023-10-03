DROP PROCEDURE IF EXISTS sp_SaveFechaByGrupo;

DELIMITER $$
CREATE PROCEDURE sp_SaveFechaByGrupo (
	IN p_cgf_id INT, 
    IN p_ccg_id INT, 
    IN p_cgf_fecha DATE, 
    IN p_cgf_hora_inicio INT, 
    IN p_cgf_hora_fin INT, 
    IN p_cgf_horas DECIMAL(10,2), 
    IN p_cgf_estado VARCHAR(4), 
    IN p_usuario INT,
    IN p_dispositivo VARCHAR(100)
)  
BEGIN  
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
    ELSE
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
