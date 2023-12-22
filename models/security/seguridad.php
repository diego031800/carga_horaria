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
                $usuario['acciones'] = '<button class="btn btn-warning" onClick="abrir_Modal_permisos('.$index.')">Ver permisos</button>';
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
            $sql="SELECT * from carga_horaria_pagina_permisos where chpp_id_usu = ". $this->parametros['id_usu'];
            $permiso = array();
            $permisos = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $pagina['permiso_id'] = $row['chpp_id'];
                    $pagina['chpp_id_usu'] = $row['chpp_id_usu'];
                    $pagina['chpp_id_pag'] = $row['chpp_id_pag'];     
                    array_push($permisos, $permiso);   
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'permisos'=> $permisos]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }
    
    
}
