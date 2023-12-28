<?php

include_once '../../models/conexion.php';


class Seguridad
{
    private $con;
    private $parametros = array();

    public function __construct()
    {
        $this->con = new connection();
    }

    public function opciones($parametros)
    {
        $this->parametros = $parametros;
        switch ($this->parametros['opcion']) {
            case 'get_usuarios':
                echo $this->get_usuarios();
                break;
            case 'get_paginas':
                echo $this->get_paginas();
                break;
            case 'get_permisos_usuarios':
                echo $this->get_permisos_usuarios();
                break;
            case 'save_permisos_usuario':
                echo $this->save_permisos_usuario();
                break;    
            default:
                break;
        }
    }

    private function get_usuarios()
    {
        try {
            $sql = "SELECT 
            U.usu_id, 
            PER.per_nombres + ' ' + PER.per_ape_paterno + ' ' + PER.per_ape_materno AS nombres
            FROM SISTEMA.USUARIO U 
            INNER JOIN SISTEMA.PERSONA PER ON PER.per_id = U.per_id
            WHERE U.usu_estado = 1";
            $datos = $this->con->return_query_sqlsrv($sql);
            $usuarios = array();
            $usuario = [];
            $index = 0;
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $index ++;
                $usuario['nro'] = $index;
                $usuario['usu_id'] = $row['usu_id'];
                $usuario['nombres'] = $row['nombres'];
                $usuario['acciones'] = '<button class="btn btn-warning" onClick="abrir_Modal_permisos('.$row['usu_id'].')">Ver permisos</button>';
                array_push($usuarios, $usuario);
            }
            $mensaje = 'Se completó correctamente la sentencia';
            return json_encode(['respuesta'=>1, 'mensaje' => $mensaje, 'usuarios'=> $usuarios]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_paginas(){
        try {
            $sql="SELECT CHP.chp_id, CHP.chp_nombre, CHPT.parent_name from carga_horaria_pagina CHP
            LEFT JOIN carga_horaria_parents CHPT ON CHP.chp_parent = CHPT.parent_id 
            where CHP.chp_tipo = 1";
            $paginas = array();
            $pagina = [];
            $index = 0;
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $index ++;
                    $pagina['nro'] = $index;
                    $pagina['pag_id'] = $row['chp_id'];
                    $pagina['pag_nombre'] = $row['chp_nombre'];
                    $pagina['parent_nombre'] = $row['parent_name'];     
                    $pagina['acciones'] = '<div class="form-check form-switch"><input class="form-check-input" type="checkbox" role="switch" id="check_pag_'.$row['chp_id'].'" onChange="agregar_eliminar_permiso('.$row['chp_id'].')">
                    <label class="form-check-label" for="check_pag_'.$row['chp_id'].'" id="label_pag_'.$row['chp_id'].'">NO</label></div>';
                    array_push($paginas, $pagina);   
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'paginas'=> $paginas]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_permisos_usuarios(){
        try {
            $sql="SELECT CHPP.* FROM carga_horaria_pagina_permisos CHPP 
            inner JOIN carga_horaria_pagina CHP on CHP.chp_id = CHPP.chpp_id_pag
            where CHPP.chpp_id_usu = ". $this->parametros['id_usu']." and CHP.chp_tipo =1;";
            //$sql="SELECT * from carga_horaria_pagina_permisos where chpp_id_usu = ". $this->parametros['id_usu']."and CHP.chp_tipo = 1";
            $permisos = array();
            $permiso = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $permiso['permiso_id'] = $row['chpp_id'];
                    $permiso['chpp_id_usu'] = $row['chpp_id_usu'];
                    $permiso['chpp_id_pag'] = $row['chpp_id_pag'];
                    $permiso['chpp_estado'] = '1';     
                    array_push($permisos, $permiso);   
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'permisos'=> $permisos]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function save_permisos_usuario(){
        try {
            $permisos = json_decode($this->parametros['permisos_usu']);
            $rpta = 1;
            foreach ($permisos as $permiso) {
                $sql ="";
                if($permiso->permiso_id == 0){
                    $sql = "INSERT INTO carga_horaria_pagina_permisos (chpp_id_usu,chpp_id_pag) value(".$permiso->chpp_id_usu.",".$permiso->chpp_id_pag.");";
                    $this->con->simple_query_mysql($sql);
                }else{
                    if($permiso->chpp_estado == 0){
                        $sql = "delete from carga_horaria_pagina_permisos where chpp_id=".$permiso->permiso_id.";";
                        $this->con->simple_query_mysql($sql);
                    }
                }
            }
            if($_SESSION['usu_id'] == $this->parametros['id_usu']){
                $this->set_Permisos($this->parametros['id_usu']);
                $rpta = 2;
            }
            return json_encode(['respuesta'=> $rpta, 'mensaje' => "Se han guardado exitosamente los permisos"]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }
    
    private function set_Permisos($usu_id)
  {
    try {
      $sql = "SELECT chpp_id_pag FROM carga_horaria_pagina_permisos where chpp_id_usu =" . $usu_id . ";";
      $datos = $this->con->return_query_mysql($sql);
      $error = $this->con->error_mysql();
      $permisos = array();
      if (empty($error)) {
        while ($row = mysqli_fetch_array($datos)) {
          array_push($permisos, $row['chpp_id_pag']);
        }
      }
      $_SESSION['permisos'] = $permisos;
    } catch (Exception $ex) {
      die("Error: " . $this->con->error_mysql(). $ex);  
    }
  }
}
