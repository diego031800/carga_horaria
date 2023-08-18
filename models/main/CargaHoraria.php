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
                case 'get_cbo_unidades':
                    echo $this->get_cbo_unidades();
                    break;
                case 'get_cbo_semestres':
                    echo $this->get_cbo_semestres();
                    break;
                case 'get_cbo_programa':
                    echo $this->get_cbo_programa();
                    break;
            }
        }

        private function get_cbo_semestres()
        {
            $sql = "SELECT 
                        SEM.sem_id,
                        UPPER(SEM.sem_nombre) as semestre
                    FROM ADMISION.SEMESTRE SEM
                    WHERE sem_estado = 1
                    ORDER BY SEM.sem_id DESC";
            $datos = $this->con->return_query_sqlsrv($sql);
            $semestres = "<option value=''>Selecciona un semestre ...</option>\n";
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $semestres .= "<option value=".$row['sem_id'].">".$row['semestre']."</option>\n";
            }
            $this->con->close_connection_sqlsrv();
            return $semestres;
        }

        private function get_cbo_unidades()
        {
            $sql = "SELECT
                        SEC.sec_id,
                        UPPER(SEC.sec_descripcion) as seccion
                    FROM PROGRAMACION.SEMESTRE_SECCION SSE
                    INNER JOIN ADMISION.SECCION SEC ON SSE.sec_id = SEC.sec_id
                    INNER JOIN SISTEMA.USUARIO_UNIDAD UUN ON UUN.sec_id = SSE.sec_id
                    WHERE SSE.sem_id = '".$this->parametros['sem_id']."' AND UUN.usu_id = '".$_SESSION['usu_id']."' AND SSE.sse_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $unidades = "";
            $has_data = 0;
            if (!empty($this->parametros['sem_id'])) {
                $has_data = 1;
                $unidades = "<option value=''>Selecciona una unidad ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $unidades .= "<option value=".$row['sec_id'].">".$row['seccion']."</option>\n";
                }
            } else {
                $unidades = "<option value=''>Primero selecciona un semestre ...</option>\n";
            }
            $resp = array('has_data' => $has_data,'unidades' => $unidades);
            return json_encode($resp);
        }

        private function get_cbo_programa()
        {
            $sql = "SELECT
                        SEC.sec_id,
                        SEC.sec_descripcion as seccion
                    FROM PROGRAMACION.SEMESTRE_SECCION SSE
                    INNER JOIN ADMISION.SECCION SEC ON SSE.sec_id = SEC.sec_id
                    INNER JOIN SISTEMA.USUARIO_UNIDAD UUN ON UUN.sec_id = SSE.sec_id
                    WHERE SSE.sem_id = '".$this->parametros['sem_id']."' AND UUN.usu_id = '".$_SESSION['usu_id']."' AND SSE.sse_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $unidades = "";
            $has_data = 0;
            if (!empty($this->parametros['sem_id'])) {
                $has_data = 1;
                $unidades = "<option value=''>Selecciona una unidad ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $unidades .= "<option value=".$row['sec_id'].">".$row['seccion']."</option>\n";
                }
            } else {
                $unidades = "<option value=''>Primero selecciona un semestre ...</option>\n";
            }
            $resp = array('has_data' => $has_data,'unidades' => $unidades);
            return json_encode($resp);
        }
    }
?>