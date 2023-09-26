<?php 

    include_once '../../models/conexion.php';

    class Director{
        private $parametros = array();
        private $con;

        public function __construct()
        {
            $this->con = new connection();
        }

        public function get_Correo(){
            $sql="Select doc_correo";
        }
    }

?> 