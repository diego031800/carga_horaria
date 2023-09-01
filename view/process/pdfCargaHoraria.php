<?php
  require_once('../../models/conecction.php');
  require_once '../../vendor/autoload.php';

  date_default_timezone_set('America/Lima');

	session_start();

	$time = time();

	if (isset($_GET['sem_id']) && isset($_GET['sec_id'])) {
		$sem_id = $_GET['sem_id'];
		$sec_id = $_GET['sec_id'];
	}

  /* FUNCIONES PARA CONVERSIONES */
  function convertirARomano($numero) {
      $romanos = array(
          1 => 'I',
          2 => 'II',
          3 => 'III',
          4 => 'IV',
          5 => 'V',
          6 => 'VI'
      );
      
      if (array_key_exists($numero, $romanos)) {
          return $romanos[$numero];
      } else {
          return "No se puede convertir a número romano";
      }
  }

  function formatearFecha($fecha) {
    $timestamp = strtotime($fecha); // Convertir el formato de fecha
    $dia = date('d', $timestamp); // Obtener el día en número
    $mes = date('F', $timestamp); // Obtener el mes completo en texto

    // Convertir el mes a su forma abreviada en español si es necesario
    $meses_abreviados = array(
        'January'   => 'Ene',
        'February'  => 'Feb',
        'March'     => 'Mar',
        'April'     => 'Abr',
        'May'       => 'May',
        'June'      => 'Jun',
        'July'      => 'Jul',
        'August'    => 'Ago',
        'September' => 'Sep',
        'October'   => 'Oct',
        'November'  => 'Nov',
        'December'  => 'Dic'
    );

    $mes_abreviado = $meses_abreviados[$mes];

    return "$dia, $mes_abreviado";
}

  /* DATOS CARGA HORARIA */
  function get_cargas_horarias($sem_id, $sec_id)
  {
    $con = conectar();
    $sql = "CALL sp_getCargaHorariaBySemSec(";
    $sql .= "'".$sem_id."', "; // p_sem_id
    $sql .= "'".$sec_id."');"; // p_sec_id
    // return $sql;
    $datos = $con->query($sql);
    $carga_horaria = array();
    while ($row = mysqli_fetch_array($datos)) {
      $ch = [];
      $ch['cgh_id'] = $row['cgh_id'];
      $ch['codigoCH'] = $row['codigoCH'];
      $ch['sem_id'] = $row['sem_id'];
      $ch['codSemestre'] = $row['codSemestre'];
      $ch['semestre'] = $row['semestre'];
      $ch['sec_id'] = $row['sec_id'];
      $ch['unidad'] = $row['unidad'];
      $ch['prg_id'] = $row['prg_id'];
      $ch['mencion'] = $row['mencion'];
      array_push($carga_horaria, $ch);
    }
    $con->close();
    return $carga_horaria;
  }

  /* OBTENER CICLOS */
  function get_ciclos_by_carga_horaria($cgh_id)
  {
    $con = conectar();
    $sql = "CALL sp_searchCargaHorariaCiclos(";
    $sql .= "'".$cgh_id."');"; // p_sec_id
    // return $sql;
    $datos = $con->query($sql);
    $ciclos = array();
    while ($row = mysqli_fetch_array($datos)) {
      $ciclo = [];
      $ciclo['cgc_id'] = $row['cgc_id'];
      $ciclo['cgh_id'] = $row['cgh_id'];
      $ciclo['ciclo'] = $row['ciclo'];
      array_push($ciclos, $ciclo);
    }
    $con->close();
    return $ciclos;
  }

  /* OBTENER CURSOS */
  function get_cursos_by_ciclo($cgc_id)
  {
    $con = conectar();
    $sql = "CALL sp_searchCargaHorariaCursos(";
    $sql .= "'". $cgc_id."');"; // p_cgh_id
    // return $sql;
    $datos = $con->query($sql);
    $cursos = array();
    while ($row = mysqli_fetch_array($datos)) {
      $curso = [];
      $curso['chc_id'] = $row['chc_id'];
      $curso['cgc_id'] = $row['cgc_id'];
      $curso['cur_id'] = $row['cur_id'];
      $curso['cur_codigo'] = $row['cur_codigo'];
      $curso['curso'] = $row['curso'];
      $curso['cur_ciclo'] = $row['cur_ciclo'];
      $curso['cur_creditos'] = $row['cur_creditos'];
      $curso['chc_horas'] = $row['chc_horas'];
      array_push($cursos, $curso);
    }
    $con->close();
    return $cursos;
  }

  /* OBTENER DOCENTES */
  function get_docentes_by_curso($chc_id)
  {
    $con = conectar();
    $sql = "CALL sp_searchDocentesByCurso(";
    $sql .= "'".$chc_id."');"; // p_cgh_id
    // return $sql;
    $datos = $con->query($sql);
    $docentes = array();
    while ($row = mysqli_fetch_array($datos)) {
      $docente = [];
      $docente['chd_id'] = $row['chd_id'];
      $docente['chc_id'] = $row['chc_id'];
      $docente['chd_titular'] = $row['chd_titular'];
      $docente['doc_condicion'] = $row['doc_condicion'];
      $docente['doc_id'] = $row['doc_id'];
      $docente['doc_codigo'] = $row['doc_codigo'];
      $docente['doc_nombres'] = $row['doc_nombres'];
      $docente['doc_celular'] = $row['doc_celular'];
      $docente['doc_email'] = $row['doc_email'];
      array_push($docentes, $docente);
    }
    $con->close();
    return $docentes;
  }

  /* OBTENER FECHAS */
  function get_fechas_by_curso($chc_id)
  {
    $con = conectar();
    $sql = "CALL sp_searchFechasByCursos(";
    $sql .= "'".$chc_id."');"; // p_cgh_id
    // return $sql;
    $datos = $con->query($sql);
    $fechas = array();
    while ($row = mysqli_fetch_array($datos)) {
      $fecha = [];
      $fecha['chf_id'] = $row['chf_id'];
      $fecha['chc_id'] = $row['chc_id'];
      $fecha['chf_fecha'] = $row['chf_fecha'];
      array_push($fechas, $fecha);
    }
    $con->close();
    return $fechas;
  }

