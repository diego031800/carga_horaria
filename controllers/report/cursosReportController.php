<?php 
  session_start();
  include_once '../../models/report/cursosReport.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['sem_id'] = '';

  if (isset($_GET['opcion'])) 
  {
    $parametros['opcion'] = $_GET['opcion'];
  }
  if (isset($_GET['sem_id'])) 
  {
    $parametros['sem_id'] = $_GET['sem_id'];
  }

  $CursosReportes = new CursosReportes();
  echo $CursosReportes->opciones($parametros);
?>