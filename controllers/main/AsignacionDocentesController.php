<?php

  session_start();
  include_once '../../models/main/AsignacionDocentes.php';

  /* PARAMETROS DE FILTRADO DE DATOS */
  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['p_sem_id'] = '';
  $parametros['p_sec_id'] = '';
  $parametros['p_docente'] = '';
  $parametros['p_doc_id'] = '';

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
  if (isset($_POST['p_doc_id'])) 
  {
    $parametros['p_doc_id'] = $_POST['p_doc_id'];
  }
  if (isset($_POST['p_docente'])) 
  {
    $parametros['p_docente'] = $_POST['p_docente'];
  }

  $AsignacionDocentes = new AsignacionDocentes();
  echo $AsignacionDocentes->opciones($parametros);

?>