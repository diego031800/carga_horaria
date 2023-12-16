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

    public function opciones($parametros){
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

    private function get_usuarios(){
        try {
            //code...
        } catch (Exception $ex) {
            return json_encode(['respuesta' => 0, 'mensaje' => $this->con->error_mysql().$ex]);
        }
    }

}
