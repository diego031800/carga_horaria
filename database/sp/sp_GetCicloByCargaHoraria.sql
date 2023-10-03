DROP PROCEDURE IF EXISTS sp_GetCicloByCargaHoraria;

DELIMITER $$
CREATE PROCEDURE sp_GetCicloByCargaHoraria (
	IN p_cgh_id INT
)  
BEGIN  
	
    SELECT
		CGC.cgc_id,
        CGC.cgh_id,
        CGC.cgh_ciclo as ciclo,
        CGC.cgc_estado as estado
    FROM CARGA_HORARIA_CICLO CGC
    WHERE CGC.cgh_id = p_cgh_id
		AND CGC.cgc_estado = '0001';
    
END$$