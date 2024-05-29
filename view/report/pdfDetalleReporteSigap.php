<?php 
require_once('../../models/conexion.php');
require_once '../../vendor/autoload.php';

date_default_timezone_set('America/Lima');

session_start();
$p_sem_id = 0;
$p_sem_txt = "";
$p_uni_id = 0;
$p_uni_txt = 0;
$p_pro_id = 0;
$p_pro_txt = 0;
$p_cic = 0;
$p_cre = 0;
$p_cur_id = 0;
$p_gpo_id = 0;
$p_gpo = 0;
$p_hrs = 0;
$p_doc = 0;
$p_fec = 0;

$p_datos_cursos =  array();

$subtitulo_unidad = "Unidad: ";
$subtitulo_programa = "Programa: ";
$subtitulo_ciclo = "Ciclo: ";
$subtitulo_creditos = "Cantidad de creditos: ";
$subtitulo_id_curso = "Id de curso: ";
$subtitulo_grupo = "Grupo: ";
$subtitulo_cant_horas = "Cantidad de horas: ";
$subtitulo_docentes = "Cantidad de docentes: ";
$subtitulo_fechas = "Cantidad de fechas: ";

if (isset($_GET['p_sem_id']) && isset($_GET['p_sem_txt']) && isset($_GET['p_uni_id']) && isset($_GET['p_uni_txt']) && isset($_GET['p_pro_id']) && isset($_GET['p_pro_txt']) && isset($_GET['p_cic'])
&& isset($_GET['p_cre'])  && isset($_GET['p_cur_id']) && isset($_GET['p_gpo_id']) && isset($_GET['p_gpo']) && isset($_GET['p_hrs']) && isset($_GET['p_doc']) && isset($_GET['p_fec'])) {
    $p_sem_id = $_GET['p_sem_id'];
    $p_sem_txt = $_GET['p_sem_txt'];
    $p_uni_id = $_GET['p_uni_id'];
    $p_uni_txt = $_GET['p_uni_txt'];
    $p_pro_id = $_GET['p_pro_id'];
    $p_pro_txt = $_GET['p_pro_txt'];
    $p_cic = $_GET['p_cic'];
    $p_cre = $_GET['p_cre'];
    $p_cur_id = $_GET['p_cur_id'];
    $p_gpo_id = $_GET['p_gpo_id'];
    $p_gpo = $_GET['p_gpo'];
    $p_hrs = $_GET['p_hrs'];
    $p_doc = $_GET['p_doc'];
    $p_fec = $_GET['p_fec'];
}


function set_titulos($parametro_id, $parametro, $subtitulo, $array){
    if($parametro_id != 0){
        $item = new stdClass();
        $item->parametro = $parametro;
        $item->subtitulo = $subtitulo;
        return $item;
    }
}

function set_titulos_1($parametro_id, $parametro, $subtitulo){
    $item = "";
    if($parametro_id != 0){
        $item = "<span>".$subtitulo.$parametro."</span><br>";
    }
    return $item;
}

$subtitulo = "";
$subtitulo .=set_titulos_1($p_uni_id,$p_uni_txt,$subtitulo_unidad);
$subtitulo .=set_titulos_1($p_pro_id,$p_pro_txt,$subtitulo_programa);
$subtitulo .=set_titulos_1($p_cic,$p_cic,$subtitulo_ciclo);
$subtitulo .=set_titulos_1($p_cre,$p_cre,$subtitulo_creditos);
$subtitulo .=set_titulos_1($p_cur_id,$p_cur_id,$subtitulo_id_curso);
$subtitulo .=set_titulos_1($p_gpo_id,$p_gpo,$subtitulo_grupo);
$subtitulo .=set_titulos_1($p_hrs,$p_hrs,$subtitulo_cant_horas);
$subtitulo .=set_titulos_1($p_doc,$p_doc,$subtitulo_docentes);
$subtitulo .=set_titulos_1($p_fec,$p_fec,$subtitulo_fechas);

error_log($subtitulo);

