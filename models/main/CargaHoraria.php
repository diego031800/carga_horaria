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
                case 'buscar_carga_horaria':
                    echo $this->buscar_carga_horaria();
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
                    WHERE sem_estado = 1/*  AND sem_activo = 1  */
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
                        CUR.cur_ciclo,
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
                    $cursos .= "<option value='".$row['cur_id']."' data-nombre='".$row['curso']."' data-codigo='".$row['cur_codigo'];
                    $cursos .= "' data-ciclo='".$row['cur_ciclo']."' data-creditos='".$row['cur_creditos']."'>CÓDIGO: ".$row['cur_codigo'];
                    $cursos .= " | CRÉDITOS: ".$row['cur_creditos']." | ".$row['curso']."</option>\n";
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
                        DOC.doc_id,
                        UPPER(DOC.doc_ape_paterno) + ' ' + UPPER(DOC.doc_ape_materno) + ' ' + UPPER(DOC.doc_nombres) AS docente,
                        DOC.doc_grado,
                        DOC.doc_email,
                        DOC.doc_codigo,
                        DOC.doc_documento,
                        DOC.doc_celular
                    FROM ADMISION.DOCENTE DOC
                    WHERE DOC.doc_estado = 1
                    ORDER BY DOC.doc_ape_paterno, DOC.doc_ape_materno, DOC.doc_nombres ASC";
            $datos = $this->con->return_query_sqlsrv($sql);
            $docentes = "<option value=''>Selecciona un docente ...</option>\n";
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $docentes .= "<option value='".$row['doc_id']."' data-email='".$row['doc_email']."' data-codigo='".$row['doc_codigo'];
                $docentes .= "' data-documento='".$row['doc_documento']."' data-celular='".$row['doc_celular']."'>".$row['docente']."</option>\n";;
            }
            return $docentes;
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
                $respDetalle = array();
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        if ($row['respuesta'] == 1 && !empty($row['cgh_id'])) {
                            $respDetalle = $this->saveCargaHorariaCursos($row['cgh_id']);
                            return json_encode($respDetalle);
                            foreach ($respDetalle[0] as $value) {
                                if ($value['respuesta'] == 0) {
                                    return json_encode(['respuesta' => $value['respuesta'], 'mensaje' => $value['mensaje']]);
                                }
                            }
                            foreach ($respDetalle[1] as $value) {
                                if ($value['respuesta'] == 0) {
                                    return json_encode(['respuesta' => $value['respuesta'], 'mensaje' => $value['mensaje']]);
                                }
                            }
                            return json_encode(['respuesta' => $row['respuesta'], 'mensaje' => 'La carga horaria se guardo exitosamente.']);
                        } else {
                            return json_encode(array('respuesta' => $row['respuesta'], 'mensaje' => $row['mensaje'], 'cgh_id' => $row['cgh_id']));
                        }
                    }
                } else {
                    return json_encode(array('respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar la carga horaria '.$error));
                }
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }

        private function saveCargaHorariaCursos($cgh_id)
        {
            try {
                $cursos = json_decode($this->parametros['p_cursos']);
                $resp = array();
                foreach ($cursos as $curso) {
                    $this->con->close_open_connection_mysql();
                    $sql = "CALL sp_saveCargaHorariaCursos(";
                    $sql .= "'".$curso->chc_id."', "; // p_chc_id
                    $sql .= "'".$cgh_id."', "; // p_cgh_id
                    $sql .= "'".$curso->index."', "; // p_cur_id
                    $sql .= "'".$curso->cur_codigo."', "; // p_cur_codigo
                    $sql .= "'".$curso->curso."', "; // p_cur_descripcion
                    $sql .= "'".$curso->cur_ciclo."', "; // p_cur_ciclo
                    $sql .= "'".$curso->cur_creditos."', "; // p_cur_creditos
                    $sql .= "'".$curso->horas."', "; // p_chc_horas
                    $sql .= "'0001', "; // p_chc_estado
                    $sql .= "'".$_SESSION['usu_id']."');"; // p_usuario
                    // return $sql;
                    $datos = $this->con->return_query_mysql($sql);
                    $error = $this->con->error_mysql();
                    if (empty($error)) {
                        while ($row = mysqli_fetch_array($datos)) {
                            if ($row['respuesta'] == 1 && !empty($row['chc_id'])) {
                                array_push($resp, $this->saveCargaHorariaCursosFechas($row['chc_id'], $curso));
                                array_push($resp, $this->saveCargaHorariaCursosDocentes($row['chc_id'], $curso));
                            } else {
                                return [array('respuesta' => 0, 'mensaje' => 'No se pudo guardar el curso id:'.$curso->index.' curso: '.$curso->curso)];
                            }
                        }
                    } else {
                        return [array('respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar un curso '.$error)];
                    }
                }
                return $resp;
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function saveCargaHorariaCursosFechas($chc_id, $curso)
        {
            try {
                $fechas = $curso->fechas;
                $resp = array();
                foreach ($fechas as $fecha) {
                    $this->con->close_open_connection_mysql();
                    $sql = "CALL sp_saveCargaHorariaFechas(";
                    $sql .= "'".$fecha->p_chf_id."', "; // p_chf_id
                    $sql .= "'".$chc_id."', "; // p_chc_id
                    $sql .= "'".date('Y-m-d', strtotime(str_replace('/', '-', $fecha->fecha)))."', "; // p_chf_fecha
                    $sql .= "NULL, "; // p_chf_hora_inicio
                    $sql .= "NULL, "; // p_chf_hora_fin
                    $sql .= "NULL, "; // p_chf_horas
                    $sql .= "'0001', "; // p_chf_estado
                    $sql .= "'".$_SESSION['usu_id']."');"; // p_usuario
                    // return $sql;
                    $datos = $this->con->return_query_mysql($sql);
                    $error = $this->con->error_mysql();
                    if (empty($error)) {
                        while ($row = mysqli_fetch_array($datos)) {
                            if ($row['respuesta'] == 1 && !empty($row['chf_id'])) {
                                array_push($resp, array('respuesta' => $row['respuesta'], 'chf_id' => $row['chf_id']));
                            } else {
                                return [array('respuesta' => 0, 'mensaje' => 'No se pudo guardar la fecha id:'.$fecha->id.' fecha: '.date('Y-m-d', strtotime(str_replace('/', '-', $fecha->fecha))))];
                            }
                        }
                    } else {
                        return [array('respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar una fecha '.$error)];
                    }
                }
                return $resp;
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function saveCargaHorariaCursosDocentes($chc_id, $curso)
        {
            try {
                $docentes = $curso->docentes;
                $resp = array();
                foreach ($docentes as $docente) {
                    $this->con->close_open_connection_mysql();
                    $sql = "CALL sp_saveCargaHorariaDocentes(";
                    $sql .= "'".$docente->chd_id."', "; // p_chd_id
                    $sql .= "'".$chc_id."', "; // p_chc_id
                    $sql .= "'".$docente->titular."', "; // p_chd_titular
                    $sql .= "'".$docente->doc_id."', "; // p_doc_id
                    $sql .= "'".$docente->codigo."', "; // p_doc_codigo
                    $sql .= "'".$docente->docente."', "; // p_doc_nombres
                    $sql .= "'".$docente->telefono."', "; // p_doc_celular
                    $sql .= "'".$docente->correo."', "; // p_doc_email
                    $sql .= "'0001', "; // p_chd_estado
                    $sql .= "'".$_SESSION['usu_id']."');"; // p_usuario
                    // return $sql;
                    $datos = $this->con->return_query_mysql($sql);
                    $error = $this->con->error_mysql();
                    if (empty($error)) {
                        while ($row = mysqli_fetch_array($datos)) {
                            if ($row['respuesta'] == 1 && !empty($row['chd_id'])) {
                                array_push($resp, array('respuesta' => $row['respuesta'], 'chd_id' => $row['chd_id']));
                            } else {
                                return [array('respuesta' => 0, 'mensaje' => 'No se pudo guardar al docente id:'.$docente->doc_id.' docente: '.$docente->docente)];
                            }
                        }
                    } else {
                        return [array('respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar un docente '.$error)];
                    }
                }
                return $resp;
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function buscar_carga_horaria()
        {
            try {
                $sql = "CALL sp_saveCargaHorariaDocentes(";
                $sql .= "'".$docente->chd_id."', "; // p_chd_id
                $sql .= "'".$chc_id."', "; // p_chc_id
                $sql .= "'".$docente->titular."', "; // p_chd_titular
                $sql .= "'".$docente->doc_id."', "; // p_doc_id
                $sql .= "'".$docente->codigo."', "; // p_doc_codigo
                $sql .= "'".$docente->docente."', "; // p_doc_nombres
                $sql .= "'".$docente->telefono."', "; // p_doc_celular
                $sql .= "'".$docente->correo."', "; // p_doc_email
                $sql .= "'0001', "; // p_chd_estado
                $sql .= "'".$_SESSION['usu_id']."');"; // p_usuario
            } catch (\Throwable $th) {
                //throw $th;
            }
        }
    }
?>