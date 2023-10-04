DROP procedure IF EXISTS sp_getReporteEnvios;
DELIMITER $$
CREATE PROCEDURE sp_getReporteEnvios (
	IN p_sem_id INT, 
    IN p_sec_id INT, 
    IN p_prg_id INT
)

BEGIN  
	Select 
    chec_doc_nombre as Nombre,
    chec_doc_correo as Correo,
    chec_envio as Envio,
    chec_envio as Fecha,
    chec_envio_error as Error_Envio
    from carga_horaria_envio_credenciales CHEC
    where CHEC.sem_id = p_sem_id AND CHEC.sec_id = p_sec_id AND CHEC.prg_id = p_prg_id;
END
$$
DELIMITER ;
;