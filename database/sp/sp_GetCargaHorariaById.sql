DROP procedure IF EXISTS sp_GetCargaHorariaById;

DELIMITER $$
CREATE PROCEDURE sp_GetCargaHorariaById(
	IN p_cgh_id INT, 
    IN p_cgc_id INT
)
BEGIN  

	SELECT
		CH.cgh_id,
        CH.cgh_codigo,
        CH.sem_id,
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.prg_id,
        CH.prg_mencion as mencion,
        CGC.cgc_id,
        CGC.cgh_ciclo as ciclo,
        CHC.chc_id,
        CHC.cur_id,
        CHC.cur_codigo,
        CHC.cur_descripcion as curso,
        CHC.cur_tipo,
        TC.nombre as tipo_curso,
        CHC.cur_calidad,
        CC.nombre as calidad_curso,
        CHC.cur_creditos,
        CHC.chc_horas,
        CCG.ccg_id,
        CCG.ccg_grupo as grupo,
        CGD.cgd_id,
        CGD.cgd_titular as titular,
        CGD.doc_condicion,
        CGD.doc_id,
        CGD.doc_codigo,
        CGD.doc_documento,
        CGD.doc_nombres,
        CGD.doc_celular,
        CGD.doc_email,
        CGF.cgf_id,
        CGF.cgf_fecha as fecha
    FROM CARGA_HORARIA CH
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
    INNER JOIN CARGA_HORARIA_CURSO CHC ON CHC.cgc_id = CGC.cgc_id
    INNER JOIN V_TIPO_CURSO TC ON TC.valor = CHC.cur_tipo
    INNER JOIN V_CALIDAD_CURSO CC ON CC.valor = CHC.cur_calidad
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO CCG ON CCG.chc_id = CHC.chc_id
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_DOCENTE CGD ON CGD.ccg_id = CCG.ccg_id
    INNER JOIN CARGA_HORARIA_CURSO_GRUPO_FECHA CGF ON CGF.ccg_id = CCG.ccg_id
    WHERE CH.cgh_id = p_cgh_id
		AND CGC.cgc_id= p_cgc_id
        AND CH.cgh_estado = '0001'
	ORDER BY CH.sec_descripcion ASC, CH.prg_mencion ASC, CGC.cgh_ciclo ASC, CHC.cur_descripcion ASC,
		CCG.ccg_grupo ASC, CGD.cgd_titular DESC, CGF.cgf_id ASC;
    
END$$

DELIMITER ;
;
