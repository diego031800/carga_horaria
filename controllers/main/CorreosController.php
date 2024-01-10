<?php 

date_default_timezone_set('America/Lima');
include_once '../../controllers/main/enviarCorreos.php';
include_once '../../controllers/main/utilidades/pdfCredencial.php';
include_once '../../models/main/datosEnvio.php';
session_start();
$datos = '';
$reporte = '';
if (isset($_POST['docentes'])) 
{
    $datos = $_POST['docentes'];
}
 
$datosJson = json_decode($datos);
$itemsEnviados = array();
$datosEnvio = new datosEnvio();

try {
    $correo = new CorreoCargaHoraria();
    $pdf = new CredencialDocente();
    $rutaPdf = $pdf->generarCredencial($datosJson->nombre,$datosJson->documento,$datosJson->codigo,$datosJson->sem);
    $itemEnviado = $correo->enviarCredencial($datosJson,$rutaPdf);
    $datosEnvio->save_reporte_individual($itemsEnviados);
    echo json_encode($itemEnviado);
} catch (Exception $ex) {
    die("Error: " . $ex);
}

?>