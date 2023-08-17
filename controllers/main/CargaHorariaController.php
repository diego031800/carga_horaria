<?php

  // session_start();
  include_once '../../models/main/CargaHoraria.php';

  $parametros = array();
  $parametros['opcion'] = '';
  
  if (isset($_POST['opcion'])) 
  {
    $parametros['opcion'] = $_POST['opcion'];
  }

  $CargaHoraria = new CargaHoraria();
  echo $CargaHoraria->opciones($parametros);

?>