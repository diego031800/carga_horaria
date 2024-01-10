<?php 

date_default_timezone_set('America/Lima');
include_once '../../controllers/main/enviarCorreos.php';
include_once '../../controllers/main/utilidades/pdfCredencial.php';
include_once '../../models/main/datosEnvio.php';
session_start();
$datos = '';
if (isset($_POST['docente'])) 
{
    $datos = $_POST['docente'];
}
$datosJson = json_decode($datos);
$datosEnvio = new datosEnvio();

try {
    $correo = new CorreoCargaHoraria();
    $pdf = new CredencialDocente();
    $rutaPdf = $pdf->generarCredencial($datosJson->nombre,$datosJson->documento,$datosJson->codigo,$datosJson->sem);
    $itemEnviado = $correo->enviarCredencial($datosJson,$rutaPdf);
    $respuesta = $datosEnvio->save_reporte_individual($itemEnviado);
    echo $respuesta;
} catch (Exception $ex) {
    echo json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
}

?>