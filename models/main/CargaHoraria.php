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
                case 'get_cursos_by_ciclo':
                    echo $this->get_cursos_by_ciclo();
                    break;
                case 'get_docentes':
                    echo $this->get_docentes();
                    break;
                case 'saveCargaHoraria':
                    echo $this->saveCargaHoraria();
                    break;
            }
        }

        private function get_cbo_semestres()
        {
            $sql = "SELECT 
                        SEM.sem_id,
                        SEM.sem_codigo,
                        UPPER(SEM.sem_nombre) as semestre
                    FROM ADMISION.SEMESTRE SEM
                    WHERE sem_estado = 1 AND sem_activo = 1 
                    ORDER BY SEM.sem_id DESC";
            $datos = $this->con->return_query_sqlsrv($sql);
            $semestres = "<option value=''>Selecciona un semestre ...</option>\n";
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $semestres .= "<option value='".$row['sem_id']."' data-codigo='".$row['sem_codigo']."'>".$row['semestre']."</option>\n";
            }
            $this->con->close_connection_sqlsrv();
            return $semestres;
        }

        private function get_cbo_unidades()
        {
            $sql = "SELECT
                        SEC.sec_id,
                        UPPER(SEC.sec_descripcion) as seccion
                    FROM ADMISION.SECCION SEC
                    INNER JOIN SISTEMA.USUARIO_UNIDAD UUN ON UUN.sec_id = SEC.sec_id
                    WHERE UUN.usu_id = '".$_SESSION['usu_id']."' AND SEC.sec_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $unidades = "";
            $unidades = "<option value=''>Selecciona una unidad ...</option>\n";
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $unidades .= "<option value='".$row['sec_id']."'>".$row['seccion']."</option>\n";
            }
            return $unidades;
        }

        private function get_cbo_programas()
        {
            $sql = "SELECT
                        PRG.prg_id,
                        PRG.prg_mencion as programa
                    FROM ADMISION.PROGRAMA PRG
                    INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id
                    WHERE PRG.sec_id = '".$this->parametros['sec_id']."' AND PRG.prg_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $programas = "";
            $has_data = 0;
            if (!empty($this->parametros['sec_id'])) {
                $has_data = 1;
                $programas = "<option value=''>Selecciona un programa ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $programas .= "<option value='".$row['prg_id']."'>".$row['programa']."</option>\n";
                }
            } else {
                $programas = "<option value='SD'>Antes selecciona una unidad ...</option>\n";
            }
            $resp = array('has_data' => $has_data,'programas' => $programas);
            return json_encode($resp);
        }

        private function get_cursos_by_ciclo()
        {
            $sql = "SELECT 
                        CUR.cur_id,
                        CUR.cur_creditos,
                        CUR.cur_codigo,
                        UPPER(CUR.cur_descripcion) AS curso
                    FROM ADMISION.CURSO CUR
                    WHERE CUR.cur_ciclo = '".$this->parametros['ciclo']. "' AND CUR.cur_estado = 1
                    ORDER BY CUR.cur_descripcion ASC";
            $datos = $this->con->return_query_sqlsrv($sql);
            $cursos = "";
            $has_data = 0;
            if (!empty($this->parametros['ciclo'])) {
                $has_data = 1;
                $cursos = "<option value=''>Selecciona un curso ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $cursos .= "<option value='".$row['cur_id']."'>CÓDIGO: ".$row['cur_codigo']." | CRÉDITOS: ".$row['cur_creditos']." | ".$row['curso']."</option>\n";
                }
            } else {
                $cursos = "<option value='SD'>Antes selecciona un ciclo ...</option>\n";
            }
            $resp = array('has_data' => $has_data, 'cursos' => $cursos);
            return json_encode($resp);
        }

        private function get_docentes()
        {
            $sql = "SELECT
                        PRG.prg_id,
                        PRG.prg_mencion as programa
                    FROM ADMISION.PROGRAMA PRG
                    INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id
                    WHERE PRG.sec_id = '".$this->parametros['sec_id']."' AND PRG.prg_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $docentes = "";
            $has_data = 0;
            if (!empty($this->parametros['sec_id'])) {
                $has_data = 1;
                $programas = "<option value=''>Selecciona un programa ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $programas .= "<option value='".$row['prg_id']."'>".$row['programa']."</option>\n";
                }
            } else {
                $programas = "<option value='SD'>Antes selecciona una unidad ...</option>\n";
            }
            $resp = array('has_data' => $has_data,'programas' => $programas);
            return json_encode($resp);
        }

        private function saveCargaHoraria() 
        {
            try {
                $sql = "CALL sp_saveCargaHoraria(";
                $sql .= "'".$this->parametros['p_cgh_id']."', "; // p_cgh_id
                $sql .= "'".$this->parametros['p_cgh_codigo']."', "; // p_cgh_codigo
                $sql .= "'".$this->parametros['p_sem_id']."', "; // p_sem_id
                $sql .= "'".$this->parametros['p_sem_codigo']."', "; // p_sem_codigo
                $sql .= "'".$this->parametros['p_sem_descripcion']."', "; // p_sem_descripcion
                $sql .= "'".$this->parametros['p_sec_id']."', "; // p_sec_id
                $sql .= "'".$this->parametros['p_sec_descripcion']."', "; // p_sec_descripcion
                $sql .= "'".$this->parametros['p_prg_id']."', "; // p_prg_id
                $sql .= "'".$this->parametros['p_prg_mencion']."', "; // p_prg_mencion
                $sql .= "'".$this->parametros['p_cgh_ciclo']."', "; // p_cgh_ciclo
                $sql .= "'".$this->parametros['p_cgh_estado']."', "; // p_cgh_estado
                $sql .= "'".$_SESSION['usu_id']."');"; // p_usuario
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                $resp = "";
                $cgh_id = "";
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $resp = $row['respuesta'];
                        $cgh_id = $row['cgh_id'];
                    }
                }
                return json_encode(array('respuesta' => $resp, 'cgh_id' => $cgh_id));
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }
    }
?>