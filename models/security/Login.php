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
                U.usu_login,
                PER.per_nombres + ' ' + PER.per_ape_paterno + ' ' + PER.per_ape_materno AS nombres
              FROM SISTEMA.USUARIO U 
              INNER JOIN SISTEMA.PERSONA PER ON PER.per_id = U.per_id
              WHERE U.usu_estado = 1 
                  AND U.usu_login = '" . $this->parametros['usuario'] . "'
                  AND U.usu_password = '" . $this->parametros['password'] . "'";
    $datos = $this->con->return_query_sqlsrv($sql);
    $resp = array();
    $usu_id = "";
    while ($fila = $datos->fetch(PDO::FETCH_ASSOC)) {
      $usu_id = $fila['usu_id'];
      $_SESSION['usu_id'] = $fila['usu_id'];
      $_SESSION['login'] = $fila['usu_login'];
      $_SESSION['nombres'] = $fila['nombres'];
      $_SESSION['usu_ip'] = $this->parametros['ip'];
      $_SESSION['permisos'] = $this->get_Permisos($usu_id);
      $_SESSION['id_pag_activa'] = 0;
    }
    if (!empty($usu_id)) {
      $resp = array('respuesta' => 'Acceso permitido');
    } else {
      $resp = array('respuesta' => 'Acceso no permitido');
    }
    return json_encode($resp);
  }

  private function get_Permisos($usu_id)
  {
    try {
      $sql = "SELECT chpp_id_pag FROM carga_horaria_pagina_permisos where chpp_id_usu =" . $usu_id . ";";
      $datos = $this->con->return_query_mysql($sql);
      $error = $this->con->error_mysql();
      $permisos = array();
      if (empty($error)) {
        while ($row = mysqli_fetch_array($datos)) {
          array_push($permisos, $row['chpp_id_pag']);
          error_log($row['chpp_id_pag']);
        }
      }
      error_log($sql);
      return $permisos;
    } catch (Exception $ex) {
      die("Error: " . $this->con->error_mysql(). $ex);  
    }
  }
}
