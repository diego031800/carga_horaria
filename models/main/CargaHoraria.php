<?php

    include_once '../../models/conexion.php';

    class CargaHoraria
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
                case 'get_unidades':
                    echo $this->get_unidades();
                    break;
            }
        }

        private function get_unidades()
        {
            $sql = "CALL sp_get_unidades();";
            $datos = $this->con->return_query($sql);
            $unidades = array();
            foreach ($datos as $fila) {
                $unidades[] = $fila;
            }
            return json_encode($unidades);
        }
    }
?>