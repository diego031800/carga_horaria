<?php 
include_once '../../models/conexion.php';

class DetalleCursosReportesSigap{

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
            SELECT DISTINCT
	            CUR.cur_creditos as 'cantCreditos'
            FROM PROGRAMACION.SEMESTRE_CURSO SCU
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG ON SCU.scu_id = SCG.scu_id
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD ON SCD.scg_id = SCG.scg_id
            INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
            INNER JOIN ADMISION.SEMESTRE SEM ON SEM.sem_id = SCG.sem_id
            WHERE SEM.sem_id = ".$this->parametros['sem_id']." 
            AND SCG.scg_estado = 1
	        AND SCD.scd_estado = 1
            AND (CUR.cur_descripcion NOT IN('INVESTIGACIÓN III', 'INVESTIGACIÓN IV', 'INVESTIGACIÓN V', 'INVESTIGACIÓN VI')
            AND CUR.cur_descripcion NOT IN('TESIS I', 'TESIS II', 'TESIS III'))";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_sqlsrv($sql);
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $data .= "<option value='" . $row['cantCreditos'] . "'>" . $row['cantCreditos'] . "</option>\n";
            }
            return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cbo_horas(){
        try {
            $sql = "
            SELECT DISTINCT
                SUM(SCD.scd_horas) as 'cantHoras'
            FROM PROGRAMACION.SEMESTRE_CURSO SCU
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG ON SCU.scu_id = SCG.scu_id
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD ON SCD.scg_id = SCG.scg_id
            INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
            INNER JOIN ADMISION.SEMESTRE SEM ON SEM.sem_id = SCG.sem_id
            WHERE SEM.sem_id = ".$this->parametros['sem_id']."  
                AND SCG.scg_estado = 1
                AND SCD.scd_estado = 1
                AND (CUR.cur_descripcion NOT IN('INVESTIGACIÓN III', 'INVESTIGACIÓN IV', 'INVESTIGACIÓN V', 'INVESTIGACIÓN VI')
                AND CUR.cur_descripcion NOT IN('TESIS I', 'TESIS II', 'TESIS III'))
            GROUP BY SCG.scg_id";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_sqlsrv($sql);
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $data .= "<option value='" . $row['cantHoras'] . "'>" . $row['cantHoras'] . "</option>\n";
            }
            return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cbo_cantidad_docentes(){
        try {
            $sql = "
            SELECT DISTINCT
                COUNT(SCD.scd_id) as 'cantDoc'
            FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD ON SCD.scg_id = SCG.scg_id
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO SCU ON SCU.scu_id = SCG.scu_id
            INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
            INNER JOIN ADMISION.SEMESTRE SEM ON SEM.sem_id = SCG.sem_id
            WHERE SEM.sem_id = ".$this->parametros['sem_id']." 
                AND SCG.scg_estado = 1
                AND SCD.scd_estado = 1
                AND (CUR.cur_descripcion NOT IN('INVESTIGACIÓN III', 'INVESTIGACIÓN IV', 'INVESTIGACIÓN V', 'INVESTIGACIÓN VI')
                AND CUR.cur_descripcion NOT IN('TESIS I', 'TESIS II', 'TESIS III'))
            GROUP BY SCG.scg_id";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_sqlsrv($sql);
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $data .= "<option value='" . $row['cantDoc'] . "'>" . $row['cantDoc'] . "</option>\n";
            }
            return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_cbo_cantidad_fechas(){
        try {
            $sql = "
            SELECT DISTINCT
                COUNT(SCC.scc_id) as 'cantFechas'
            FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD ON SCD.scg_id = SCG.scg_id
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_CLASE SCC ON SCC.scg_id = SCG.scg_id
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO SCU ON SCU.scu_id = SCG.scu_id
            INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
            INNER JOIN ADMISION.SEMESTRE SEM ON SEM.sem_id = SCG.sem_id
            WHERE SEM.sem_id = ".$this->parametros['sem_id']." 
                AND SCG.scg_estado = 1
                AND SCD.scd_estado = 1
                AND SCC.scc_estado = 1
                AND SCU.scu_estado = 1
                AND (CUR.cur_descripcion NOT IN('INVESTIGACIÓN III', 'INVESTIGACIÓN IV', 'INVESTIGACIÓN V', 'INVESTIGACIÓN VI')
                AND CUR.cur_descripcion NOT IN('TESIS I', 'TESIS II', 'TESIS III'))
            GROUP BY SCG.scg_id";
            $data = "";
            $data = "<option value=''>Seleccione una opción ...</option>\n";
            $datos = $this->con->return_query_sqlsrv($sql);
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $data .= "<option value='" . $row['cantFechas'] . "'>" . $row['cantFechas'] . "</option>\n";
            }
            return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }

    private function get_data() {
        try {
            $sql = "
            SELECT DISTINCT
            SEM.sem_nombre as Semestre,
                UPPER(SEC.sec_descripcion) as Unidad,
                PRG.prg_mencion as Programa,
                SCG.scg_id as id_curso,
                MCU.mcu_ciclo as Ciclo,
                CUR.cur_descripcion as Nombre,
                CUR.cur_creditos as Creditos,
                CASE WHEN SCG.scg_grupo = 1 THEN 'A' WHEN SCG.scg_grupo = 2 THEN 'B' END as Grupo,
                MIN(SCC.scc_fecha) as FecINI,
				MAX(SCC.scc_fecha) as FecFIN,
                CASE WHEN SCG.scg_envio_estado = 1 THEN 'SIN ENVIAR NOTAS' WHEN SCG.scg_envio_estado = 2 THEN 'CERRADO' END AS ESTADO,
                P1.scd_horas as 'Horas'
            FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO SCU ON SCU.scu_id = SCG.scu_id
            INNER JOIN PROGRAMACION.SEMESTRE_PROGRAMA SPR ON SPR.spr_id = SCU.spr_id
            INNER JOIN PROGRAMACION.SEMESTRE_SECCION SSE ON SSE.sse_id = SPR.sse_id
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_CLASE SCC ON SCC.scg_id = SCG.scg_id
            INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = SSE.sec_id
            INNER JOIN ADMISION.MATRICULA_CURSO MCU ON MCU.scg_id = SCG.scg_id
            INNER JOIN ADMISION.MATRICULA MAT ON MAT.mat_id = MCU.mat_id
            INNER JOIN CONTABILIDAD.CRONOGRAMA_PAGO CRP ON CRP.mat_id = MAT.mat_id
            INNER JOIN CONTABILIDAD.PAGO PAG ON PAG.crp_id = CRP.crp_id
            INNER JOIN CONTABILIDAD.VOUCHER VOU ON VOU.vou_id = PAG.vou_id
            INNER JOIN ADMISION.PROGRAMA PRG ON PRG.prg_id = SCG.prg_id
            INNER JOIN ADMISION.CURSO CUR ON CUR.cur_id = SCU.cur_id
            INNER JOIN ADMISION.SEMESTRE SEM ON SEM.sem_id = SCG.sem_id
            LEFT JOIN ADMISION.DOCENTE DOC ON DOC.doc_id = SCG.scg_docente
            INNER JOIN (SELECT SCG.scg_id, SUM(SCD.scd_horas) AS scd_horas, COUNT(SCD.doc_id) as 'Docs'  FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG 
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD on SCD.scg_id = SCG.scg_id GROUP BY SCG.scg_id) P1 ON P1.scg_id = SCG.scg_id
            INNER JOIN (SELECT SCG.scg_id, COUNT(SCC.scc_id) as 'fechas'  FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO SCG  
            INNER JOIN PROGRAMACION.SEMESTRE_CURSO_CLASE SCC ON SCC.scg_id = SCG.scg_id GROUP BY SCG.scg_id) P2 ON P2.scg_id = SCG.scg_id
            WHERE SEM.sem_id = ".$this->parametros['sem_id']."
            AND SEC.sec_id ".$this->set_parametro($this->parametros['p_uni_id'])."
            AND PRG.prg_id ".$this->set_parametro($this->parametros['p_pro_id'])."
            AND MCU.mcu_ciclo ".$this->set_parametro($this->parametros['p_cic_id'])."
            AND CUR.cur_creditos ".$this->set_parametro($this->parametros['p_cre_id'])."
            AND CUR.cur_id ".$this->set_parametro($this->parametros['p_cur_id'])."
            AND SCG.scg_grupo ".$this->set_parametro($this->parametros['p_gpo_id'])."
            AND P1.scd_horas ".$this->set_parametro($this->parametros['p_hrs'])."
            AND P1.Docs ".$this->set_parametro($this->parametros['p_doc'])."
            AND P2.fechas ".$this->set_parametro($this->parametros['p_fec'])."
            AND SCG.scg_estado = 1
            AND (VOU.vou_monto_usado = SEM.sem_monto_doctorado_matricula OR VOU.vou_monto_usado = SEM.sem_monto_maestria_matricula)
            AND VOU.vou_usu_verificado IS NOT NULL AND VOU.vou_estado = 5 
            AND (CUR.cur_descripcion NOT IN('INVESTIGACIÓN III', 'INVESTIGACIÓN IV', 'INVESTIGACIÓN V', 'INVESTIGACIÓN VI')
            AND CUR.cur_descripcion NOT IN('TESIS I', 'TESIS II', 'TESIS III'))
            GROUP BY SEM.sem_nombre, SEC.sec_descripcion,PRG.prg_mencion, SCG.scg_id, MCU.mcu_ciclo, CUR.cur_descripcion, CUR.cur_creditos, SCG.scg_grupo,
            SCG.scg_envio_estado, P1.scd_horas
            ORDER BY UPPER(SEC.sec_descripcion) DESC;";
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_sqlsrv($sql);
            $indx = 1;
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $dato['nro'] = $indx;
                $dato['Semestre'] = $row['Semestre'];
                $dato['Unidad'] = $row['Unidad'];
                $dato['Programa'] = $row['Programa'];
                $dato['id_curso'] = $row['id_curso'];
                $dato['Ciclo'] = $row['Ciclo'];
                $dato['Nombre'] = $row['Nombre'];
                $dato['Creditos'] = $row['Creditos'];
                $dato['Grupo'] = $row['Grupo'];
                $dato['FechaInicio'] = $row['FecINI'];
                $dato['FechaFin'] = $row['FecFIN'];
                $dato['Horas'] = $row['Horas'];
                $dato['Acciones'] = '<button class="btn btn-warning text-light" onClick="datos_docente('.$row['id_curso'].')"><i class="fa fa-search"></i>Ver</button>';
                $indx ++;
                array_push($data, $dato);
            }
            return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
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
                SELECT 
                case when SCD.scd_titular = 1 then 'Titular' else 'Suplente' end AS 'Tipo',
                SCD.doc_id as 'ID',
                UPPER(CONCAT(DOC.doc_ape_paterno, ' ', DOC.doc_ape_materno, ' ', DOC.doc_nombres)) as 'Nombres',
                SCD.scd_horas AS 'Horas',
                CASE 
                WHEN SCD.scd_condicion = 1 THEN 'MAESTRÍA | DOC. UNT'
                WHEN SCD.scd_condicion = 2 THEN 'MAESTRÍA | DOC. LOCAL'
                WHEN SCD.scd_condicion = 3 THEN 'MAESTRÍA | DOC. NACIONAL'
                WHEN SCD.scd_condicion = 4 THEN 'MAESTRÍA | DOC. EXTRANJERO'
                WHEN SCD.scd_condicion = 5 THEN 'DOCTORADO | DOC. UNT'
                WHEN SCD.scd_condicion = 6 THEN 'DOCTORADO | DOC. LOCAL'
                WHEN SCD.scd_condicion = 7 THEN 'DOCTORADO | DOC. NACIONAL'
                WHEN SCD.scd_condicion = 8 THEN 'DOCTORADO | DOC. EXTRANJERO'
                END AS 'Condicion',
                DOC.doc_grado as 'Grado',
                DOC.doc_codigo as 'Codigo',
                DOC.doc_documento as 'Documento',
                DOC.doc_email as 'Email'
                FROM PROGRAMACION.SEMESTRE_CURSO_GRUPO_DOCENTE SCD 
                INNER JOIN ADMISION.DOCENTE DOC ON DOC.doc_id = SCD.doc_id
                where SCD.scg_id = ".$this->parametros['p_cgd_id']." AND SCD.scd_estado = 1";
            $data = array();
            $dato = [];
            $datos = $this->con->return_query_sqlsrv($sql);
            $indx = 1;
            while ($row = $datos->fetch(PDO::FETCH_ASSOC)) {
                $dato['nro'] = $indx;
                $dato['Tipo'] = $row['Tipo'];
                $dato['Id'] = $row['ID'];
                $dato['Nombres'] = $row['Nombres'];
                $dato['Horas'] = $row['Horas'];
                $dato['Condicion'] = $row['Condicion'];
                $dato['Grado'] = $row['Grado'];
                $dato['Codigo'] = $row['Codigo'];
                $dato['Documento'] = $row['Documento'];
                $dato['Email'] = $row['Email'];
                $indx ++;
                array_push($data, $dato);
            }
            return json_encode(['respuesta'=> 1, 'mensaje' => "La consulta se ejecutó con éxito", 'data'=> $data]);
        } catch (Exception $ex) {
            return json_encode(['respuesta'=> 0, 'mensaje' => $ex]);
        }
    }
}

?>