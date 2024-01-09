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
if (isset($_GET['reporte'])){
    $reporte = $_GET['reporte'];
}
 
$datosJson = json_decode($datos);
$itemsEnviados = array();
$datosEnvio = new datosEnvio();

try {
    if($reporte == ''){
        $correo = new CorreoCargaHoraria();
        $pdf = new CredencialDocente();
        $rutaPdf = $pdf->generarCredencial($item->nombre,$item->documento,$item->codigo,$item->sem);
        $itemEnviado = $correo->enviarCredencial($item,$rutaPdf);
        
    }else{

    }
    foreach ($datosJson as $item) {
        $correo = new CorreoCargaHoraria();
        $pdf = new CredencialDocente();
        $rutaPdf = $pdf->generarCredencial($item->nombre,$item->documento,$item->codigo,$item->sem);
        $itemEnviado = $correo->enviarCredencial($item,$rutaPdf); 
        $itemsEnviados[] = $itemEnviado;
        unlink($rutaPdf);
        $correo->cerrarConexion();
    }
    $datosEnvio->save_reporte($itemsEnviados); 
} catch (Exception $ex) {
    die("Error: " . $ex);
}

echo json_encode($itemsEnviados);
?>