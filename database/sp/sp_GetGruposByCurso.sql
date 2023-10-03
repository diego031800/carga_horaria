DROP PROCEDURE IF EXISTS sp_GetGruposByCurso;

DELIMITER $$
CREATE PROCEDURE sp_GetGruposByCurso (
	IN p_chc_id INT
)  
BEGIN  
	
    SELECT
		CCG.ccg_id,
        CCG.chc_id,
        CCG.sem_id,
		CCG.prg_id,
        CCG.ccg_grupo as grupo,
        CCG.ccg_estado as estado
    FROM CARGA_HORARIA_CURSO_GRUPO CCG
    WHERE CCG.chc_id = p_chc_id
		AND CCG.ccg_estado = '0001';
    
END$$