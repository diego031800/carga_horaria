<?php 
include_once '../../models/conexion.php';

class CursosReportes{

    private $con;
    private $parametros = array();
    private $total;

    public function __construct()
    {
        $this->con = new connection();
        $this->total =0;
    }

    public function opciones($parametros)
    {
        $this->parametros = $parametros;
        switch ($this->parametros['opcion']) {
            case 'get_cant_cursos_unidad':
                echo $this->get_cant_cursos_unidad();
                break;
            case 'get_cant_cursos_grupo':
                echo $this->get_cant_cursos_grupo();
                break;
            case 'get_cant_cursos_horas':
                echo $this->get_cant_cursos_horas();
                break;
            case 'get_cant_cursos_terminados_sinterminar_unidad':
                echo $this->get_cant_cursos_terminados_sinterminar_unidad();
                break;      
            default:
                break;
        }
    }

    private function get_cant_cursos_unidad(){
        try {
            $sql = "
            select 
                CH.sec_id AS 'Id_unidad',
                CH.sec_descripcion AS 'Unidad', 
                count(A1.Id_curso) as 'Cantidad de cursos'
            from (select CH.sec_id, CH.sem_id,CH.sec_descripcion from carga_horaria CH WHERE CH.sem_id=".$this->parametros['sem_id']." group by CH.sec_id, CH.sem_id,CH.sec_descripcion order by CH.sec_id) CH
            inner join (SELECT
                CH.sec_id AS 'Id_unidad',
                CH.sec_descripcion AS 'Unidad',
                CHC.chc_id as 'Id_curso'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHC.chc_id
            ORDER BY CHC.chc_id asc) A1 ON CH.sec_id = A1.Id_unidad
            GROUP BY CH.sec_id, CH.sec_descripcion
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

    private function get_cant_cursos_grupo(){
        try {
            $sql = "
            SELECT
                SUM(case when A1.Grupos = 1 THEN 1 else 0 end) as '1',
                SUM(case when A1.Grupos = 2 THEN 1 else 0 end) as '2',
                SUM(case when A1.Grupos = 3 THEN 1 else 0 end) as '3'
            FROM (SELECT 
                CHC.chc_id, 
                CHC.chc_estado,
                count(CHG.ccg_id) as 'Grupos'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." AND CH.cgh_estado = '0001'
            GROUP BY CHC.chc_id) A1;";
            $data = array();
            $dato1 = [];
            $dato2 = [];
            $dato3 = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $dato1['Cantidad'] = $row['1'];
                    $dato1['Grupo'] = "Cursos con un solo grupo";
                    array_push($data, $dato1); 
                    $dato2['Cantidad'] = $row['2'];
                    $dato2['Grupo'] = "Cursos con dos grupos";
                    array_push($data, $dato2); 
                    $dato3['Cantidad'] = $row['3'];
                    $dato3['Grupo'] = "Cursos con tres grupos";
                    array_push($data, $dato3);   
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
            }else{
                return json_encode(['respuesta'=> 0, 'mensaje' => $error]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cant_cursos_horas(){
        try {
            $sql = "
            SELECT 
                A1.Horas as 'Horas', 
                count(A1.Id_curso) as 'Cantidad de cursos'
            FROM (SELECT
                CHC.chc_id as 'Id_curso',
                CHC.chc_horas as 'Horas'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHC.chc_id
            ORDER BY CHC.chc_id asc) A1
            GROUP BY A1.Horas;";
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $dato['Horas'] = $row['Horas'];
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

    private function get_cant_cursos_terminados_sinterminar_unidad(){
        try {
            $sql = "
            select 
                CH.sec_id AS 'Id_unidad',
                CH.sec_descripcion AS 'Unidad', 
                SUM(case when A1.Estado = 0 THEN 1 else 0 end) as 'NoTerminados',
                SUM(case when A1.Estado = 1 THEN 1 else 0 end) as 'Terminados'
            from (select CH.sec_id, CH.sem_id,CH.sec_descripcion from carga_horaria CH WHERE CH.sem_id=".$this->parametros['sem_id']." group by CH.sec_id, CH.sem_id,CH.sec_descripcion order by CH.sec_id) CH
            inner join (Select 
                A1.Id_unidad,
                A1.Unidad,
                A1.Id_curso,
                case when avg(A1.Estado) = 1 THEN 1 ELSE 0 END Estado
            from (SELECT
                CH.sec_id AS 'Id_unidad',
                CH.sec_descripcion AS 'Unidad',
                CHC.chc_id as 'Id_curso',
                case when MAX(CHGF.cgf_fecha)<NOW() THEN 1 else 0 end as 'Estado'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHG.ccg_id
            HAVING count(CHGF.cgf_id) >2
            ORDER BY CHG.ccg_id asc) A1 
            GROUP BY A1.Id_curso) A1 ON CH.sec_id = A1.Id_unidad
            GROUP BY CH.sec_id, CH.sec_descripcion
            ORDER BY CH.sec_id asc;";
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $dato['Nro'] = $row['Id_unidad'];
                    $dato['Unidad'] = $row['Unidad'];
                    $dato['NoTerminados'] = $row['NoTerminados'];
                    $dato['Terminados'] = $row['Terminados'];
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