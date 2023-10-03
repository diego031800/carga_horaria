<?php 

require_once '../../vendor/autoload.php';

date_default_timezone_set('America/Lima');

session_start();

$sem = '';
$sec = '';
$pro = '';
$datosDoc = array();

if (isset($_POST['semTxt']) && isset($_POST['secTxt']) && isset($_POST['prgTxt'])&& isset($_POST['docs'])) {
    $sem = $_POST['semTxt'];
    $sec = $_POST['secTxt'];
    $pro = $_POST['prgTxt'];
    $datosDoc = json_decode($_POST['docs']);
}

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
                    <tr>
                        <td class='bg-azul text-center' style='vertical-align: middle; width: 180px;' colspan='7'>
                        <b>PROGRAMA ACADÉMICO: &nbsp;&nbsp; ".$pro."</b>
                        </td>
                    </tr>
                </tbody>
            </table>";

    // Armado de la tabla donde 
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