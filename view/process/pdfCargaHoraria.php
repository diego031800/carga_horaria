<?php
  require_once('../../models/conecction.php');
  require_once '../../vendor/autoload.php';

  date_default_timezone_set('America/Lima');

	session_start();

	$time = time();

  $sem_id = 0;
  $sec_id = 0;

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
    $sql = "CALL sp_GetCargaHoraria(";
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
      $ch['estado'] = $row['estado'];
      array_push($carga_horaria, $ch);
    }
    $con->close();
    return $carga_horaria;
  }

  /* OBTENER CICLOS */
  function get_ciclos_by_carga_horaria($cgh_id)
  {
    $con = conectar();
    $sql = "CALL sp_GetCicloByCargaHoraria(";
    $sql .= "'".$cgh_id."');"; // p_sec_id
    // return $sql;
    $datos = $con->query($sql);
    $ciclos = array();
    while ($row = mysqli_fetch_array($datos)) {
      $ciclo = [];
      $ciclo['cgc_id'] = $row['cgc_id'];
      $ciclo['cgh_id'] = $row['cgh_id'];
      $ciclo['ciclo'] = $row['ciclo'];
      $ciclo['estado'] = $row['estado'];
      array_push($ciclos, $ciclo);
    }
    $con->close();
    return $ciclos;
  }

  /* OBTENER CURSOS */
  function get_cursos_by_ciclo($cgc_id)
  {
    $con = conectar();
    $sql = "CALL sp_GetCursosByCiclo(";
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
      $curso['cur_tipo'] = $row['cur_tipo'];
      $curso['tipo'] = $row['tipo'];
      $curso['cur_calidad'] = $row['cur_calidad'];
      $curso['calidad'] = $row['calidad'];
      $curso['chc_horas'] = $row['chc_horas'];
      $curso['estado'] = $row['estado'];
      array_push($cursos, $curso);
    }
    $con->close();
    return $cursos;
  }

  /* OBTENER GRUPOS */
  function get_grupos_by_curso($chc_id)
  {
    $con = conectar();
    $sql = "CALL sp_GetGruposByCurso(";
    $sql .= "'". $chc_id."');"; // p_chc_id
    // return $sql;
    $datos = $con->query($sql);
    $grupos = array();
    while ($row = mysqli_fetch_array($datos)) {
      $grupo = [];
      $grupo['ccg_id'] = $row['ccg_id'];
      $grupo['chc_id'] = $row['chc_id'];
      $grupo['sem_id'] = $row['sem_id'];
      $grupo['prg_id'] = $row['prg_id'];
      $grupo['grupo'] = $row['grupo'];
      $grupo['estado'] = $row['estado'];
      array_push($grupos, $grupo);
    }
    $con->close();
    return $grupos;
  }

  /* OBTENER DOCENTES */
  function get_docentes_by_grupo($ccg_id)
  {
    $con = conectar();
    $sql = "CALL sp_GetDocentesByGrupo(";
    $sql .= "'". $ccg_id."');"; // p_ccg_id
    // return $sql;
    $datos = $con->query($sql);
    $docentes = array();
    while ($row = mysqli_fetch_array($datos)) {
      $docente = [];
      $docente['cgd_id'] = $row['cgd_id'];
      $docente['ccg_id'] = $row['ccg_id'];
      $docente['cgd_titular'] = $row['cgd_titular'];
      $docente['cgd_horas'] = $row['cgd_horas'];
      $docente['cgd_fecha_inicio'] = $row['cgd_fecha_inicio'];
      $docente['cgd_fecha_fin'] = $row['cgd_fecha_fin'];
      $docente['doc_condicion'] = $row['doc_condicion'];
      $docente['doc_id'] = $row['doc_id'];
      $docente['doc_codigo'] = $row['doc_codigo'];
      $docente['doc_documento'] = $row['doc_documento'];
      $docente['doc_nombres'] = $row['doc_nombres'];
      $docente['doc_celular'] = $row['doc_celular'];
      $docente['doc_email'] = $row['doc_email'];
      $docente['estado'] = $row['estado'];
      array_push($docentes, $docente);
    }
    $con->close();
    return $docentes;
  }

  /* OBTENER FECHAS */
  function get_fechas_by_grupo($ccg_id)
  {
    $con = conectar();
    $sql = "CALL sp_GetFechasByGrupo(";
    $sql .= "'". $ccg_id."');"; // p_ccg_id
    // return $sql;
    $datos = $con->query($sql);
    $fechas = array();
    while ($row = mysqli_fetch_array($datos)) {
      $fecha = [];
      $fecha['cgf_id'] = $row['cgf_id'];
      $fecha['ccg_id'] = $row['ccg_id'];
      $fecha['fecha'] = $row['fecha'];
      $fecha['estado'] = $row['estado'];
      array_push($fechas, $fecha);
    }
    $con->close();
    return $fechas;
  }

