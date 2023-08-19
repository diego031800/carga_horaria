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
                case 'get_cbo_programas':
                    echo $this->get_cbo_programas();
                    break;
            }
        }

        private function get_cbo_semestres()
        {
            $sql = "SELECT 
                        SEM.sem_id,
                        UPPER(SEM.sem_nombre) as semestre
                    FROM ADMISION.SEMESTRE SEM
                    WHERE sem_estado = 1 /* AND sem_activo = 1 */
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
                $unidades = "<option value=''>Antes selecciona un semestre ...</option>\n";
            }
            $resp = array('has_data' => $has_data,'unidades' => $unidades);
            return json_encode($resp);
        }

        private function get_cbo_programas()
        {
            $sql = "SELECT
                        PRG.prg_id,
                        PRG.prg_mencion as programa
                    FROM PROGRAMACION.SEMESTRE_PROGRAMA SPR
                    INNER JOIN PROGRAMACION.SEMESTRE_SECCION SSE ON SSE.sse_id = SPR.sse_id
                    INNER JOIN ADMISION.PROGRAMA PRG ON PRG.prg_id = SPR.prg_id
                    WHERE SSE.sem_id = '".$this->parametros['sem_id']."' AND PRG.sec_id = '".$this->parametros['sec_id']."' AND PRG.prg_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $programas = "";
            $has_data = 0;
            if (!empty($this->parametros['sem_id']) && !empty($this->parametros['sec_id'])) {
                $has_data = 1;
                $programas = "<option value=''>Selecciona un programa ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $programas .= "<option value=".$row['prg_id'].">".$row['programa']."</option>\n";
                }
            } else {
                $programas = "<option value=''>Antes selecciona una unidad ...</option>\n";
            }
            $resp = array('has_data' => $has_data,'programas' => $programas);
            return json_encode($resp);
        }
    }
?>