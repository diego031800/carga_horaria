DROP PROCEDURE IF EXISTS sp_GetDocentesByGrupo;

DELIMITER $$
CREATE PROCEDURE sp_GetDocentesByGrupo (
	IN p_ccg_id INT
)  
BEGIN  
	
    SELECT
		CGD.cgd_id,
        CGD.ccg_id,
        CGD.cgd_titular,
        CGD.cgd_horas,
        CGD.cgd_fecha_inicio,
        CGD.cgd_fecha_fin,
        CGD.doc_condicion,
        CGD.doc_id,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_celular,
        CGD.doc_email,
        CGD.cgd_estado as estado
    FROM CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD
    WHERE CGD.ccg_id = p_ccg_id
		AND CGD.cgd_estado = '0001';
    
END$$