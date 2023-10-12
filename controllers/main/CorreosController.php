<?php 

date_default_timezone_set('America/Lima');
include_once '../../controllers/main/enviarCorreos.php';
include_once '../../controllers/main/pdfCredencial.php';
include_once '../../models/main/datosEnvio.php';
session_start();
$datos = '';
if (isset($_POST['docentes'])) 
{
    $datos = $_POST['docentes'];
    //error_log($datos); 
}

$datosJson = json_decode($datos);
$itemsEnviados = array();
$datosEnvio = new datosEnvio();



function timer_diff($timeStart)
{
    return number_format(microtime(true) - $timeStart, 3);
}

try {
    foreach ($datosJson as $item) {
        $timeStart1 = microtime(true);
        $correo = new CorreoCargaHoraria();
        $pdf = new CredencialDocente();
        error_log("INICIO: ".timer_diff($timeStart1));
        $timeStart1 = microtime(true);
        $rutaPdf = $pdf->generarCredencial($item->nombre,$item->codigo,$item->documento,$item->sem);
        error_log("GENERAR PDF: ".timer_diff($timeStart1));
        $timeStart1 = microtime(true);
        $itemEnviado = $correo->enviarCredencial($item,$rutaPdf); 
        error_log("ENVIAR CORREO: ".timer_diff($timeStart1));
        $timeStart1 = microtime(true);
        $itemsEnviados[] = $itemEnviado;
        error_log("FIN: ".timer_diff($timeStart1));
        $timeStart1 = microtime(true);
        unlink($rutaPdf);
        $correo->cerrarConexion();
    }
    $datosEnvio->save_reporte($itemsEnviados); 
} catch (Exception $ex) {
    die("Error: " . $ex);
}

echo json_encode($itemsEnviados);
?>