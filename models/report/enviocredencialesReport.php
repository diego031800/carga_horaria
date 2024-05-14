<?php 

    include_once '../../models/conexion.php';

    class datosEnvio{
        private $parametros = array();
        private $con;

        public function __construct()
        {
            $this->con = new connection();
        }

        public function opciones_busqueda( $parametros){
            $this->parametros = $parametros;
            switch ($this->parametros['opcion_busqueda']) {
                case '1':
                    echo $this->get_ReporteEnvios();
                    break;
                case '2':
                    echo $this->get_ReporteEnviosByFecha();
                    break;
                case '3':
                    echo $this->get_ReporteEnviosByMA();
                    break;     
                default:
                    break;
            }
        }

        public function save_reporte($datosGuardar){
            try{
                $this->con->close_open_connection_mysql();
                foreach ($datosGuardar as $item) {
                    $sql = "INSERT into carga_horaria_envio_credenciales ( sem_id, sec_id, chec_doc_id,
                        chec_doc_nombre, chec_doc_correo,chec_envio,chec_envio_fecha,chec_envio_error
                        ,fechahora,usuario, dispositivo) values(";
                    $sql .= "".$item['sem_id'].",";
                    $sql .= "".$item['sec_id'].",";
                    $sql .= "".$item['doc_id'].",";
                    $sql .= "'".$item['nombre']."',";
                    $sql .= "'".$item['correo']."',";
                    $sql .= "".$item['envio'].",";
                    $sql .= "'".$item['fechahora']."',";
                    $sql .= "'".$item['error']."',";
                    $sql .= "'".date('Y-m-d H:i:s')."', ";
                    $sql .= "'".$_SESSION['usu_id']."', "; // p_usuario
                    $sql .= "'".$_SESSION['usu_ip']."');"; // p_dispositivo
                    $this->con->simple_query_mysql($sql);
                }
            }catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }

        public function save_reporte_individual($item, $is_asesor){
            try{
                $this->con->close_open_connection_mysql();
                    $sql = "INSERT into carga_horaria_envio_credenciales ( sem_id, sec_id,is_asesor, chec_doc_id,
                        chec_doc_nombre, chec_doc_correo,chec_envio,chec_envio_fecha,chec_envio_error
                        ,fechahora,usuario, dispositivo) values(";
                    $sql .= "".$item['sem_id'].",";
                    $sql .= "".$item['sec_id'].",";
                    $sql .= "".$is_asesor.",";
                    $sql .= "".$item['doc_id'].",";
                    $sql .= "'".$item['nombre']."',";
                    $sql .= "'".$item['correo']."',";
                    $sql .= "".$item['envio'].",";
                    $sql .= "'".$item['fechahora']."',";
                    $sql .= "'".$item['error']."',";
                    $sql .= "'".date('Y-m-d H:i:s')."', ";
                    $sql .= "'".$_SESSION['usu_id']."', "; // p_usuario
                    $sql .= "'".$_SESSION['usu_ip']."');"; // p_dispositivo
                    $this->con->simple_query_mysql($sql);
                    $mensaje = 'Se completó correctamente la sentencia';
                    return json_encode(['respuesta'=>1, 'mensaje' => $mensaje, 'item'=> $item]);
            }catch (Exception $ex) {
                return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
            }
        }

        private function get_ReporteEnvios(){
            try {
                $this->con->close_open_connection_mysql();
                $sql = "CALL sp_getReporteEnvios(";
                $sql .= "".$this->parametros['sem_id'].", ";
                $sql .= "".$this->parametros['sec_id'].", ";
                $sql .= "".$this->parametros['is_asesor']."); ";
                $respuesta = $this->con->return_query_mysql($sql);
                $datos = array();
                $error = $this->con->error_mysql();
                $i = 1;
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($respuesta)) {
                        $data = new stdClass();
                        $data->nro = $i;
                        $data->idDocente = $row['idDocente'];
                        $data->nombre = $row['Nombre'];
                        $data->correo = $row['Correo'];
                        if ($row['Envio'] == 1) {
                            $data->envio = 'SI';
                        }else{
                            $data->envio = 'NO';
                        }
                        $data->fechahora = $row['Fecha'];
                        $data->error = $row['Error_Envio'];
                        $datos[] = $data;
                        $i++;
                    }
                }
                $this->con->close_open_connection_mysql();
                $mensaje = 'Se completó correctamente la sentencia';
                return json_encode(['respuesta'=>1, 'mensaje' => $mensaje, 'data'=>$datos]);
            } catch (Exception $ex) {
                return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
            }
        }

        private function get_ReporteEnviosByFecha(){
            try {
                $this->con->close_open_connection_mysql();
                $sql = "CALL sp_getReporteEnviosByFecha(";
                $sql .= "".$this->parametros['sem_id'].", ";
                $sql .= "".$this->parametros['sec_id'].", ";
                $sql .= "".$this->parametros['is_asesor'].",";
                $sql .= "'".date('Y-m-d', strtotime(str_replace('/', '-', $this->parametros['fecha'])))."'); ";
                error_log($sql);
                $respuesta = $this->con->return_query_mysql($sql);
                $datos = array();
                $error = $this->con->error_mysql();
                $i = 1;
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($respuesta)) {
                        $data = new stdClass();
                        $data->nro = $i;
                        $data->idDocente = $row['idDocente'];
                        $data->nombre = $row['Nombre'];
                        $data->correo = $row['Correo'];
                        if ($row['Envio'] == 1) {
                            $data->envio = 'SI';
                        }else{
                            $data->envio = 'NO';
                        }
                        $data->fechahora = $row['Fecha'];
                        $data->error = $row['Error_Envio'];
                        $datos[] = $data;
                        $i++;
                    }
                }
                $this->con->close_open_connection_mysql();
                $mensaje = 'Se completó correctamente la sentencia';
                return json_encode(['respuesta'=>1, 'mensaje' => $mensaje, 'data'=>$datos]);
            } catch (Exception $ex) {
                return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
            }
        }

        private function get_ReporteEnviosByMA(){
            try {
                $this->con->close_open_connection_mysql();
                $sql = "CALL sp_getReporteEnviosByMA(";
                $sql .= "".$this->parametros['sem_id'].", ";
                $sql .= "".$this->parametros['sec_id'].", ";
                $sql .= "".$this->parametros['is_asesor'].", ";
                $sql .= "".$this->parametros['month'].", ";
                $sql .= "".$this->parametros['year']."); ";
                error_log($sql);
                $respuesta = $this->con->return_query_mysql($sql);
                $datos = array();
                $error = $this->con->error_mysql();
                $i = 1;
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($respuesta)) {
                        $data = new stdClass();
                        $data->nro = $i;
                        $data->idDocente = $row['idDocente'];
                        $data->nombre = $row['Nombre'];
                        $data->correo = $row['Correo'];
                        if ($row['Envio'] == 1) {
                            $data->envio = 'SI';
                        }else{
                            $data->envio = 'NO';
                        }
                        $data->fechahora = $row['Fecha'];
                        $data->error = $row['Error_Envio'];
                        $datos[] = $data;
                        $i++;
                    }
                }
                $this->con->close_open_connection_mysql();
                $mensaje = 'Se completó correctamente la sentencia';
                return json_encode(['respuesta'=>1, 'mensaje' => $mensaje, 'data'=>$datos]);
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }
        }
        
    }

?>