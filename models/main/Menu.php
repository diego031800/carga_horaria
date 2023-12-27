<?php
include_once '../../models/conexion.php';

class Menu
{
    private $con;

    public function __construct()
    {
        $this->con = new connection();
    }

    public function get_paginas($id_usu)
    {
        try {
            /*$sql = "select * from carga_horaria_pagina CHP
            INNER JOIN carga_horaria_pagina_permisos CHPP on CHPP.chpp_id_pag = CHP.chp_id
            where CHPP.chpp_id_usu = ".$id_usu.";";*/
            $sql="SELECT * FROM carga_horaria_pagina where chp_orden = 1";
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

    public function get_parents($id_usu)
    {
        try {
            $sql = "select CHPT.parent_id, CHPT.parent_icono, CHPT.parent_name from carga_horaria_parents CHPT 
            INNER JOIN carga_horaria_pagina CHP on CHP.chp_parent = CHPT.parent_id
            INNER JOIN carga_horaria_pagina_permisos CHPP on CHPP.chpp_id_pag = CHP.chp_id
            where CHPP.chpp_id_usu =".$id_usu." group by CHPT.parent_id, CHPT.parent_icono, CHPT.parent_name;";
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
