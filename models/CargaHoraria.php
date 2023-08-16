<?php
// Incluir el archivo de conexión
require_once './db_connection_get_data.php';

// Aquí puedes realizar tus consultas y operaciones en la base de datos usando la variable $db
// Ejemplo:
$query = "SELECT
            PRG.prg_mencion AS MENCION,
            SCU.scu_ciclo AS CICLO,
            CUR.cur_descripcion as CURSO,
            SCG.scg_grupo AS GRUPO,
            CUR.cur_creditos as CREDITOS,
            DOC.doc_ape_paterno + ' ' + DOC.doc_ape_materno + ' ' + DOC.doc_nombres as DOCENTE
        FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG
        INNER JOIN PROGRAMACION.SEMESTRE_CURSO SCU ON SCG.scu_id = SCU.scu_id
        INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
        INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD ON SCD.scg_id = SCG.scg_id
        INNER JOIN ADMISION.DOCENTE DOC ON DOC.doc_id = SCD.doc_id
        INNER JOIN PROGRAMACION.SEMESTRE_PROGRAMA SPR ON SPR.spr_id = SCU.spr_id
        INNER JOIN ADMISION.PROGRAMA PRG ON PRG.prg_id = SPR.prg_id
        INNER JOIN PROGRAMACION.SEMESTRE_SECCION SSE ON SSE.sse_id = SPR.sse_id
        INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = SSE.sec_id
        WHERE SCG.sem_id = 69 AND SCU.scu_estado = 1
        ORDER BY PRG.prg_mencion, SCU.scu_ciclo, CUR.cur_descripcion, DOC.doc_ape_paterno";
$result = sqlsrv_query($db, $query);

echo $result;
// Procesar los resultados...
?>