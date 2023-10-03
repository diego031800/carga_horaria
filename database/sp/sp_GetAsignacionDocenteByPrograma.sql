DROP procedure IF EXISTS sp_GetAsignacionDocenteByPrograma;

DELIMITER $$
CREATE PROCEDURE sp_GetAsignacionDocenteByPrograma (
	IN p_sem_id INT, 
    IN p_sec_id INT, 
    IN p_prg_id INT
)
BEGIN  
	SELECT 
		CGD.cgd_id,
        CH.sem_codigo, 
        CGC.cgh_ciclo as ciclo,
        CHC.cur_codigo,
        CHC.cur_descripcion,
        CASE WHEN CCG.ccg_grupo = 1
			THEN 'A'
            ELSE 'B' END as grupo,
        CGD.cgd_titular,
        CGD.doc_condicion,
        CGD.doc_id,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_email,
        MIN(date_format(CGF.cgf_fecha, '%d/%m/%Y')) as fecha_inicio,
        MAX(date_format(CGF.cgf_fecha, '%d/%m/%Y')) as fecha_fin
    FROM CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO CCG ON CCG.ccg_id = CGD.ccg_id
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_FECHA CGF ON CGF.ccg_id = CCG.ccg_id
    INNER JOIN CARGA_HORARIA_CURSO CHC ON CHC.chc_id = CCG.chc_id
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgc_id = CHC.cgc_id
    INNER JOIN CARGA_HORARIA CH ON CH.cgh_id = CGC.cgh_id
    WHERE CH.sem_id = p_sem_id AND CH.sec_id = p_sec_id AND CH.prg_id = p_prg_id
		AND CH.cgh_estado = '0001' AND CGD.cgd_titular = 1
	GROUP BY CGD.cgd_id, CH.sem_codigo, CGC.cgh_ciclo, CHC.cur_codigo, CHC.cur_descripcion,
		CCG.ccg_grupo, CGD.cgd_titular, CGD.doc_condicion, CGD.doc_id, CGD.doc_codigo, 
        CGD.doc_documento, CGD.doc_nombres, CGD.doc_email;
END$$

DELIMITER ;
;

