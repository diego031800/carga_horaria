<?php 
include_once '../../models/conexion.php';

class CursosReportes{

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
            case 'get_cant_cursos_unidad':
                echo $this->get_cant_cursos_unidad();
                break;  
            default:
                break;
        }
    }

    private function get_cant_cursos_unidad(){
        try {
            $sql = "
            SELECT 
                CH.sec_id AS 'Id_unidad',
                CH.sec_descripcion AS 'Unidad', 
                count(CHC.chc_id) as 'Cantidad de cursos'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']."
            GROUP BY CH.sec_descripcion
            ORDER BY CH.sec_id asc;";
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $dato['Unidad'] = $row['Unidad'];
                    $dato['Cantidad'] = $row['Cantidad de cursos'];
                    array_push($data, $dato);   
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
            }else{
                return json_encode(['respuesta'=> 0, 'mensaje' => $error]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
        

    }
}

?>