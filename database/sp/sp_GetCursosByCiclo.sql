DROP PROCEDURE IF EXISTS sp_GetCursosByCiclo;

DELIMITER $$
CREATE PROCEDURE sp_GetCursosByCiclo (
	IN p_cgc_id INT
)  
BEGIN  
	
    SELECT
		CHC.chc_id,
        CHC.cgc_id,
        CHC.cur_id,
		CHC.cur_codigo,
        CHC.cur_descripcion as curso,
        CHC.cur_ciclo,
        CHC.cur_creditos,
        CHC.cur_tipo,
        TP.nombre as tipo,
        CHC.cur_calidad,
        CC.nombre as calidad,
        CHC.chc_horas,
        CHC.chc_estado as estado
    FROM CARGA_HORARIA_CURSO CHC
    INNER JOIN V_TIPO_CURSO TP ON TP.valor = CHC.cur_tipo
    INNER JOIN V_CALIDAD_CURSO CC ON CC.valor = CHC.cur_calidad
    WHERE CHC.cgc_id = p_cgc_id
		AND CHC.chc_estado = '0001'
	ORDER BY CHC.cur_creditos DESC, CHC.cur_descripcion ASC;
    
END$$