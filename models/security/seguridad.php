<?php

include_once '../../models/conexion.php';

class Seguridad
{
    private $con;
    private $parametros = array();

    public function __construct()
    {
        $this->con = new connection();
    }

    public function opciones($parametros)
    {
        $this->parametros = $parametros;
        switch ($this->parametros['opcion']) {
            case 'value':
                # code...
                break;

            default:
                # code...
                break;
        }
    }

    private function get_usuarios()
    {
        try {
            $sql = "SELECT 
            U.usu_id, 
            U.usu_login,
            PER.per_nombres + ' ' + PER.per_ape_paterno + ' ' + PER.per_ape_materno AS nombres
          FROM SISTEMA.USUARIO U 
          INNER JOIN SISTEMA.PERSONA PER ON PER.per_id = U.per_id
          WHERE U.usu_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $usuarios = array();
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $usuario = $row['usuario'];
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta' => 0, 'mensaje' => $ex]);
        }
    }
}
