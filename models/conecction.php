<?php 
	require_once 'config.php';

	function conectar()
	{
		$conexion = new mysqli(HOST_MYSQL, USER_NAME_MYSQL, PASS_MYSQL, DB_NAME_MYSQL);

		$conexion->query("SET CHARACTER SET UTF8");

		return $conexion;
	}