function get_data($p_sem_id,$p_uni_id, $p_pro_id, $p_cic, $p_cre, $p_cur_id, $p_gpo_id, $p_hrs, $p_doc, $p_fec) {
    $con = new connection();
        $sql = "
        SELECT DISTINCT
        SEM.sem_nombre as Semestre,
            UPPER(SEC.sec_descripcion) as Unidad,
            PRG.prg_mencion as Programa,
            MCU.mcu_ciclo as Ciclo,
            CUR.cur_descripcion as Nombre,
            CUR.cur_creditos as Creditos,
            CASE WHEN SCG.scg_grupo = 1 THEN 'A' WHEN SCG.scg_grupo = 2 THEN 'B' END as Grupo,
            MIN(SCC.scc_fecha) as FecINI,
            MAX(SCC.scc_fecha) as FecFIN,
            CASE WHEN SCG.scg_envio_estado = 1 THEN 'SIN ENVIAR NOTAS' WHEN SCG.scg_envio_estado = 2 THEN 'CERRADO' END AS ESTADO,
            P1.scd_horas as 'Horas'
        FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG
        INNER JOIN PROGRAMACION.SEMESTRE_CURSO SCU ON SCU.scu_id = SCG.scu_id
        INNER JOIN PROGRAMACION.SEMESTRE_PROGRAMA SPR ON SPR.spr_id = SCU.spr_id
        INNER JOIN PROGRAMACION.SEMESTRE_SECCION SSE ON SSE.sse_id = SPR.sse_id
        INNER JOIN PROGRAMACION.SEMESTRE_CURSO_CLASE SCC ON SCC.scg_id = SCG.scg_id
        INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = SSE.sec_id
        INNER JOIN ADMISION.MATRICULA_CURSO MCU ON MCU.scg_id = SCG.scg_id
        INNER JOIN ADMISION.MATRICULA MAT ON MAT.mat_id = MCU.mat_id
        INNER JOIN CONTABILIDAD.CRONOGRAMA_PAGO CRP ON CRP.mat_id = MAT.mat_id
        INNER JOIN CONTABILIDAD.PAGO PAG ON PAG.crp_id = CRP.crp_id
        INNER JOIN CONTABILIDAD.VOUCHER VOU ON VOU.vou_id = PAG.vou_id
        INNER JOIN ADMISION.PROGRAMA PRG ON PRG.prg_id = SCG.prg_id
        INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
        INNER JOIN ADMISION.SEMESTRE SEM ON SEM.sem_id = SCG.sem_id
        LEFT JOIN ADMISION.DOCENTE DOC ON DOC.doc_id = SCG.scg_docente
        INNER JOIN (SELECT SCG.scg_id, SUM(SCD.scd_horas) AS scd_horas, COUNT(SCD.doc_id) as 'Docs'  FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG 
        INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD on SCD.scg_id = SCG.scg_id GROUP BY SCG.scg_id) P1 ON P1.scg_id = SCG.scg_id
        INNER JOIN (SELECT SCG.scg_id, COUNT(SCC.scc_id) as 'fechas'  FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG  
        INNER JOIN PROGRAMACION.SEMESTRE_CURSO_CLASE SCC ON SCC.scg_id = SCG.scg_id GROUP BY SCG.scg_id) P2 ON P2.scg_id = SCG.scg_id
        WHERE SEM.sem_id = ".$p_sem_id."
        AND SEC.sec_id ".set_parametro($p_uni_id)."
        AND PRG.prg_id ".set_parametro($p_pro_id)."
        AND MCU.mcu_ciclo ".set_parametro($p_cic)."
        AND CUR.cur_creditos ".set_parametro($p_cre)."
        AND CUR.cur_id ".set_parametro($p_cur_id)."
        AND SCG.scg_grupo ".set_parametro($p_gpo_id)."
        AND P1.scd_horas ".set_parametro($p_hrs)."
        AND P1.Docs ".set_parametro($p_doc)."
        AND P2.fechas ".set_parametro($p_fec)."
        AND SCG.scg_estado = 1
        AND (VOU.vou_monto_usado = SEM.sem_monto_doctorado_matricula OR VOU.vou_monto_usado = SEM.sem_monto_maestria_matricula)
        AND VOU.vou_usu_verificado IS NOT NULL AND VOU.vou_estado = 5 
        AND (CUR.cur_descripcion NOT IN('INVESTIGACIÓN III', 'INVESTIGACIÓN IV', 'INVESTIGACIÓN V', 'INVESTIGACIÓN VI')
        AND CUR.cur_descripcion NOT IN('TESIS I', 'TESIS II', 'TESIS III'))
        GROUP BY SEM.sem_nombre, SEC.sec_descripcion,PRG.prg_mencion, SCG.scg_id, MCU.mcu_ciclo, CUR.cur_descripcion, CUR.cur_creditos, SCG.scg_grupo,
        SCG.scg_envio_estado, P1.scd_horas
        ORDER BY UPPER(SEC.sec_descripcion) DESC;";
        $data = array();
        $datos = $con->return_query_sqlsrv($sql);
        while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
            $dato = new stdClass();
            $dato->Semestre = $row['Semestre'];
            $dato->Unidad = $row['Unidad'];
            $dato->Programa = $row['Programa'];
            $dato->Ciclo = $row['Ciclo'];
            $dato->Nombre = $row['Nombre'];
            $dato->Creditos = $row['Creditos'];
            $dato->Grupo = $row['Grupo'];
            $dato->FechaInicio = $row['FecINI'];
            $dato->FechaFin = $row['FecFIN'];
            $dato->Horas = $row['Horas'];
            $data[] = $dato;
        }
        return $data;
}



function set_parametro($parametro){
    $resultado = "";
    if($parametro == 0){
        $resultado = "<> 0";
    }else{
        $resultado = "= ".$parametro;
    }
    return $resultado;
}


