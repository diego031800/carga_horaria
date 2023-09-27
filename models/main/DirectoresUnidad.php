<?php 

    include_once '../../models/conexion.php';

    class Director{
        //private $parametros = array();
        private $con;

        $objeto = array(
            'atributo1' => 'Valor para atributo 1',
            'atributo2' => 'Valor para atributo 2',
            'atributo3' => 'Valor para atributo 3'
        );

        public function __construct()
        {
            $this->con = new connection();
        }

        public function get_Correo($parametros){
            try {
                $sql="SELECT doc_correo as correo FROM directores.aca DC 
                INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = PRG.sec_id 
                WHERE PRG.sec_id = '".$parametros['p_sec_id']."'";
                $datos = $this->con->return_query_sqlsrv($sql);
                while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                    $this->objeto = $row['correo'];
                }
            } catch (Exception $ex) {
                die("Error: " . $ex);
            }
        } 
    }

?> 