<?php 

include_once '../../controllers/main/enviarCorreos.php';
session_start();
$datos = '';
if (isset($_POST['docentes'])) 
{
    $datos = $_POST['docentes'];
    //error_log($datos); 
}

//error_log($datos);
 
$correo = new CorreoCargaHoraria();
echo $correo->enviarCredenciales($datos);
?>