$cabecera = "<header>
            <table style='width: 100%;'>
                <tbody>
                    <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                        <div style='text-align: center; font-weight: bold;'>
                        Reporte de cursos en el semestre: ".$p_sem_txt."
                        </div> 
                    </td>
                    <td style='width: 30%;'></td>
                    </tr>
                </tbody>
            </table>
            <br>".$subtitulo."
        </header>
        <br>
        <body>";

$html = "<header>
            <table style='width: 100%;'>
                <tbody>
                    <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                        <div style='text-align: center; font-weight: bold;'>
                        Reporte de cursos en el semestre: ".$p_sem_txt."
                        </div> 
                    </td>
                    <td style='width: 30%;'></td>
                    </tr>
                </tbody>
            </table>
            <br>".$subtitulo."
        </header>
        <br>
        <body>";
        
$inicioTabla = "<table class='table table-bordered' style='page-break-inside: avoid;'>
    <thead>
        <tr class='table-info'>
        <th class='text-center'>N°</th>
        <th class='text-center'>UNIDAD</th>
        <th class='text-center'>PROGRAMA</th>
        <th class='text-center'>CICLO</th>
        <th class='text-center'>NOMBRE</th>
        <th class='text-center'>CREDITOS</th>
        <th class='text-center'>GRUPO</th>
        <th class='text-center'>FECHA INICIO</th>
        <th class='text-center'>FECHA FIN</th>
        <th class='text-center'>HORAS</th>
        </tr>
    </thead>
    <tbody>
    ";

$html .= "<table class='table table-bordered' style='page-break-inside: avoid;'>
    <thead>
        <tr class='table-info'>
        <th class='text-center'>N°</th>
        <th class='text-center'>UNIDAD</th>
        <th class='text-center'>PROGRAMA</th>
        <th class='text-center'>CICLO</th>
        <th class='text-center'>NOMBRE</th>
        <th class='text-center'>CREDITOS</th>
        <th class='text-center'>GRUPO</th>
        <th class='text-center'>FECHA INICIO</th>
        <th class='text-center'>FECHA FIN</th>
        <th class='text-center'>HORAS</th>
        </tr>
    </thead>
    <tbody>
    ";

    
$registrosPorPagina = 10;
$registroContado = 1;
$contador = 1; 
$data = array();

$data = get_data($p_sem_id,$p_uni_id, $p_pro_id, $p_cic, $p_cre, $p_cur_id, $p_gpo_id, $p_hrs, $p_doc, $p_fec);
//erro_log($data);
    foreach ($data as $dato) {
        $html .= "<tr>";
        //Numero
        $html .= "<td>".$contador."</td>"; 
        //Unidad
        $html .= "<td>".$dato->Unidad."</td>";
        //Programa
        $html .= "<td>".$dato->Programa."</td>";
        //Ciclo
        $html .= "<td>".$dato->Ciclo."</td>";
        //Nombre
        $html .= "<td>".$dato->Nombre."</td>";
        //Creditos
        $html .= "<td>".$dato->Creditos."</td>"; 
        //Grupo
        $html .= "<td>".$dato->Grupo."</td>";
        //FechaInicio
        $html .= "<td>".$dato->FechaInicio."</td>";
        //FechaFin
        $html .= "<td>".$dato->FechaFin."</td>";
        //Horas
        $html .= "<td>".$dato->Horas."</td>";

        $html .= "</tr>";
        if ($registroContado == $registrosPorPagina) {
            $html .= "</tbody></table><pagebreak />";
            $html .= $cabecera;
            $html .= $inicioTabla;
            $registroContado = 1;
        }else{
            $registroContado++;
        }
        
        $contador++;
    }

    $html .= "</tbody></table>";
    $mpdf = new \Mpdf\Mpdf();
    $mpdf->defaultfooterline = 0;
    // Definir contenido para el pie de página
    $footerContent = '<footer style="border-top: solid black 1px; text-align: left; font-size: 10px; position: fixed; bottom: 0; font-weight: bold;">
                        
                      </footer>
                      <hr>
                      <div style="text-align: center; font-size: 10px;">
                          Página {PAGENO}/{nbpg} - Generado el ' . date('d-m-Y') . '
                      </div>';

    // Configurar el pie de página
    $mpdf->SetFooter($footerContent);

    // $stylesheet = file_get_contents('../css/process/kv-mpdf-bootstrap.css');
    $stylesheet1 = file_get_contents('../css/process/pdfCargaHoraria.css');

    // $mpdf->WriteHTML($stylesheet,\Mpdf\HTMLParserMode::HEADER_CSS);
    $mpdf->WriteHTML($stylesheet1,\Mpdf\HTMLParserMode::HEADER_CSS);

    // Write some HTML code:
    $mpdf->WriteHTML($html, \Mpdf\HTMLParserMode::HTML_BODY);

    // Nombre del archivo PDF
    $nombreArchivo = 'ReporteCursos.pdf';

    // Output a PDF file directly to the browser with a specific filename
    echo $mpdf->Output($nombreArchivo, \Mpdf\Output\Destination::INLINE);
    //$mpdf->Output();
    exit;
?>