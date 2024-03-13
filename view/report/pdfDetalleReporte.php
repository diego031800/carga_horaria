<?php 
require_once('../../models/conexion.php');
require_once '../../vendor/autoload.php';

date_default_timezone_set('America/Lima');

session_start();
$sem = "";
$sem_id = 0;
$p_uni_id = 0;
$p_pro_id = 0;
$p_cic_id = 0;
$p_cre_id = 0;
$p_cur_id = 0;
$p_gpo_id = 0;
$p_hrs = 0;
$p_doc = 0;
$p_fec = 0;
error_log($sem_id);

if (isset($_GET['sem']) && isset($_GET['sem_id']) && isset($_GET['p_uni_id']) && isset($_GET['p_pro_id']) && isset($_GET['p_cic_id']) && isset($_GET['p_cre_id']) 
    && isset($_GET['p_cur_id']) && isset($_GET['p_gpo_id']) && isset($_GET['p_hrs']) && isset($_GET['p_doc']) && isset($_GET['p_fec'])) {
    $sem = $_GET['sem'];
    $sem_id = $_GET['sem_id'];
    $p_uni_id = $_GET['p_uni_id'];
    $p_pro_id = $_GET['p_pro_id'];
    $p_cic_id = $_GET['p_cic_id'];
    $p_cre_id = $_GET['p_cre_id'];
    $p_cur_id = $_GET['p_cur_id'];
    $p_gpo_id = $_GET['p_gpo_id'];
    $p_hrs = $_GET['p_hrs'];
    $p_doc = $_GET['p_doc'];
    $p_fec = $_GET['p_fec'];
}

error_log($sem_id);

function set_parametro($parametro){
    $resultado = "";
    if($parametro == 0){
        $resultado = "<> 0";
    }else{
        $resultado = "= ".$parametro;
    }
    return $resultado;
}

function get_data($sem_id, $p_uni_id, $p_pro_id, $p_cic_id, $p_cre_id, $p_cur_id, $p_gpo_id, $p_hrs, $p_doc, $p_fec) {
    $con = new connection();
    $sql = "
    select
        CH.sem_descripcion as 'Semestre',
        CH.sec_descripcion as 'Unidad',
        CH.prg_mencion as 'Programa',
        CHCI.cgh_ciclo as 'Ciclo',
        CHC.cur_descripcion as 'Nombre',
        CHC.cur_creditos as 'Creditos',
        case 
        when CHG.ccg_grupo = 1 then 'A' 
        when CHG.ccg_grupo = 2 then 'B' 
        else 'C' end AS 'Grupo',
        Min(CHGF.cgf_fecha) as 'Fecha Inicio',
        Max(CHGF.cgf_fecha) as 'Fecha Fin',
        CHC.chc_horas as 'Horas'
    FROM carga_horaria_curso_grupo CHG
    INNER JOIN carga_horaria_curso CHC ON CHG.chc_id = CHC.chc_id
    INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
    INNER JOIN carga_horaria_curso_grupo_docente CHGD ON CHGD.ccg_id = CHG.ccg_id
    INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
    INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
    WHERE CH.cgh_estado = '0001' AND  CHCI.cgc_estado = '0001' AND CHC.chc_estado = '0001' AND CHG.ccg_estado = '0001' AND CHGF.cgf_estado = '0001' AND CHGD.cgd_estado = '0001' 
    AND CH.sem_id ".set_parametro($sem_id)."
    AND CH.sec_id ".set_parametro($p_uni_id)."
    AND CH.prg_id ".set_parametro($p_pro_id)."
    AND CHCI.cgh_ciclo ".set_parametro($p_cic_id)."
    AND CHC.cur_creditos ".set_parametro($p_cre_id)."
    AND CHC.cur_id ".set_parametro($p_cur_id)."
    AND CHG.ccg_grupo ".set_parametro($p_gpo_id)."
    AND CHC.chc_horas ".set_parametro($p_hrs)."
    GROUP BY CHG.ccg_id
    HAVING 
    count(distinct CHGD.cgd_id) ".set_parametro($p_doc)."
    AND count(distinct CHGF.cgf_id) ".set_parametro($p_fec)."
    order by CH.sec_id;
    ";
    $data = array();
    $dato = [];
    $datos = $con->return_query_mysql($sql);
    $error = $con->error_mysql();
    if (empty($error)){
        error_log("Paso 1");
        while ($row = mysqli_fetch_array($datos)) {
            $dato['Semestre'] = $row['Semestre'];
            $dato['Unidad'] = $row['Unidad'];
            $dato['Programa'] = $row['Programa'];
            $dato['Ciclo'] = $row['Ciclo'];
            $dato['Nombre'] = $row['Nombre'];
            $dato['Creditos'] = $row['Creditos'];
            $dato['Grupo'] = $row['Grupo'];
            $dato['FechaInicio'] = $row['Fecha Inicio'];
            $dato['FechaFin'] = $row['Fecha Fin'];
            $dato['Horas'] = $row['Horas'];
            array_push($data, $dato);
        }
    }
    return $data;
}

$cabecera = "<header>
            <table style='width: 100%;'>
                <tbody>
                    <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                        <div style='text-align: center; font-weight: bold;'>
                        Reporte de cursos en el semestre: ".$sem."
                        </div> 
                    </td>
                    <td style='width: 30%;'></td>
                    </tr>
                </tbody>
            </table>
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
                        Reporte de cursos en el semestre: ".$sem."
                        </div> 
                    </td>
                    <td style='width: 30%;'></td>
                    </tr>
                </tbody>
            </table>
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
$data = get_data($sem_id, $p_uni_id, $p_pro_id, $p_cic_id, $p_cre_id, $p_cur_id, $p_gpo_id, $p_hrs, $p_doc, $p_fec);
//erro_log($data);
    foreach ($data as $dato) {
        $html .= "<tr>";
        //Numero
        $html .= "<td>".$contador."</td>"; 
        //Unidad
        $html .= "<td>".$dato['Unidad']."</td>";
        //Programa
        $html .= "<td>".$dato['Programa']."</td>";
        //Ciclo
        $html .= "<td>".$dato['Ciclo']."</td>";
        //Nombre
        $html .= "<td>".$dato['Nombre']."</td>";
        //Creditos
        $html .= "<td>".$dato['Creditos']."</td>"; 
        //Grupo
        $html .= "<td>".$dato['Grupo']."</td>";
        //FechaInicio
        $html .= "<td>".$dato['FechaInicio']."</td>";
        //FechaFin
        $html .= "<td>".$dato['FechaFin']."</td>";
        //Horas
        $html .= "<td>".$dato['Horas']."</td>";

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