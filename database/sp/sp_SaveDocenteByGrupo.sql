DROP procedure IF EXISTS sp_SaveDocenteByGrupo;

DELIMITER $$
CREATE PROCEDURE sp_SaveDocenteByGrupo(
	IN p_cgd_id INT, 
    IN p_ccg_id INT, 
    IN p_cgd_titular BIT, 
    IN p_cgd_horas DECIMAL(10,2), 
    IN p_cgd_fecha_inicio DATE, 
    IN p_cgd_fecha_fin DATE, 
    IN p_doc_grado VARCHAR(4), 
    IN p_doc_condicion VARCHAR(25), 
    IN p_doc_id INT, 
    IN p_doc_codigo VARCHAR(10), 
    IN p_doc_documento VARCHAR(10), 
    IN p_doc_nombres VARCHAR(180), 
    IN p_doc_celular VARCHAR(180), 
    IN p_doc_email VARCHAR(180), 
    IN p_cgd_estado VARCHAR(4), 
    IN p_usuario INT, 
    IN p_dispositivo VARCHAR(100)
)
BEGIN  
	DECLARE cgd_id INT;
	IF p_cgd_id IS NULL OR p_cgd_id = 0 THEN
        -- Insertar nuevo registro
        INSERT INTO CARGA_HORARIA_CURSO_GRUPO_DOCENTE (
            ccg_id, cgd_titular, cgd_horas, cgd_fecha_inicio, cgd_fecha_fin, doc_condicion, doc_grado,
            doc_id, doc_codigo, doc_documento, doc_nombres, doc_celular, doc_email, 
            cgd_estado, usuario, fechahora, dispositivo 
        ) VALUES (
            p_ccg_id, p_cgd_titular, p_cgd_horas, p_cgd_fecha_inicio, p_cgd_fecha_fin, p_doc_condicion, p_doc_grado,
            p_doc_id, p_doc_codigo, p_doc_documento, p_doc_nombres, p_doc_celular, p_doc_email, 
            p_cgd_estado, p_usuario, NOW(), p_dispositivo
        );
        
        SET @cgd_id = last_insert_id();
        
        SELECT 1 as respuesta, 'El docente se guardo exitosamente.' as mensaje, @cgd_id as cgd_id;
    ELSE
        -- Actualizar registro existente
        UPDATE CARGA_HORARIA_CURSOS_DOCENTES SET
            ccg_id = p_ccg_id,
            cgd_titular = p_cgd_titular,
            cgd_horas = p_cgd_horas,
            cgd_fecha_inicio = p_cgd_fecha_inicio,
            cgd_fecha_fin = p_cgd_fecha_fin,
            doc_condicion = p_doc_condicion,
            doc_grado = p_doc_grado,
            doc_id = p_doc_id,
            doc_documento = p_doc_documento,
            doc_codigo = p_doc_codigo,
            doc_nombres = p_doc_nombres,
            doc_celular = p_doc_celular,
            doc_email = p_doc_email,
            cgd_estado = p_cgd_estado,
            usuario_modificacion = p_usuario,
            fechahora_modificacion = NOW(),
            dispositivo_modificacion = p_dispositivo
        WHERE cgd_id = p_cgd_id;
        
        SELECT 1 as respuesta, 'Se actualizaron correctamente los datos del docente.' as mensaje, p_cgd_id as cgd_id;
    END IF;
END$$

DELIMITER ;
;

