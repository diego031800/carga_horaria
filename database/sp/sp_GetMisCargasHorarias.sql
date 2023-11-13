DROP procedure IF EXISTS sp_GetMisCargasHorarias;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE sp_GetMisCargasHorarias(
	IN p_sem_id INT,
    IN p_sec_id INT,
    IN p_prg_id INT,
    IN p_ciclo INT,
    IN p_usuario INT
)
BEGIN  

	SELECT 
		CH.cgh_id,
        CASE WHEN CH.cgh_codigo = '' OR CH.cgh_codigo IS NULL THEN
			'-' 
		ELSE CH.cgh_codigo END as codigo,
        CH.sem_id,
		CH.sem_codigo,
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.prg_id, 
        CH.prg_mencion as programa,
        CGC.cgc_id, 
        CGC.cgh_ciclo as ciclo,
        date_format(CH.fechahora, '%d/%m/%Y %h:%i %p') as creado,
        CASE WHEN CGC.fechahora_modificacion IS NULL THEN
			'SIN EDICIÓN'
		ELSE date_format(CGC.fechahora_modificacion, '%d/%m/%Y %h:%i %p') END as editado,
        CGC.cgc_estado as estado_id,
        ECH.nombre as estado,
        ECH.color,
        CGC.usuario,
        CGC.usuario_modificacion
    FROM CARGA_HORARIA CH
    INNER JOIN CARGA_HORARIA_CICLO CGC ON CGC.cgh_id = CH.cgh_id
    INNER JOIN V_ESTADOS_CARGA_HORARIA ECH ON ECH.valor = CGC.cgc_estado
    WHERE (CH.sem_id = p_sem_id)
		AND (CH.sec_id = p_sec_id)
		AND (CH.prg_id = p_prg_id OR p_prg_id = '')
        AND (CGC.cgh_ciclo = p_ciclo OR p_ciclo = '')
        -- AND CH.usuario = p_usuario;
	ORDER BY CH.prg_mencion ASC;
    
END$$

DELIMITER ;
;

