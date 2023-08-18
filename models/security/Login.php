<?php

  include_once '../../models/conexion.php';

  class Login
  {
    private $parametros = array();
    private $con;

    public function __construct()
    {
      $this->con = new connection();
    }

    public function opciones($parametros)
    {
      $this->parametros = $parametros;
      switch ($this->parametros['opcion']) {
        case 'login':
          echo $this->login();
          break;
      }
    }

    private function login()
    {
      $sql = "SELECT 
                U.usu_id, 
                U.usu_login 
              FROM SISTEMA.USUARIO U 
              WHERE U.usu_estado = 1 
                  AND U.usu_login = '".$this->parametros['usuario']."' 
                  AND U.usu_password = '".$this->parametros['password']."'";
      $datos = $this->con->return_query_sqlsrv($sql);
      $resp = array();
      $usu_id = "";
      while ($fila = $datos->fetch(PDO::FETCH_ASSOC))
      {
        $usu_id = $fila['usu_id'];
        $_SESSION['usu_id'] = $fila['usu_id'];
        $_SESSION['login'] = $fila['usu_login'];
      }
      if (!empty($usu_id)) {
        $resp = array('respuesta' => 'Acceso permitido');
      } else {
        $resp = array('respuesta' => 'Acceso no permitido');
      }
      return json_encode($resp);
    }
  }