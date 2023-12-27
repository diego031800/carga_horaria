<?php 
  
  session_start();
  include_once '../../models/security/seguridad.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['id_usu'] = '';
  $parametros['permisos_usu'] = '';

  if (isset($_POST['opcion'])) 
  {
    $parametros['opcion'] = $_POST['opcion'];
  }
  if (isset($_POST['id_usu'])) 
  {
    $parametros['id_usu'] = $_POST['id_usu'];
  }
  if (isset($_POST['permisos_usu'])) 
  {
    $parametros['permisos_usu'] = $_POST['permisos_usu'];
  }

  $Seguridad = new Seguridad();
  echo $Seguridad->opciones($parametros);

?>