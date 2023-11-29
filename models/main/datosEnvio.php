<?php 

    include_once '../../models/conexion.php';

    class datosEnvio{
        //private $parametros = array();
        private $con;

        private $objeto = array(
            'unidad' => 'Valor para atributo 1',
            'nombre' => 'Valor para atributo 2',
            'correo' => 'Valor para atributo 3',
            'rutaPDF' => 'Valor para atributo 3'
        );

        private $datos_docentes = array();

        public function __construct()
        {
            $this->con = new connection();
        }

        public function get_Datos_Envio_Director($parametros){
            try {
                $sql="SELECT doc_correo as correo FROM directores.aca DC 
                INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id 
                WHERE PRG.sec_id = '".$parametros['p_sec_id']."'";
                $datos = $this->con->return_query_sqlsrv($sql);
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $this->objeto = $row['correo'];
                }
                echo $this->objeto;
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        }
        
        public function get_Datos_Envio_Docente($parametros){
            try {
                foreach ($parametros as $item) {
                    $datos = array(
                        'Nombre' => 'SN',
                        'codigo' => 'SC',
                        'documento' => 'SD',
                        'email' => 'SE'
                    );
                    $sql="SELECT doc_correo as correo FROM directores.aca DC 
                    INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id 
                    WHERE PRG.sec_id = '".$parametros['p_sec_id']."'";
                    
                }
                
                $sql="SELECT doc_correo as correo FROM directores.aca DC 
                INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id 
                WHERE PRG.sec_id = '".$parametros['p_sec_id']."'";
                $datos = $this->con->return_query_sqlsrv($sql);
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $this->objeto = $row['correo'];
                }
                echo $this->objeto;
            } catch (Exception $ex) {
                die("Error: " . $ex);
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