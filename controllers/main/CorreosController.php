<?php 

date_default_timezone_set('America/Lima');
include_once '../../controllers/main/enviarCorreos.php';
include_once '../../controllers/main/utilidades/pdfCredencial.php';
include_once '../../models/main/datosEnvio.php';
session_start();
$datos = '';
$p_is_asesor = '';
if (isset($_POST['docente'])) 
{
    $datos = $_POST['docente'];
}
if (isset($_POST['p_is_asesor'])) 
{
    $p_is_asesor = $_POST['p_is_asesor'];
}
$datosJson = json_decode($datos);
$datosEnvio = new datosEnvio();

try {
    $correo = new CorreoCargaHoraria();
    $pdf = new CredencialDocente();
    $rutaPdf = $pdf->generarCredencial($datosJson->nombre,$datosJson->documento,$datosJson->codigo,$datosJson->sem);
    $itemEnviado = $correo->enviarCredencial($datosJson,$rutaPdf);
    $respuesta = $datosEnvio->save_reporte_individual($itemEnviado,$p_is_asesor);
    echo $respuesta;
} catch (Exception $ex) {
    echo json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
}

?>