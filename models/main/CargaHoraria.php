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
            $sql = "SELECT 
                        SEC.sec_id,
                        SEC.sec_descripcion
                    FROM PROGRAMACION.SEMESTRE_SECCION SSE
                    INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = SSE.sec_id
                    WHERE SSE.sem_id = 69";
            $datos = $this->con->return_query_sqlsrv($sql);
            $unidades = array();
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $unidades[] = $row;
            }
            $this->con->close_connection_sqlsrv();
            return json_encode($unidades);
        }
    }
?>