<?php 

date_default_timezone_set('America/Lima');
include_once '../../models/report/enviocredencialesReport.php';
session_start();

$parametros = array();
$parametros['opcion_busqueda'] = '';
$parametros['sem_id'] = '';
$parametros['sec_id'] = '';
$parametros['is_asesor'] = '';
$parametros['fecha'] = '';
$parametros['month'] = '';
$parametros['year'] = '';

if (isset($_GET['opcion_busqueda'])) 
  {
    $parametros['opcion_busqueda'] = $_GET['opcion_busqueda'];
  }
  if (isset($_GET['sem_id'])) 
  {
    $parametros['sem_id'] = $_GET['sem_id'];
  }
  if (isset($_GET['sec_id'])) 
  {
    $parametros['sec_id'] = $_GET['sec_id'];
  }
  if (isset($_GET['is_asesor'])) 
  {
    $parametros['is_asesor'] = $_GET['is_asesor'];
  }
  if (isset($_GET['fecha'])) 
  {
    $parametros['fecha'] = $_GET['fecha'];
  }
  if (isset($_GET['month'])) 
  {
    $parametros['month'] = $_GET['month'];
  }
  if (isset($_GET['year'])) 
  {
    $parametros['year'] = $_GET['year'];
  }

  $datosEnvio = new datosEnvio();
  echo $datosEnvio->opciones_busqueda($parametros);




?>