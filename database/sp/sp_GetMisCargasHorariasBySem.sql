DROP procedure IF EXISTS sp_GetMisCargasHorariasBySem;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE sp_GetMisCargasHorariasBySem(
	IN p_sem_id INT, 
    IN p_sec_id INT, 
    IN p_usuario INT, 
    IN p_unidades JSON
)
BEGIN  
	DECLARE i INT DEFAULT 0;
	DECLARE total_elementos INT;
	DECLARE unidad JSON; 
    DECLARE unidad_id INT;

	SET total_elementos = JSON_LENGTH(p_unidades);
	
    DROP TEMPORARY TABLE IF EXISTS UNIDADES_TEMP;
	CREATE TEMPORARY TABLE UNIDADES_TEMP (sec_id INT);
    
    WHILE i < total_elementos DO
		SET unidad = JSON_UNQUOTE(JSON_EXTRACT(p_unidades, CONCAT('$[', i, ']')));
        SET unidad_id = JSON_UNQUOTE(JSON_EXTRACT(unidad, '$.unidad_id'));
		INSERT INTO UNIDADES_TEMP VALUES (unidad_id);
		SET i = i + 1;
	END WHILE;
    
    SELECT
		CASE WHEN CH.cgh_codigo = '' OR CH.cgh_codigo IS NULL THEN
			'-' 
		ELSE CH.cgh_codigo END as codigo,
        CH.sem_id,
		CH.sem_codigo,
        CH.sem_descripcion as semestre,
        CH.sec_id,
        CH.sec_descripcion as unidad,
        CH.cgh_estado as estado_id,
        ECH.nombre as estado,
        ECH.color,
        CH.usuario
    FROM CARGA_HORARIA CH
    INNER JOIN V_ESTADOS_CARGA_HORARIA ECH ON ECH.valor = CH.cgh_estado
    INNER JOIN UNIDADES_TEMP UTE ON UTE.sec_id = CH.sec_id
    WHERE (CH.sem_id = p_sem_id OR p_sem_id = '')
		AND (CH.sec_id = p_sec_id OR p_sec_id = '')
	GROUP BY CH.cgh_codigo, CH.sem_id, CH.sem_codigo, CH.sem_descripcion, CH.sec_id, CH.sec_descripcion,
		CH.cgh_estado, ECH.nombre, ECH.color, CH.usuario
	ORDER BY CH.fechahora DESC;
    
END$$

DELIMITER ;
;

