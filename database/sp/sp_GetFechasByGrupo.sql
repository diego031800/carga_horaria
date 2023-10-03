DROP PROCEDURE IF EXISTS sp_GetFechasByGrupo;

DELIMITER $$
CREATE PROCEDURE sp_GetFechasByGrupo (
	IN p_ccg_id INT
)  
BEGIN  
	
    SELECT
		CGF.cgf_id,
		CGF.ccg_id,
        CGF.cgf_fecha as fecha,
        CGF.cgf_estado as estado
    FROM CARGA_HORARIA_CURSO_GRUPO_FECHA CGF
    WHERE CGF.ccg_id = p_ccg_id
		AND CGF.cgf_estado = '0001';
    
END$$