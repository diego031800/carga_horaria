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
    }

?>