/* CONTEO DE FILAS */
function get_nro_total_filas($limite, $id, $sem_id, $sec_id)
{
  try {
    $carga_horaria = get_cargas_horarias($sem_id, $sec_id);
    // return json_encode($carga_horaria);
    $total_filas = 0;
    if (count($carga_horaria) > 0) {
      /* OBTENER EL NUMERO TOTAL DE FILAS POR UNIDAD */
      foreach ($carga_horaria as $carga) {
        $nro_filas_x_mencion = 0;
        $ciclos = get_ciclos_by_carga_horaria($carga['cgh_id']);
        if (count($ciclos) > 0) {
          /* OBTENER EL NUMERO TOTAL DE FILAS POR CICLO */
          foreach ($ciclos as $ciclo) {
            $nro_filas_x_ciclo = 0;
            $cursos = get_cursos_by_ciclo($ciclo['cgc_id']);
            if (count($cursos) > 0) {
              /* OBTENER EL NUMERO TOTAL DE FILAS POR CURSO */
              foreach ($cursos as $curso) {
                $nro_filas_x_curso = 0;
                $grupos = get_grupos_by_curso($curso['chc_id']);
                if (count($grupos) > 0) {
                  /* OBTENER EL NUMERO TOTAL DE FILAS POR GRUPO */
                  foreach ($grupos as $grupo) {
                    $nro_filas_x_grupo = 0;
                    $docentes = get_docentes_by_grupo($grupo['ccg_id']);
                    if (count($docentes)) {
                      $total_filas += count($docentes);
                      $nro_filas_x_mencion += count($docentes);
                      $nro_filas_x_ciclo += count($docentes);
                      $nro_filas_x_curso += count($docentes);
                      $nro_filas_x_grupo += count($docentes);
                    } else {
                      $total_filas++;
                      $nro_filas_x_mencion++;
                      $nro_filas_x_ciclo++;
                      $nro_filas_x_curso++;
                      $nro_filas_x_grupo++;
                    }
                    if ($limite == 'grupo' && $grupo['ccg_id'] == $id) {
                      return $nro_filas_x_grupo;
                    }
                  }
                }
                if ($limite == 'curso' && $curso['chc_id'] == $id) {
                  return $nro_filas_x_curso;
                }
              }
            }
            if ($limite == 'ciclo' && $ciclo['cgc_id'] == $id) {
              return $nro_filas_x_ciclo;
            }
          }
        }
        if ($limite == 'mencion' && $carga['cgh_id'] == $id) {
          return $nro_filas_x_mencion;
        }
      }
    }
    return $total_filas;
  } catch (Exception $ex) {
    die("Error: ".$ex);
  }
}

