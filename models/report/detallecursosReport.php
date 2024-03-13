<?php 
include_once '../../models/conexion.php';

class DetalleCursosReportes{

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
            case 'get_cbo_creditos':
                echo $this->get_cbo_creditos();
                break;
            case 'get_cbo_horas':
                echo $this->get_cbo_horas();
                break;
            case 'get_cbo_cantidad_docentes':
                echo $this->get_cbo_cantidad_docentes();
                break;
            case 'get_cbo_cantidad_fechas':
                echo $this->get_cbo_cantidad_fechas();
                break;
            case 'get_data':
                echo $this->get_data();
                break;
            case 'get_datos_docente':
                echo $this->get_datos_docente();
                break;       
            default:
                break;
        }
    }
    // Obtener los datos de los filtros
    private function get_cbo_creditos(){
        try {
            $sql = "
            SELECT
                CHC.cur_creditos
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHC.cur_creditos
            order by CHC.cur_creditos ASC;";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $data .= "<option value='" . $row['cur_creditos'] . "'>" . $row['cur_creditos'] . "</option>\n";
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
            }else{
                return json_encode(['respuesta'=> 0, 'mensaje' => $error]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cbo_horas(){
        try {
            $sql = "
            SELECT
                CHC.chc_horas as 'Horas'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHC.chc_horas
            ORDER BY CHC.chc_horas asc;";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $data .= "<option value='" . $row['Horas'] . "'>" . $row['Horas'] . "</option>\n";
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
            }else{
                return json_encode(['respuesta'=> 0, 'mensaje' => $error]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cbo_cantidad_docentes(){
        try {
            $sql = "
            SELECT
                Distinct count(CHCGD.cgd_id) as 'Cantidad'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_docente CHCGD on CHCGD.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHG.ccg_id;";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $data .= "<option value='" . $row['Cantidad'] . "'>" . $row['Cantidad'] . "</option>\n";
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
            }else{
                return json_encode(['respuesta'=> 0, 'mensaje' => $error]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cbo_cantidad_fechas(){
        try {
            $sql = "
            SELECT
                Distinct count(CHGF.cgf_id) as 'Cantidad'
            FROM carga_horaria_curso CHC
            INNER JOIN carga_horaria_curso_grupo CHG ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CHC.chc_estado = '0001' AND CH.sem_id = ".$this->parametros['sem_id']." 
            GROUP BY CHG.ccg_id;";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $data .= "<option value='" . $row['Cantidad'] . "'>" . $row['Cantidad'] . "</option>\n";
                }
                return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
            }else{
                return json_encode(['respuesta'=> 0, 'mensaje' => $error]);
            }
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_data() {
        try {
            $sql = "
            select
                CH.sem_descripcion as 'Semestre',
                CH.sec_descripcion as 'Unidad',
                CH.prg_mencion as 'Programa',
                CHG.ccg_id as 'id_curso',
                CHCI.cgh_ciclo as 'Ciclo',
                CHC.cur_descripcion as 'Nombre',
                CHC.cur_creditos as 'Creditos',
                case 
                when CHG.ccg_grupo = 1 then 'A' 
                when CHG.ccg_grupo = 2 then 'B' 
                else 'C' end AS 'Grupo',
                Min(CHGF.cgf_fecha) as 'Fecha Inicio',
                Max(CHGF.cgf_fecha) as 'Fecha Fin',
                CHC.chc_horas as 'Horas'
            FROM carga_horaria_curso_grupo CHG
            INNER JOIN carga_horaria_curso CHC ON CHG.chc_id = CHC.chc_id
            INNER JOIN carga_horaria_curso_grupo_fecha CHGF ON CHGF.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_curso_grupo_docente CHGD ON CHGD.ccg_id = CHG.ccg_id
            INNER JOIN carga_horaria_ciclo CHCI on CHCI.cgc_id = CHC.cgc_id
            INNER JOIN carga_horaria CH on CH.cgh_id = CHCI.cgh_id
            WHERE CH.cgh_estado = '0001' AND  CHCI.cgc_estado = '0001' AND CHC.chc_estado = '0001' AND CHG.ccg_estado = '0001' AND CHGF.cgf_estado = '0001' AND CHGD.cgd_estado = '0001' 
            AND CH.sem_id = ".$this->parametros['sem_id']."
            AND CH.sec_id ".$this->set_parametro($this->parametros['p_uni_id'])."
            AND CH.prg_id ".$this->set_parametro($this->parametros['p_pro_id'])."
            AND CHCI.cgh_ciclo ".$this->set_parametro($this->parametros['p_cic_id'])."
            AND CHC.cur_creditos ".$this->set_parametro($this->parametros['p_cre_id'])."
            AND CHC.cur_id ".$this->set_parametro($this->parametros['p_cur_id'])."
            AND CHG.ccg_grupo ".$this->set_parametro($this->parametros['p_gpo_id'])."
            AND CHC.chc_horas ".$this->set_parametro($this->parametros['p_hrs'])."
            GROUP BY CHG.ccg_id
            HAVING 
            count(distinct CHGD.cgd_id) ".$this->set_parametro($this->parametros['p_doc'])."
            AND count(distinct CHGF.cgf_id) ".$this->set_parametro($this->parametros['p_fec'])."
            order by CH.sec_id;
            ";
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            $indx = 1;
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $dato['nro'] = $indx;
                    $dato['Semestre'] = $row['Semestre'];
                    $dato['Unidad'] = $row['Unidad'];
                    $dato['Programa'] = $row['Programa'];
                    $dato['id_curso'] = $row['id_curso'];
                    $dato['Ciclo'] = $row['Ciclo'];
                    $dato['Nombre'] = $row['Nombre'];
                    $dato['Creditos'] = $row['Creditos'];
                    $dato['Grupo'] = $row['Grupo'];
                    $dato['FechaInicio'] = $row['Fecha Inicio'];
                    $dato['FechaFin'] = $row['Fecha Fin'];
                    $dato['Horas'] = $row['Horas'];
                    $dato['Acciones'] = '<button class="btn btn-warning text-light" onClick="datos_docente('.$row['id_curso'].')"><i class="fa fa-search"></i>Ver</button>';
                    $indx ++;
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

    private function set_parametro($parametro){
        $resultado = "";
        if($parametro == 0){
            $resultado = "<> 0";
        }else{
            $resultado = "= ".$parametro;
        }
        return $resultado;
    }


    private function get_datos_docente(){
        try {
            $sql = "
            Select
                case when CHGD.cgd_titular = 1 then 'Titular' else 'Suplente' end AS 'Tipo',
                CHGD.doc_id as 'ID',
                CHGD.doc_nombres as 'Nombres',
                A1.mtb_nombre as 'Condicion',
                A2.mtb_nombre as 'Grado',
                CHGD.doc_codigo as 'Codigo',
                CHGD.doc_documento as 'Documento',
                CHGD.doc_email as 'Email'
            FROM carga_horaria_curso_grupo CHG
            INNER JOIN carga_horaria_curso_grupo_docente CHGD ON CHGD.ccg_id = CHG.ccg_id
            INNER JOIN (select * from multitabla where tbl_id = '0001') A1 ON CHGD.doc_condicion = A1.mtb_valor
            INNER JOIN (select * from multitabla where tbl_id = '0002') A2 ON CHGD.doc_grado = A2.mtb_valor
            WHERE CHG.ccg_id = ".$this->parametros['p_cgd_id'];
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_mysql($sql);
            $error = $this->con->error_mysql();
            $indx = 1;
            if (empty($error)) {
                while ($row = mysqli_fetch_array($datos)) {
                    $dato['nro'] = $indx;
                    $dato['Tipo'] = $row['Tipo'];
                    $dato['Id'] = $row['ID'];
                    $dato['Nombres'] = $row['Nombres'];
                    $dato['Condicion'] = $row['Condicion'];
                    $dato['Grado'] = $row['Grado'];
                    $dato['Codigo'] = $row['Codigo'];
                    $dato['Documento'] = $row['Documento'];
                    $dato['Email'] = $row['Email'];
                    $indx ++;
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