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
                    echo $this->save();
                    break;
                case 'buscar_carga_horaria':
                    echo $this->buscar();
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

        private function save()
        {
            try {
                $this->con->begin_transaction_mysql();
                $respCargaHoraria = $this->saveCargaHoraria();
                
                if ($respCargaHoraria['respuesta'] == 1) {
                    $cgh_id = $respCargaHoraria['cgh_id'];
                    
                    /* GUARDAR CURSOS */
                    $cursos = json_decode($this->parametros['p_cursos']);
                    foreach ($cursos as $curso) {
                        $respCargaHorariaCursos = $this->saveCargaHorariaCurso($cgh_id, $curso);
                        if ($respCargaHorariaCursos['respuesta'] == 1) {
                            $chc_id = $respCargaHorariaCursos['chc_id'];
                            
                            /* GUARDAR FECHAS POR CURSO */
                            $fechas = $curso->fechas;
                            foreach ($fechas as $fecha) {
                                $respCargaHorariaCursosFechas = $this->saveCargaHorariaCursosFecha($chc_id, $fecha);
                                if ($respCargaHorariaCursosFechas['respuesta'] != 1) {
                                    $this->con->rollback_mysql();
                                    return json_encode(['respuesta' => 'error', 'mensaje' => $respCargaHorariaCursosFechas['mensaje']]);
                                }
                            }

                            /* GUARDAR DOCENTES POR CURSO */
                            $docentes = $curso->docentes;
                            foreach ($docentes as $docente) {
                                $respCargaHorariaCursosDocentes = $this->saveCargaHorariaCursosDocente($chc_id, $docente);
                                if ($respCargaHorariaCursosDocentes['respuesta'] != 1) {
                                    $this->con->rollback_mysql();
                                    return json_encode(['respuesta' => 'error', 'mensaje' => $respCargaHorariaCursosDocentes['mensaje']]);
                                }
                            }
                        } else {
                            $this->con->rollback_mysql();
                            return json_encode(['respuesta' => 0, 'mensaje' => $respCargaHorariaCursos['mensaje']]);
                        }
                    }
                    
                    $this->con->commit_mysql();
    
                    return json_encode(['respuesta' => 1, 'mensaje' => 'Registros guardados correctamente.', 'cgh_id' => $cgh_id]);
                } else {
                    $this->con->rollback_mysql();
                    return json_encode(['respuesta' => 0, 'mensaje' => $respCargaHoraria['mensaje']]);
                }
            } catch (Exception $e) {
                $this->con->rollback_mysql();
                return json_encode(['respuesta' => 0, 'mensaje' => $e->getMessage()]);
            }
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
                            return ['respuesta' => $row['respuesta'], 'mensaje' => 'La carga horaria se guardo exitosamente.', 'cgh_id' => $row['cgh_id']];
                        } else {
                            return ['respuesta' => $row['respuesta'], 'mensaje' => $row['mensaje'], 'cgh_id' => $row['cgh_id']];
                        }
                    }
                } else {
                    return ['respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar la carga horaria '.$error];
                }
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }

        private function saveCargaHorariaCurso($cgh_id, $curso)
        {
            try {
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
                            return ['respuesta' => $row['respuesta'], 'mensaje' => 'El curso se guardo exitosamente.', 'chc_id' => $row['chc_id']];
                        } else {
                            return ['respuesta' => 0, 'mensaje' => 'No se pudo guardar el curso id:'.$curso->index.' curso: '.$curso->curso];
                        }
                    }
                } else {
                    return ['respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar un curso '.$error];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function saveCargaHorariaCursosFecha($chc_id, $fecha)
        {
            try {
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
                            return ['respuesta' => $row['respuesta'], 'mensaje' => 'La fecha se guardo exitosamente.','chf_id' => $row['chf_id']];
                        } else {
                            return [array('respuesta' => 0, 'mensaje' => 'No se pudo guardar la fecha id:'.$fecha->id.' fecha: '.date('Y-m-d', strtotime(str_replace('/', '-', $fecha->fecha))))];
                        }
                    }
                } else {
                    return [array('respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar una fecha '.$error)];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function saveCargaHorariaCursosDocente($chc_id, $docente)
        {
            try {
                $this->con->close_open_connection_mysql();
                $sql = "CALL sp_saveCargaHorariaDocentes(";
                $sql .= "'".$docente->chd_id."', "; // p_chd_id
                $sql .= "'".$chc_id."', "; // p_chc_id
                $sql .= "".$docente->titular.", "; // p_chd_titular
                $sql .= "'".$docente->condicion."', "; // p_chd_titular
                $sql .= "'".$docente->doc_id."', "; // p_doc_id
                $sql .= "'".$docente->dni."', "; // p_doc_codigo
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
                            return ['respuesta' => $row['respuesta'], 'mensaje' => 'Los datos del docente se guardaron exitosamente.', 'chd_id' => $row['chd_id']];
                        } else {
                            return [array('respuesta' => 0, 'mensaje' => 'No se pudo guardar al docente id:'.$docente->doc_id.' docente: '.$docente->docente)];
                        }
                    }
                } else {
                    return [array('respuesta' => 0, 'mensaje' => 'Ocurrio un error al guardar un docente '.$error)];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function buscar()
        {
            try {
                $tabla_carga = "";
                $carga_horaria = $this->buscar_carga_horaria();
                $total_filas = 0;
                if (count($carga_horaria) > 0) {
                    $tabla_carga .= "<table class='table table-bordered rounded'>
                                        <tbody>
                                            <tr>
                                                <td class='table-primary text-center' colspan='9'><b>SEMESTRE: &nbsp;&nbsp;".$carga_horaria[0]['semestre']. "</b></td>
                                            </tr>
                                            <tr>
                                                <td class='table-primary text-center'><b>UNIDAD</b></td>
                                                <td class='table-primary text-center'><b>MENCIÓN</b></td>
                                                <td class='table-primary text-center'><b>CICLO</b></td>
                                                <td class='table-primary text-center'><b>CURSO</b></td>
                                                <td class='table-primary text-center'><b>CRED.</b></td>
                                                <td class='table-primary text-center'><b>DOCENTE</b></td>
                                                <td class='table-primary text-center'><b>COND.</b></td>
                                                <td class='table-primary text-center'><b>HORAS</b></td>
                                                <td class='table-primary text-center'><b>FECHAS</b></td>
                                            </tr>";
                    /* ITERAR CARGAS HORARIAS */
                    foreach ($carga_horaria as $carga_id => $carga) {
                        /* OBTENER CURSOS */
                        $this->con->close_open_connection_mysql();
                        $cursos = $this->buscar_cursos_by_carga_horaria($carga['cgh_id']);
                        $total_filas += count($cursos);
                        $tabla_carga .= "<tr>
                                            <td class='align-middle text-center' rowspan='".(count($cursos)==0 ? '' : count($cursos))."'>
                                                " . $carga['unidad'] . "
                                            </td>
                                            <td class='align-middle text-center' rowspan='".(count($cursos)==0 ? '' : count($cursos))."'>
                                                " . $carga['mencion'] . "
                                            </td>
                                            <td class='align-middle text-center' rowspan='".(count($cursos)==0 ? '' : count($cursos))."'>
                                                " . $this->convertirARomano($carga['ciclo']) . "
                                            </td>";
                        
                        if (count($cursos) > 0) {
                            foreach ($cursos as $curso_id => $curso) {
                                $tabla_carga .= "<td class='align-middle text-center'>
                                                    " . $curso['curso'] . "
                                                </td>
                                                <td class='align-middle text-center'>
                                                    " . $curso['cur_creditos'] . "
                                                </td>";
                                $this->con->close_open_connection_mysql();
                                $docentes = $this->buscar_docentes_by_curso($curso['chc_id']);
                                if (count($docentes) > 0) {
                                    foreach ($docentes as $index => $docente) {
                                        $tabla_carga .= "<td class='align-middle text-center'>
                                                        " . $docente['doc_nombres'] . "
                                                        </td>";
                                        $tabla_carga .= "<td class='align-middle text-center'>
                                                        " . $docente['doc_condicion'] . "
                                                        </td>";
                                    }
                                } else {
                                    $tabla_carga .= "<td class='align-middle text-center' colspan='2'>
                                                        Sin docente asignado.
                                                    </td>";
                                }
                                $this->con->close_open_connection_mysql();
                                $fechas = $this->buscar_fechas_by_curso($curso['chc_id']);
                                $tabla_carga .= "<td class='align-middle text-center'>
                                                    " . $curso['chc_horas'] . "
                                                </td>
                                                <td class='align-middle text-center'>";
                                
                                foreach ($fechas as $index => $fecha) {
                                    $tabla_carga .= "<small class='d-inline-flex mb-3 px-2 py-1 fw-semibold text-primary-emphasis bg-primary-subtle border border-primary-subtle rounded-2 mr-5'>" . $this->formatearFecha($fecha['chf_fecha']) . "</small>";
                                }
                                $tabla_carga .= "</td>";
                                $tabla_carga .= "</tr>";
                                $curso_id < count($cursos) - 1?$tabla_carga .= "<tr>":$tabla_carga .= "";
                            }
                        } else {
                            $tabla_carga .= "<td class='align-middle text-center' colspan='6'>
                                                Sin cursos registrados.
                                            </td></tr>";
                        }
                    }
                    $tabla_carga .= "</tbody></table>";
                } else {
                    $tabla_carga = "<table class='table table-bordered rounded'>
                                        <tbody>
                                            <tr>
                                                <td class='align-middle text-center'><b>Sin registros.</b></td>
                                            </tr>
                                        </tbody>
                                    </table>";
                }
                // return $total_filas;
                return $tabla_carga;
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function buscar_carga_horaria()
        {
            try {
                $sql = "CALL sp_getCargaHorariaBySemSec(";
                $sql .= "'".$this->parametros['p_sem_id']."', "; // p_sem_id
                $sql .= "'".$this->parametros['p_sec_id']."');"; // p_sec_id
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                $resp = array();
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $carga_horaria = [];
                        $carga_horaria['cgh_id'] = $row['cgh_id'];
                        $carga_horaria['codigoCH'] = $row['codigoCH'];
                        $carga_horaria['sem_id'] = $row['sem_id'];
                        $carga_horaria['codSemestre'] = $row['codSemestre'];
                        $carga_horaria['semestre'] = $row['semestre'];
                        $carga_horaria['sec_id'] = $row['sec_id'];
                        $carga_horaria['unidad'] = $row['unidad'];
                        $carga_horaria['prg_id'] = $row['prg_id'];
                        $carga_horaria['mencion'] = $row['mencion'];
                        $carga_horaria['ciclo'] = $row['ciclo'];
                        array_push($resp, $carga_horaria);
                    }
                    return $resp;
                } else {
                    return ['respuesta' => 0, 'mensaje' => 'Error en la consulta.'];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function buscar_cursos_by_carga_horaria($cgh_id)
        {
            try {
                $sql = "CALL sp_searchCargaHorariaCursos(";
                $sql .= "'".$cgh_id."');"; // p_cgh_id
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                $resp = array();
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $curso = [];
                        $curso['chc_id'] = $row['chc_id'];
                        $curso['cgh_id'] = $row['cgh_id'];
                        $curso['cur_id'] = $row['cur_id'];
                        $curso['cur_codigo'] = $row['cur_codigo'];
                        $curso['curso'] = $row['curso'];
                        $curso['cur_ciclo'] = $row['cur_ciclo'];
                        $curso['cur_creditos'] = $row['cur_creditos'];
                        $curso['chc_horas'] = $row['chc_horas'];
                        array_push($resp, $curso);
                    }
                    return $resp;
                } else {
                    return ['respuesta' => 0, 'mensaje' => 'Error en la consulta.'];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function buscar_fechas_by_curso($chc_id)
        {
            try {
                $sql = "CALL sp_searchFechasByCursos(";
                $sql .= "'".$chc_id."');"; // p_cgh_id
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                $resp = array();
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $fecha = [];
                        $fecha['chf_id'] = $row['chf_id'];
                        $fecha['chc_id'] = $row['chc_id'];
                        $fecha['chf_fecha'] = $row['chf_fecha'];
                        array_push($resp, $fecha);
                    }
                    return $resp;
                } else {
                    return ['respuesta' => 0, 'mensaje' => 'Error en la consulta.'];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function buscar_docentes_by_curso($chc_id)
        {
            try {
                $sql = "CALL sp_searchDocentesByCurso(";
                $sql .= "'".$chc_id."');"; // p_cgh_id
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                $resp = array();
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $docente = [];
                        $docente['chd_id'] = $row['chd_id'];
                        $docente['chc_id'] = $row['chc_id'];
                        $docente['chd_titular'] = $row['chd_titular'];
                        $docente['doc_condicion'] = $row['doc_condicion'];
                        $docente['doc_id'] = $row['doc_id'];
                        $docente['doc_codigo'] = $row['doc_codigo'];
                        $docente['doc_nombres'] = $row['doc_nombres'];
                        $docente['doc_celular'] = $row['doc_celular'];
                        $docente['doc_email'] = $row['doc_email'];
                        array_push($resp, $docente);
                    }
                    return $resp;
                } else {
                    return ['respuesta' => 0, 'mensaje' => 'Error en la consulta.'];
                }
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        private function convertirARomano($numero) {
            $romanos = array(
                1 => 'I',
                2 => 'II',
                3 => 'III',
                4 => 'IV',
                5 => 'V',
                6 => 'VI'
            );
            
            if (array_key_exists($numero, $romanos)) {
                return $romanos[$numero];
            } else {
                return "No se puede convertir a número romano";
            }
        }

        private function formatearFecha($fecha) {
            $timestamp = strtotime($fecha); // Convertir el formato de fecha
            $dia = date('d', $timestamp); // Obtener el día en número
            $mes = date('F', $timestamp); // Obtener el mes completo en texto

            // Convertir el mes a su forma abreviada en español si es necesario
            $meses_abreviados = array(
                'January'   => 'Ene',
                'February'  => 'Feb',
                'March'     => 'Mar',
                'April'     => 'Abr',
                'May'       => 'May',
                'June'      => 'Jun',
                'July'      => 'Jul',
                'August'    => 'Ago',
                'September' => 'Sep',
                'October'   => 'Oct',
                'November'  => 'Nov',
                'December'  => 'Dic'
            );

            $mes_abreviado = $meses_abreviados[$mes];

            return "$dia, $mes_abreviado";
        }
    }