/* LLENADO DE DOCUMENTO PDF */

  /* OBTENIENDO DATOS DE LA CARGA HORARIA */
  $carga_horaria = get_cargas_horarias($sem_id, $sec_id);
  
  if (count($carga_horaria) > 0) {
    $html = "<header>
              <table style='width: 100%;'>
                <tbody>
                  <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
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
      /* OBTENIENDO DATOS DEL CICLO ACADÉMICO */
      $ciclos = get_ciclos_by_carga_horaria($carga['cgh_id']);
      if (count($ciclos) > 0) {
        $html .= "<table class='table table-bordered' style='page-break-inside: avoid;'>
                    <tbody>
                      <tr>
                        <td class='bg-celeste text-center' style='vertical-align: middle; width: 190px;' colspan='8'>
                          <b>MENCIÓN: &nbsp;&nbsp;&nbsp; " . $carga['mencion'] . "</b>
                        </td>
                      </tr>
                      <tr>
                        <td class='table-primary text-center'><b>CICLO</b></td>
                        <td class='table-primary text-center'><b>CURSO</b></td>
                        <td class='table-primary text-center'><b>CRED.</b></td>
                        <td class='table-primary text-center'><b>HORAS</b></td>
                        <td class='table-primary text-center'><b>GRUPO</b></td>
                        <td class='table-primary text-center'><b>DOCENTE</b></td>
                        <td class='table-primary text-center'><b>COND.</b></td>
                        <td class='table-primary text-center'><b>FECHAS</b></td>
                      </tr>";
        foreach ($ciclos as $ciclo_id => $ciclo) {
          /* OBTENIENDO DATOS DE LOS CURSOS */
          $filas_by_ciclo = get_nro_total_filas('ciclo', $ciclo['cgc_id'], $sem_id, $sec_id);
          $cursos = get_cursos_by_ciclo($ciclo['cgc_id']);
          $html .= "<tr>";
          $html .= "<td class='text-center' style='vertical-align: middle; width: 50px;' rowspan='".($filas_by_ciclo==0 ? '' : $filas_by_ciclo)."'>
                      " . convertirARomano($ciclo['ciclo']) . "
                    </td>";
          if (count($cursos) > 0) {
            foreach ($cursos as $curso_id => $curso) {
                $filas_by_curso = get_nro_total_filas('curso', $curso['chc_id'], $sem_id, $sec_id);
                $html .= $curso_id == 0?'':'<tr>';
                $html .= "<td class='text-center' style='vertical-align: middle; width: 300px;' rowspan='".($filas_by_curso==0 ? '' : $filas_by_curso)."'>
                            " . $curso['curso'] . "<br>".($curso['cur_calidad']=='0001'?'<b>(ELECTIVO)</b>':'')."
                          </td>
                          <td class='text-center' style='vertical-align: middle; width: 50px;' rowspan='".($filas_by_curso==0 ? '' : $filas_by_curso)."'>
                            " . $curso['cur_creditos'] . "
                          </td>
                          <td class='text-center' style='vertical-align: middle; width: 80px;' rowspan='".($filas_by_curso==0 ? '' : $filas_by_curso)."'>
                            " . $curso['chc_horas'] . "
                          </td>";
                /* OBTENIENDO DATOS DE LOS GRUPOS */
                $grupos = get_grupos_by_curso($curso['chc_id']);
                if (count($grupos) > 0) {
                  foreach ($grupos as $grupo_id => $grupo) {
                    $filas_by_grupo = get_nro_total_filas('grupo', $grupo['ccg_id'], $sem_id, $sec_id);
                    $html .= $grupo_id == 0?'':'<tr>';
                    $html .= "<td class='text-center' style='vertical-align: middle; width: 80px;' rowspan='".($filas_by_grupo==0 ? '' : $filas_by_grupo)."'>
                              " . ($grupo['grupo']==1?'A':'B') . "
                              </td>";
                    /* OBTENIENDO DATOS DE LOS DOCENTES */
                    $docentes = get_docentes_by_grupo($grupo['ccg_id']);
                    /* OBTENIENDO DATOS DE LAS FECHAS */
                    $fechas = get_fechas_by_grupo($grupo['ccg_id']);
                    if (count($docentes) > 0) {
                      foreach ($docentes as $docente_id => $docente) {
                        $html .= $docente_id == 0?'':'<tr>';
                        $html .= "<td class='text-center' style='vertical-align: middle; width: 300px;'>
                                  " . $docente['doc_nombres'] . "<br>".($docente['cgd_titular']==1?'<b>(TITULAR)</b>':'')."
                                  </td>";
                        $html .= "<td class='text-center' style='vertical-align: middle; width: 120px;'>
                                  " . $docente['doc_condicion'] . "
                                  </td>";
                        if ($docente_id == 0) {
                          $html .= "<td class='text-center' style='vertical-align: middle; width: 150px;' rowspan='".(count($docentes)==0?'':count($docentes))."'>";
                          foreach ($fechas as $fecha_id => $fecha) {
                            if ($fecha_id == 0) {
                              $html .= "<p><b>Inicio:</b> ".formatearFecha($fecha['fecha'])."</p><br>";
                            }
                            if ($fecha_id == count($fechas) - 1) {
                              $html .= "<p><b>Fin:</b> ".formatearFecha($fecha['fecha'])."</p>";
                            }
                          }
                          $html .= "</td>";
                        }
                        $html .= "</tr>";
                      }
                    } else {
                      $html .= "<td class='text-center' style='vertical-align: middle;' colspan='2'>
                                  Sin asignar docente
                                </td>";
                      $html .= "<td class='text-center' style='vertical-align: middle; width: 150px;' rowspan='" . (count($docentes) == 0 ? '' : count($docentes)) . "'>";
                      foreach ($fechas as $fecha_id => $fecha) {
                        if ($index == 0) {
                          $html .= "<p><b>Inicio:</b> ".formatearFecha($fecha['chf_fecha'])."</p><br>";
                        }
                        if ($index == count($fechas) - 1) {
                          $html .= "<p><b>Fin:</b> ".formatearFecha($fecha['chf_fecha'])."</p>";
                        }
                      }
                      $html .= "</td></tr>";
                    }
                  }
                }
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
  $nombreArchivo = 'CARGA_HORARIA_'.$carga_horaria[0]['unidad'].'_'.$carga_horaria[0]['semestre'].'.pdf';

  // Output a PDF file directly to the browser with a specific filename
  $mpdf->Output($nombreArchivo, \Mpdf\Output\Destination::INLINE);

?>