<?php

  session_start();
  include_once '../../models/main/CargaHoraria.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['sem_id'] = '';
  $parametros['sec_id'] = '';
  
  if (isset($_POST['opcion'])) 
  {
    $parametros['opcion'] = $_POST['opcion'];
  }
  if (isset($_POST['sem_id'])) 
  {
    $parametros['sem_id'] = $_POST['sem_id'];
  }
  if (isset($_POST['sec_id'])) 
  {
    $parametros['sec_id'] = $_POST['sec_id'];
  }

  $CargaHoraria = new CargaHoraria();
  echo $CargaHoraria->opciones($parametros);

?>