<?php 
  
  session_start();
  include_once '../../models/security/seguridad.php';

  $parametros = array();
  $parametros['opcion'] = '';

  if (isset($_POST['opcion'])) 
  {
    $parametros['opcion'] = $_POST['opcion'];
  }

  $Seguridad = new Seguridad();
  echo $Seguridad->opciones($parametros);

?>