/* LLENADO DE DOCUMENTO PDF */

  $carga_horaria = get_cargas_horarias($sem_id, $sec_id);
  
  if (count($carga_horaria) > 0) {
    $html = "<header>
              <table style='width: 100%;'>
                <tbody>
                  <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg.png' style='width: 100px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                      <div style='text-align: center; font-weight: bold;'>
                        CARGA HORARIA DEL SEMESTRE ACADÉMICO: ".$carga_horaria[0]['semestre']."
                      </div> 
                    </td>
                    <td style='width: 30%;'></td>
                  </tr>
                </tbody>
              </table>
            </header>
            <br>
            <body>
              <table class='table table-bordered'>
                <tbody>
                    <tr>
                        <td class='bg-azul text-center' colspan='7'><b>SEMESTRE ACADÉMICO: &nbsp;&nbsp;".$carga_horaria[0]['semestre']. "</b></td>
                    </tr>
                    <tr>
                      <td class='bg-azul text-center' style='vertical-align: middle; width: 180px;' colspan='7'>
                        <b>UNIDAD ACADÉMICA: &nbsp;&nbsp; " . $carga_horaria[0]['unidad'] . "</b>
                      </td>
                    </tr>
                </tbody>
              </table>";

    foreach ($carga_horaria as $carga_id => $carga) {
      $ciclos = get_ciclos_by_carga_horaria($carga['cgh_id']);
      if (count($ciclos) > 0) {
        $filas_curso_by_ciclo = 0;
        foreach ($ciclos as $ciclo) {
          $cursos = get_cursos_by_ciclo($ciclo['cgc_id']);
          $filas_curso_by_ciclo += count($cursos);
        }
        $html .= "<table class='table table-bordered' style='page-break-inside: avoid;'>
                    <tbody>
                      <tr>
                        <td class='bg-celeste text-center' style='vertical-align: middle; width: 190px;' colspan='7'>
                          <b>MENCIÓN: &nbsp;&nbsp;&nbsp; " . $carga['mencion'] . "</b>
                        </td>
                      </tr>
                      <tr>
                        <td class='table-primary text-center'><b>CICLO</b></td>
                        <td class='table-primary text-center'><b>CURSO</b></td>
                        <td class='table-primary text-center'><b>CRED.</b></td>
                        <td class='table-primary text-center'><b>DOCENTE</b></td>
                        <td class='table-primary text-center'><b>COND.</b></td>
                        <td class='table-primary text-center'><b>HORAS</b></td>
                        <td class='table-primary text-center'><b>FECHAS</b></td>
                      </tr>";
        foreach ($ciclos as $ciclo_id => $ciclo) {
          $cursos = get_cursos_by_ciclo($ciclo['cgc_id']);
          $html .= "<tr>";
          $html .= "<td class='text-center' style='vertical-align: middle; width: 50px;' rowspan='".(count($cursos)==0 ? '' : count($cursos))."'>
                      " . convertirARomano($ciclo['ciclo']) . "
                    </td>";
          if (count($cursos) > 0) {
            foreach ($cursos as $curso_id => $curso) {
                $html .= $curso_id == 0?'':'<tr>';
                $html .= "<td class='text-center' style='vertical-align: middle; width: 300px;'>
                              " . $curso['curso'] . "
                          </td>
                          <td class='text-center' style='vertical-align: middle; width: 50px;'>
                              " . $curso['cur_creditos'] . "
                          </td>";
                $docentes = get_docentes_by_curso($curso['chc_id']);
                if (count($docentes) > 0) {
                  foreach ($docentes as $index => $docente) {
                    $html .= "<td class='text-center' style='vertical-align: middle; width: 300px;'>
                              " . $docente['doc_nombres'] . "
                              </td>";
                    $html .= "<td class='text-center' style='vertical-align: middle; width: 120px;'>
                              " . $docente['doc_condicion'] . "
                              </td>";
                  }
                } else {
                  $html .= "<td class='text-center' style='vertical-align: middle;' colspan='2'>
                              Sin asignar docente
                            </td>";
                }
                
                $html .= "<td class='text-center' style='vertical-align: middle; width: 80px;'>
                              " . $curso['chc_horas'] . "
                          </td>
                          <td class='text-center' style='vertical-align: middle; width: 150px;'>";
                $fechas = get_fechas_by_curso($curso['chc_id']);
                foreach ($fechas as $index => $fecha) {
                  if ($index == 0) {
                    $html .= "<p><b>Inicio:</b> ".formatearFecha($fecha['chf_fecha'])."</p><br>";
                  }
                  if ($index == count($fechas) - 1) {
                    $html .= "<p><b>Fin:</b> ".formatearFecha($fecha['chf_fecha'])."</p>";
                  }
                }
                $html .= "</td></tr>";
            }
          } else {
              $html .= "<td class='text-center' style='vertical-align: middle;' colspan='6'>
                          Sin cursos registrados.
                        </td></tr>";
          }
          $html .= $ciclo_id == count($ciclos) - 1?"</tbody></table>":"";
        }
      }
    }
    $html .= "</body>";
  }else {
    $html = "<body>
              <table class='table table-bordered rounded'>
                <tbody>
                  <tr>
                    <td class='align-middle text-center'><b>Sin registros.</b></td>
                  </tr>
                </tbody>
              </table>
            </body>";
  }

  /* SOLO PARA PRUEBAS */
  // echo '<!DOCTYPE html>
  //         <html lang="en">
  //         <head>
  //           <meta charset="UTF-8">
  //           <meta name="viewport" content="width=device-width, initial-scale=1.0">
  //           <link rel="stylesheet" href="../css/process/pdfCargaHoraria.css">
  //         </head>';
  // echo $html;

  /* CREAR PDF */
  $mpdf = new \Mpdf\Mpdf();
  $mpdf->defaultfooterline = 0;
  // Definir contenido para el pie de página
  $footerContent = '<footer style="border-top: solid black 1px; text-align: left; font-size: 10px; position: fixed; bottom: 0; font-weight: bold;">
                      CRED. = CRÉDITOS &nbsp;&nbsp;&nbsp;&nbsp; COND. = CONDICIÓN
                    </footer>
                    <hr>
                    <div style="text-align: center; font-size: 10px;">
                        Página {PAGENO}/{nbpg} - Generado el ' . date('d-m-Y') . '
                    </div>';

  // Configurar el pie de página
  $mpdf->SetFooter($footerContent);

  // $stylesheet = file_get_contents('../css/process/kv-mpdf-bootstrap.css');
  $stylesheet1 = file_get_contents('../css/process/pdfCargaHoraria.css');

  // $mpdf->WriteHTML($stylesheet,\Mpdf\HTMLParserMode::HEADER_CSS);
  $mpdf->WriteHTML($stylesheet1,\Mpdf\HTMLParserMode::HEADER_CSS);

  // Write some HTML code:
  $mpdf->WriteHTML($html, \Mpdf\HTMLParserMode::HTML_BODY);

  // Nombre del archivo PDF
  $nombreArchivo = 'Carga-Horaria-'.$carga_horaria[0]['unidad'].'-'.$carga_horaria[0]['semestre'].'.pdf';

  // Output a PDF file directly to the browser with a specific filename
  $mpdf->Output($nombreArchivo, \Mpdf\Output\Destination::INLINE);

?>