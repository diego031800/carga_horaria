<?php 

date_default_timezone_set('America/Lima');
include_once '../../controllers/main/enviarCorreos.php';
include_once '../../models/main/datosEnvio.php';
session_start();
$sem_id = '';
$cgh_id = '';
if (isset($_POST['sem_id'])) 
{
    $sem_id = $_POST['docentes'];
}if (isset($_POST['chg_id'])) 
{
    $cgh_id = $_POST['docentes'];
}

$rutaPDFCarga ='';

?>