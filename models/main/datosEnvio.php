<?php 

    include_once '../../models/conexion.php';

    class datosEnvio{
        //private $parametros = array();
        private $con;

        public function __construct()
        {
            $this->con = new connection();
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

        public function get_ReporteEnvios($sem, $sec){
            try {
                $sql = "CALL sp_getReporteEnvios(";
                $sql .= "".$sem.", ";
                $sql .= "".$sec."); ";
                $datos = $this->con->return_query_mysql($sql);
                $respuesta = array();
                $error = $this->con->error_mysql();
                if (empty($error)) {
                    while ($row = mysqli_fetch_array($datos)) {
                        $data = new stdClass();
                        $data->nombre = $row['Nombre'];
                        $data->correo = $row['Correo'];
                        $data->envio = $row['Envio'];
                        $data->fechahora = $row['Fecha'];
                        $data->error = $row['Error_Envio'];
                        $respuesta[] = $data;
                    }
                }
                return $respuesta;
            } catch (Exception $ex) {
                die("Error: " . $this->con->error_mysql(). $ex);
            }

        }
    }

?>