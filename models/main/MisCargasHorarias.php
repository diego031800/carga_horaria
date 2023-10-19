<?php

    include_once '../../models/conexion.php';

    class MisCargasHorarias
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
                case 'get_cargas_horarias_by_sem':
                    echo $this->get_cargas_horarias_by_sem();
                    break;
                case 'get_cargas_horarias':
                    echo $this->get_cargas_horarias();
                    break;
                case 'get_programas':
                    echo $this->get_programas();
                    break;
                case 'send_carga_horaria':
                    echo $this->send_carga_horaria();
                    break;
                case 'delete_carga_horaria':
                    echo $this->delete_carga_horaria();
                    break;
            }
        }

        private function get_cargas_horarias_by_sem()
        {
            try {
                $sql = "CALL sp_GetMisCargasHorariasBySem(";
                $sql .= "'".$this->parametros['p_sem_id']."', "; // p_sem_id
                $sql .= "'".$this->parametros['p_sec_id']."', "; // p_sec_id
                $sql .= "'".$_SESSION['usu_id']."', "; // p_usuario
                $sql .= "'".json_encode($this->get_unidades_asignadas($_SESSION['usu_id']))."'); "; // p_unidades_usuario
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                // return json_encode($datos);
                $cuerpo_ch = '';
                $data = [];
                $data_table = array();
                $index = 0;
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $index ++;
                        $data['nro'] = $index; 
                        $data['acciones'] = '<button class="btn btn-secondary btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="false">Acciones</button>
                                            <div  class="dropdown-menu">
                                                <button class="dropdown-item btn-sm" onclick="editar('.$row['sem_id'].', '.$row['sec_id'].')">
                                                    <i class="fa fa-plus-circle text-primary"></i>&nbsp;&nbsp;
                                                    Ver detalle
                                                </button>
                                                <button class="dropdown-item btn-sm" onclick="verPdf('.$row['sem_id'].', '.$row['sec_id'].')">
                                                    <i class="fa fa-file-pdf-o text-danger"></i>&nbsp;&nbsp;
                                                    Ver pdf
                                                </button>
                                                <button class="dropdown-item btn-sm" onclick="enviar('.$row['sem_id'].', '.$row['sec_id'].')">
                                                    <i class="fa fa-send-o text-warning"></i>&nbsp;&nbsp;
                                                    Enviar
                                                </button>
                                            </div>'; 
                        $data['estado'] = '<h6><span class="badge text-bg-'.$row['color'].'">
                                                '.$row['estado']. '
                                            </span></h6>';
                        $data['codigo'] = $row['codigo'];
                        $data['semestre'] = $row['semestre'];
                        $data['unidad'] = $row['unidad'];
                        $data['usuario'] = $this->get_nombres_usuario($row['usuario']);
                        // $data['p_unidades'] = $row['p_unidades'];
                        array_push($data_table, $data);
                    }
                    return json_encode($data_table);
                } else {
                    return $error;
                }
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }

		private function get_cargas_horarias()
		{
			try {
                $sql = "CALL sp_GetMisCargasHorarias(";
                $sql .= "'".$this->parametros['p_sem_id']."', "; // p_sem_id
                $sql .= "'".$this->parametros['p_sec_id']."', "; // p_sec_id
                $sql .= "'".$this->parametros['p_prg_id']."', "; // p_prg_id
                $sql .= "'".$this->parametros['p_ciclo']."', "; // p_cgc_ciclo
                $sql .= "'".$_SESSION['usu_id']."');"; // p_usuario
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                // return json_encode($datos);
                $data = [];
                $data_table = array();
                $cuerpo_ch = '';
                $index = 0;
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $index ++;
                        $data['nro'] = $index; 
                        $data['acciones'] = '<button class="btn btn-secondary btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="false">Acciones</button>
                                            <div  class="dropdown-menu">
                                                <button class="dropdown-item btn-sm" onclick="editar('.$row['cgh_id'].', '.$row['cgc_id']. ')">
                                                    <i class="fa fa-edit text-primary"></i>&nbsp;&nbsp;
                                                    Editar
                                                </button>
                                                <button class="dropdown-item btn-sm" onclick="eliminar('.$row['cgh_id'].', '.$row['cgc_id']. ')">
                                                    <i class="fa fa-trash-o text-danger"></i>&nbsp;&nbsp;
                                                    Eliminar
                                                </button>
                                            </div>';
                        $data['estado'] = '<h6><span class="badge text-bg-'.$row['color'].'">
                                                '.$row['estado']. '
                                            </span></h6>';
                        $data['codigo'] = $row['codigo'];
                        $data['semestre'] = $row['semestre'];
                        $data['unidad'] = $row['unidad'];
                        $data['programa'] = $row['programa'];
                        $data['ciclo'] = $row['ciclo'];
                        $data['creado'] = $row['creado'];
                        $data['usuario'] = $this->get_nombres_usuario($row['usuario']);
                        $data['editado'] = $row['editado'];
                        $data['usuario_modificacion'] = is_null($row['usuario_modificacion'])?'SIN EDICIÓN': $this->get_nombres_usuario($row['usuario_modificacion']);
                        array_push($data_table, $data);
                    }
                    return json_encode($data_table);
                } else {
                    return json_encode($data_table);
                }
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
		}

        private function send_carga_horaria()
        {
            try {
                $sql = "";
            } catch (Exception $ex) {
                die("Error: ".$ex);
            }
        }

        private function get_programas()
        {
            try {
                $sql = "SELECT
                            PRG.prg_id,
                            PRG.prg_mencion as programa
                        FROM ADMISION.PROGRAMA PRG
                        INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id
                        WHERE PRG.sec_id = '".$this->parametros['p_sec_id']."' AND PRG.prg_estado = 1";
                $datos = $this->con->return_query_sqlsrv($sql);
                $programas = "";
                $programas = "<option value=''>Selecciona un programa ...</option>\n";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $programas .= "<option value='".$row['prg_id']."'>".$row['programa']."</option>\n";
                }
                return $programas;
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }

        private function get_nombres_usuario($usu_id)
        {
            try {
                $sql = "SELECT TOP 1
                            USU.usu_login,
                            UPPER(PER.per_nombres + ' ' + PER.per_ape_paterno + ' ' + PER.per_ape_materno) as usuario
                        FROM SISTEMA.USUARIO USU
                        INNER JOIN SISTEMA.PERSONA PER ON PER.per_id = USU.per_id
                        WHERE USU.usu_id = '$usu_id'
                            AND USU.usu_estado = 1
                        ORDER BY USU.usu_id DESC";
                $datos = $this->con->return_query_sqlsrv($sql);
                $usuario = "";
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $usuario = $row['usuario'];
                }
                return $usuario;
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }

        private function get_unidades_asignadas($usu_id)
        {
            try {
                $sql = "SELECT
                            UUN.sec_id
                        FROM SISTEMA.USUARIO_UNIDAD UUN
                        WHERE UUN.usu_id = '$usu_id'
                        ORDER BY UUN.sec_id DESC";
                $datos = $this->con->return_query_sqlsrv($sql);
                $unidades = array();
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $unidad = [];
                    $unidad['unidad_id'] = $row['sec_id'];
                    array_push($unidades, $unidad);
                }
                return $unidades;
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }

        private function delete_carga_horaria()
        {
            try
            {
                $sql = "CALL sp_deleteCargaHoraria(";
                $sql .= "'".$this->parametros['p_cgh_id']."', "; // p_cgh_id
                $sql .= "'".$this->parametros['p_cgc_id']."', "; // p_cgc_id
                $sql .= "'".$_SESSION['usu_id'].", "; // p_usuario
                $sql .= "'".$_SESSION['REMOTE_ADDR']."');"; // p_dispositivo
                // return $sql;
                $datos = $this->con->return_query_mysql($sql);
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        return json_encode(['respuesta' => $row['respuesta'], 'mensaje' => $row['mensaje']]);
                    }
                }
                return json_encode(['respuesta' => 0, 'mensaje' => 'Algo ocurrió mientras se eliminaba ' + $error]);
            } catch (Exception $ex) {
                die("Error: " . $ex);
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
    }