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
        } catch (Exception $ex) {
          die("Error: " . $this->con->error_mysql(). $ex);  
        }
    }

    public function get_parents()
    {
        try {
            $sql = "SELECT * FROM carga_horaria_parents";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            $paginas = array();
            if (empty($error)) {
              while ($row = mysqli_fetch_array($datos)) {
                $pag_menu = array(
                    'id' => $row['parent_id'],
                    'name' => $row['parent_name'],
                    'icon' => $row['parent_icono']
                );
                $paginas[] = $pag_menu;
              }
              return $paginas;
            }
        } catch (Exception $ex) {
          die("Error: " . $this->con->error_mysql(). $ex);  
        }
    }

    public function get_pagina_id($nombre)
    {
        try {
            $sql = "SELECT chp_id FROM carga_horaria_pagina where chp_nombre='".$nombre."';";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
              while ($row = mysqli_fetch_array($datos)) {
                $pagina_id = $row['chp_id'];
              }
              return $pagina_id;
            }
        } catch (Exception $ex) {
          die("Error: " . $this->con->error_mysql(). $ex);  
        }
    }
}
