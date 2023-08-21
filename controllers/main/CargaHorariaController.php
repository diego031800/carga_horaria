<?php

  session_start();
  include_once '../../models/main/CargaHoraria.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['sem_id'] = '';
  $parametros['sec_id'] = '';
  $parametros['prg_id'] = '';
  $parametros['ciclo'] = '';
  
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
  if (isset($_POST['prg_id'])) 
  {
    $parametros['prg_id'] = $_POST['prg_id'];
  }
  if (isset($_POST['ciclo'])) 
  {
    $parametros['ciclo'] = $_POST['ciclo'];
  }

  $CargaHoraria = new CargaHoraria();
  echo $CargaHoraria->opciones($parametros);

?>