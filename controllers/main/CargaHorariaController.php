<?php

  session_start();
  include_once '../../models/main/CargaHoraria.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['sem_id'] = '';
  $parametros['sec_id'] = '';
  $parametros['prg_id'] = '';
  $parametros['ciclo'] = '';

  // ENVIAR DATOS PARA GUARDAR
  $parametros['p_cgh_id'] = '';
  $parametros['p_cgh_codigo'] = '';
  $parametros['p_sem_id'] = '';
  $parametros['p_sem_codigo'] = '';
  $parametros['p_sem_descripcion'] = '';
  $parametros['p_sec_id'] = '';
  $parametros['p_sec_descripcion'] = '';
  $parametros['p_prg_id'] = '';
  $parametros['p_prg_mencion'] = '';
  $parametros['p_cgh_ciclo'] = '';
  $parametros['p_cgh_estado'] = '';
  
  
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
  // DATOS PARA GUARDAR
  if (isset($_POST['p_cgh_id'])) 
  {
    $parametros['p_cgh_id'] = $_POST['p_cgh_id'];
  }
  if (isset($_POST['p_cgh_codigo'])) 
  {
    $parametros['p_cgh_codigo'] = $_POST['p_cgh_codigo'];
  }
  if (isset($_POST['p_sem_id'])) 
  {
    $parametros['p_sem_id'] = $_POST['p_sem_id'];
  }
  if (isset($_POST['p_sem_codigo'])) 
  {
    $parametros['p_sem_codigo'] = $_POST['p_sem_codigo'];
  }
  if (isset($_POST['p_sem_descripcion'])) 
  {
    $parametros['p_sem_descripcion'] = $_POST['p_sem_descripcion'];
  }
  if (isset($_POST['p_sec_id'])) 
  {
    $parametros['p_sec_id'] = $_POST['p_sec_id'];
  }
  if (isset($_POST['p_sec_descripcion'])) 
  {
    $parametros['p_sec_descripcion'] = $_POST['p_sec_descripcion'];
  }
  if (isset($_POST['p_prg_id'])) 
  {
    $parametros['p_prg_id'] = $_POST['p_prg_id'];
  }
  if (isset($_POST['p_prg_mencion'])) 
  {
    $parametros['p_prg_mencion'] = $_POST['p_prg_mencion'];
  }
  if (isset($_POST['p_cgh_ciclo'])) 
  {
    $parametros['p_cgh_ciclo'] = $_POST['p_cgh_ciclo'];
  }
  if (isset($_POST['p_cgh_estado'])) 
  {
    $parametros['p_cgh_estado'] = $_POST['p_cgh_estado'];
  }

  $CargaHoraria = new CargaHoraria();
  echo $CargaHoraria->opciones($parametros);

?>