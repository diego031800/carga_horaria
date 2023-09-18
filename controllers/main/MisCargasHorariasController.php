<?php

  session_start();
  include_once '../../models/main/MisCargasHorarias.php';

  /* PARAMETROS DE FILTRADO DE DATOS */
  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['p_sem_id'] = '';
  $parametros['p_sec_id'] = '';
  $parametros['p_prg_id'] = '';
  $parametros['p_ciclo'] = '';
  $parametros['p_fecha_inicio'] = '';
  $parametros['p_fecha_fin'] = '';

  /* VERIFICAR ENVIO DE DATOS */
  if (isset($_POST['opcion'])) 
  {
    $parametros['opcion'] = $_POST['opcion'];
  }
  if (isset($_POST['p_sem_id'])) 
  {
    $parametros['p_sem_id'] = $_POST['p_sem_id'];
  }
  if (isset($_POST['p_sec_id'])) 
  {
    $parametros['p_sec_id'] = $_POST['p_sec_id'];
  }
  if (isset($_POST['p_prg_id'])) 
  {
    $parametros['p_prg_id'] = $_POST['p_prg_id'];
  }
  if (isset($_POST['p_ciclo'])) 
  {
    $parametros['p_ciclo'] = $_POST['p_ciclo'];
  }
  if (isset($_POST['p_fecha_inicio'])) 
  {
    $parametros['p_fecha_inicio'] = $_POST['p_fecha_inicio'];
  }
  if (isset($_POST['p_fecha_fin'])) 
  {
    $parametros['p_fecha_fin'] = $_POST['p_fecha_fin'];
  }

  $MisCargasHorarias = new MisCargasHorarias();
  echo $MisCargasHorarias->opciones($parametros);

?>