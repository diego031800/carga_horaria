<?php
include_once '../../models/conexion.php';

class Menu
{
    private $con;

    public function __construct()
    {
        $this->con = new connection();
    }

    public function get_paginas()
    {
        try {
            $sql = "SELECT * FROM carga_horaria_pagina";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            $paginas = array();
            if (empty($error)) {
              while ($row = mysqli_fetch_array($datos)) {
                $pag_menu = array(
                    'id' => $row['chp_id'],
                    'name' => $row['chp_nombre'],
                    'url'=> $row['chp_url'],
                    'parent_id' => $row['chp_parent']
                );
                $paginas[] = $pag_menu;
              }
              return $paginas;
            }
        } catch (\Throwable $th) {
            
        }
    }
}
