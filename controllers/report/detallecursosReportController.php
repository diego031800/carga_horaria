<?php 
  session_start();
  include_once '../../models/report/detallecursosReport.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['sem_id'] = '';
  $parametros['p_uni_id'] = '';
  $parametros['p_pro_id'] = '';
  $parametros['p_cic_id'] = '';
  $parametros['p_cre_id'] = '';
  $parametros['p_cur_id'] = '';
  $parametros['p_gpo_id'] = '';
  $parametros['p_hrs'] = '';
  $parametros['p_doc'] = '';
  $parametros['p_fec'] = '';
  $parametros['p_cgd_id'] = '';

  if (isset($_GET['opcion'])) 
  {
    $parametros['opcion'] = $_GET['opcion'];
  }

  if (isset($_GET['sem_id'])) 
  {
    $parametros['sem_id'] = $_GET['sem_id'];
  }

  if (isset($_GET['p_uni_id'])) 
  {
    $parametros['p_uni_id'] = $_GET['p_uni_id'];
  }

  if (isset($_GET['p_pro_id'])) 
  {
    $parametros['p_pro_id'] = $_GET['p_pro_id'];
  }

  if (isset($_GET['p_cic_id'])) 
  {
    $parametros['p_cic_id'] = $_GET['p_cic_id'];
  }

  if (isset($_GET['p_cre_id'])) 
  {
    $parametros['p_cre_id'] = $_GET['p_cre_id'];
  }

  if (isset($_GET['p_cur_id'])) 
  {
    $parametros['p_cur_id'] = $_GET['p_cur_id'];
  }

  if (isset($_GET['p_gpo_id'])) 
  {
    $parametros['p_gpo_id'] = $_GET['p_gpo_id'];
  }

  if (isset($_GET['p_hrs'])) 
  {
    $parametros['p_hrs'] = $_GET['p_hrs'];
  }

  if (isset($_GET['p_doc'])) 
  {
    $parametros['p_doc'] = $_GET['p_doc'];
  }

  if (isset($_GET['p_fec'])) 
  {
    $parametros['p_fec'] = $_GET['p_fec'];
  }

  if (isset($_GET['p_cgd_id'])) 
  {
    $parametros['p_cgd_id'] = $_GET['p_cgd_id'];
  }

  $DetalleCursosReportes = new DetalleCursosReportes();
  echo $DetalleCursosReportes->opciones($parametros);
?>