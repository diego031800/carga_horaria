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
                case 'get_cargas_horarias':
                    echo $this->get_cargas_horarias();
                    break;
                case 'get_programas':
                    echo $this->get_programas();
                    break;
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
                $cuerpo_ch = '';
                $index = 0;
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $index ++;
                        $cuerpo_ch .= '<tr>
                                        <td class="align-middle text-center" style="max-width: 50px;">'.$index. '</td>
                                        <td class="align-middle text-center" style="max-width: 100px;">
                                            <button class="btn btn-secondary btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="false">Acciones</button>
                                            <div  class="dropdown-menu">
                                                <button class="dropdown-item btn-sm" onclick="editar('.$row['cgh_id'].', '.$row['cgc_id']. ')">
                                                    <i class="fa fa-edit text-primary"></i>&nbsp;&nbsp;
                                                    Editar
                                                </button>
                                                <button class="dropdown-item btn-sm" onclick="enviar('.$row['cgh_id'].', '.$row['cgc_id']. ')">
                                                    <i class="fa fa-send-o text-warning"></i>&nbsp;&nbsp;
                                                    Enviar
                                                </button>
                                                <button class="dropdown-item btn-sm" onclick="eliminar('.$row['cgh_id'].', '.$row['cgc_id']. ')">
                                                    <i class="fa fa-trash-o text-danger"></i>&nbsp;&nbsp;
                                                    Eliminar
                                                </button>
                                            </div>
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 120px;">
                                            <h6><span class="badge text-bg-'.$row['color'].'">
                                                '.$row['estado']. '
                                            </span></h6>
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 120px;">
                                            '.$row['codigo']. '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 120px;">
                                            '.$row['semestre']. '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 190px;">
                                            '.$row['unidad']. '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 200px;">
                                            '.$row['mencion']. '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 50px;">
                                            '.($this->convertirARomano($row['ciclo'])). '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 150px;">
                                            '.$row['fecha_creado']. '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 150px;">
                                            '.$row['fecha_edicion']. '
                                        </td>
                                        <td class="align-middle text-center" style="max-width: 200px;">
                                            '.($this->get_nombres_usuario($row['usuario'])).'
                                        </td>
                                    </tr>';
                    }
                    return $cuerpo_ch;
                } else {
                    return '<tr>
                                <td colspan="11">
                                    '.$error. '
                                </td>
                            </tr>';
                }
            } catch (Exception $ex) {
                die("Error: " . $ex);
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