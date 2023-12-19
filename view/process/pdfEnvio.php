<?php 

require_once '../../vendor/autoload.php';
include_once '../../models/main/datosEnvio.php';

date_default_timezone_set('America/Lima');

session_start();

$sem = '';
$sec = '';
$pro = '';
$sem_id = '';
$sec_id = '';
$pro_id = '';
$report = 0;
$datosDoc = array();

if (isset($_POST['semTxt']) && isset($_POST['secTxt']) && isset($_POST['reporte'])) {
    $sem = $_POST['semTxt'];
    $sec = $_POST['secTxt'];
    $report = intval($_POST['reporte']);
    if($report == 0){
        if(isset($_POST['docs'])){
            $datosDoc = json_decode($_POST['docs']);
        }
    }else{
        if(isset($_POST['sem_id']) && isset($_POST['sec_id'])){
            $sem_id = $_POST['sem_id'];
            $sec_id = $_POST['sec_id'];
        }
        $datosEnvio = new datosEnvio();
        $datosDoc = $datosEnvio->get_ReporteEnvios(intval($sem_id), intval($sec_id));
    }
}

$cabecera = "<header>
            <table style='width: 100%;'>
                <tbody>
                    <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                        <div style='text-align: center; font-weight: bold;'>
                        Envío de credenciales en el semestre: ".$sem."
                        </div> 
                    </td>
                    <td style='width: 30%;'></td>
                    </tr>
                </tbody>
            </table>
        </header>
        <br>
        <body>
            <table class='table table-bordered'>
                <tbody>
                    <tr>
                        <td class='bg-azul text-center' colspan='7'><b>UNIDAD ACADÉMICA: &nbsp;&nbsp;".$sec."</b></td>
                    </tr>
                </tbody>
            </table>";

$html = "<header>
            <table style='width: 100%;'>
                <tbody>
                    <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                        <div style='text-align: center; font-weight: bold;'>
                        Envío de credenciales en el semestre: ".$sem."
                        </div> 
                    </td>
                    <td style='width: 30%;'></td>
                    </tr>
                </tbody>
            </table>
        </header>
        <br>
        <body>
            <table class='table table-bordered'>
                <tbody>
                    <tr>
                        <td class='bg-azul text-center' colspan='7'><b>UNIDAD ACADÉMICA: &nbsp;&nbsp;".$sec."</b></td>
                    </tr>
                </tbody>
            </table>";

    // Armado de la tabla donde 
    $inicioTabla = "<table class='table table-bordered' style='page-break-inside: avoid;'>
    <thead>
        <tr class='table-info'>
            <th class='text-center'>N°</th>
            <th class='text-center'>NOMBRES Y APELLIDOS</th>
            <th class='text-center'>CORREO</th>
            <th class='text-center'>ENVIADO</th>
            <th class='text-center'>FECHA ENVIO</th>
            <th class='text-center'>OCURRENCIA</th>
        </tr>
    </thead>
    <tbody>
    ";

    $html .= "<table class='table table-bordered' style='page-break-inside: avoid;'>
    <thead>
        <tr class='table-info'>
            <th class='text-center'>N°</th>
            <th class='text-center'>NOMBRES Y APELLIDOS</th>
            <th class='text-center'>CORREO</th>
            <th class='text-center'>ENVIADO</th>
            <th class='text-center'>FECHA ENVIO</th>
            <th class='text-center'>OCURRENCIA</th>
        </tr>
    </thead>
    <tbody>
    ";


    $registrosPorPagina = 15;
    $contador = 1; 
    foreach ($datosDoc as $key) {
        $html .= "<tr>";
        //Numero
        $html .= "<td>".$contador."</td>"; 
        //Nombre
        $html .= "<td>".$key->nombre."</td>"; 
        //Correo
        $html .= "<td>".$key->correo."</td>";
        //Envio correcto
        if ($key->envio == 1) {
            $html .= "<td>SI</td>";
        }else{
            $html .= "<td>NO</td>";
        }
        //Fecha de accion
        $html .= "<td>".$key->fechahora."</td>";
        //Descripcion de error
        if ($key->envio == ''){
            $html .= "<td>Todo correcto</td>";
        }else{
            $html .= "<td>".$key->error."</td>";
        }
        $html .= "</tr>";
        if ($contador == $registrosPorPagina) {
            $html .= "</tbody></table>
            <br>";
            $html .= $cabecera;
            $html .= $inicioTabla;
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
    $nombreArchivo = 'Prueba.pdf';

    // Output a PDF file directly to the browser with a specific filename
    echo $mpdf->Output($nombreArchivo, \Mpdf\Output\Destination::INLINE);
    //$mpdf->Output();
    exit;
?>