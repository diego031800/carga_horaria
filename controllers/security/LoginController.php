<?php

  session_start();
  include_once '../../models/security/Login.php';

  $parametros = array();
  $parametros['opcion'] = '';
  $parametros['usuario'] = '';
  $parametros['password'] = '';
  $parametros['ip'] = '';

  if(isset($_POST['opcion']))
	{
		$parametros['opcion'] = $_POST['opcion'];
	}
	if(isset($_POST['usuario']))
	{
		$parametros['usuario'] = $_POST['usuario'];
	}
	if(isset($_POST['password']))
	{
		$parametros['password'] = $_POST['password'];
	}
	if(isset($_POST['ip']))
	{
		$parametros['ip'] = $_POST['ip'];
	}

  $login = new Login();
  echo $login->opciones($parametros);