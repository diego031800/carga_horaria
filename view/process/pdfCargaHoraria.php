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
function convertirARomano($numero)
{
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

function formatearFecha($fecha)
{
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
function get_carga_horaria($sem_id, $sec_id)
{
  $con = conectar();
  $sql = "CALL sp_GetCargaHoraria(";
  $sql .= "'" . $sem_id . "', "; // p_sem_id
  $sql .= "'" . $sec_id . "');"; // p_sec_id
  // return $sql;
  $datos = $con->query($sql);
  $data = array();
  $carga_horaria = array();
  $programas = array();
  $ciclos = array();
  $cursos = array();
  $grupos = array();
  $docentes = array();
  $fechas = array();

  while ($row = mysqli_fetch_assoc($datos)) {
    array_push($data, $row);
  }
  
  if (!isset($carga_horaria[0])) {
    $carga_horaria[0] = array(
      'sem_id' => $data[0]['sem_id'],
      'codSemestre' => $data[0]['codSemestre'],
      'semestre' => $data[0]['semestre'],
      'sec_id' => $data[0]['sec_id'],
      'unidad' => $data[0]['unidad']
    );
    $carga_horaria[0]['programas'] = array();
  }

  foreach ($data as $fila) {
    $prg_id = $fila['prg_id'];

    if (!isset($programas[$prg_id])) {
      $programas[$prg_id] = [
        'sem_id' => $fila['sem_id'],
        'prg_id' => $fila['prg_id'],
        'mencion' => $fila['mencion'],
        'ciclos' => array()
      ];
      // return $programas[$prg_id];
      $carga_horaria[0]['programas'][$prg_id] = $programas[$prg_id];
    }

    $cgc_id = $fila['cgc_id'];

    if (!isset($ciclos[$cgc_id])) {
      $ciclos[$cgc_id] = array(
        'prg_id' => $fila['prg_id'],
        'cgc_id' => $fila['cgc_id'],
        'ciclo' => $fila['ciclo'],
        'cursos' => array()
      );
      if ($ciclos[$cgc_id]['prg_id'] == $carga_horaria[0]['programas'][$prg_id]['prg_id']) {
        $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id] = $ciclos[$cgc_id];
      }
    }

    $chc_id = $fila['chc_id'];

    if (!isset($cursos[$chc_id])) {
      $cursos[$chc_id] = array(
        'cgc_id' => $fila['cgc_id'],
        'chc_id' => $fila['chc_id'],
        'curso' => $fila['curso'],
        'cur_tipo' => $fila['cur_tipo'],
        'tipo_curso' => $fila['tipo_curso'],
        'cur_calidad' => $fila['cur_calidad'],
        'calidad_curso' => $fila['calidad_curso'],
        'cur_creditos' => $fila['cur_creditos'],
        'chc_horas' => $fila['chc_horas'],
        'grupos' => array()
      );

      if ($cursos[$chc_id]['cgc_id'] == $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cgc_id']) {
        $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id] = $cursos[$chc_id];
      }
    }

    $ccg_id = $fila['ccg_id'];

    if (!isset($grupos[$ccg_id])) {
      $grupos[$ccg_id] = array(
        'chc_id' => $fila['chc_id'],
        'ccg_id' => $fila['ccg_id'],
        'grupo' => $fila['grupo'],
        'docentes' => array(),
        'fechas' => array()
      );

      if ($grupos[$ccg_id]['chc_id'] == $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id]['chc_id']) {
        $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id]['grupos'][$ccg_id] = $grupos[$ccg_id];
      }
    }

    $cgd_id = $fila['cgd_id'];

    if (!isset($docentes[$cgd_id])) {
      $docentes[$cgd_id] = array(
        'ccg_id' => $fila['ccg_id'],
        'cgd_id' => $fila['cgd_id'],
        'titular' => $fila['titular'],
        'doc_condicion' => $fila['condicion'],
        'doc_documento' => $fila['doc_documento'],
        'doc_nombres' => $fila['doc_nombres'],
      );

      if ($docentes[$cgd_id]['ccg_id'] == $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id]['grupos'][$ccg_id]['ccg_id']) {
        $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id]['grupos'][$ccg_id]['docentes'][$cgd_id] = $docentes[$cgd_id];
      }
    }

    $cgf_id = $fila['cgf_id'];

    if (!isset($fechas[$cgf_id])) {
      $fechas[$cgf_id] = array(
        'ccg_id' => $fila['ccg_id'],
        'cgf_id' => $fila['cgf_id'],
        'fecha' => $fila['fecha'],
      );

      if ($fechas[$cgf_id]['ccg_id'] == $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id]['grupos'][$ccg_id]['ccg_id']) {
        $carga_horaria[0]['programas'][$prg_id]['ciclos'][$cgc_id]['cursos'][$chc_id]['grupos'][$ccg_id]['fechas'][$cgf_id] = $fechas[$cgf_id];
      }
    }
  }

  return $carga_horaria;
}

/* CONTEO DE FILAS */
function get_nro_total_filas($carga_horaria, $limite, $id)
{
  try {
    $total_filas = 0;
    if (count($carga_horaria) > 0) {
      /* FUNCION PARA OBTENER EL NUMERO TOTAL DE FILAS POR UNIDAD */
      foreach ($carga_horaria[0]['programas'] as $programa) {
        $nro_filas_x_mencion = 0;
        $ciclos = $programa['ciclos'];
        if (count($ciclos) > 0) {
          foreach ($ciclos as $ciclo) {
            $nro_filas_x_ciclo = 0;
            $cursos = $ciclo['cursos'];
            if (count($cursos) > 0) {
              foreach ($cursos as $curso) {
                $nro_filas_x_curso = 0;
                $grupos = $curso['grupos'];
                if (count($grupos) > 0) {
                  foreach ($grupos as $grupo) {
                    $nro_filas_x_grupo = 0;
                    $docentes = $grupo['docentes'];
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
        if ($limite == 'mencion' && $programa['prg_id'] == $id) {
          return $nro_filas_x_mencion;
        }
      }
    }
    return $total_filas;
  } catch (Exception $ex) {
    die("Error: " . $ex);
  }
}

/* LLENADO DE DOCUMENTO PDF */

/* OBTENIENDO DATOS DE LA CARGA HORARIA */
$carga_horaria = get_carga_horaria($sem_id, $sec_id);

if (count($carga_horaria) > 0) {
  $html = "<header>
              <table style='width: 100%;'>
                <tbody>
                  <tr>
                    <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
                    <td class='text-center' style='width: 40%;'>
                      <div style='text-align: center; font-weight: bold;'>
                        CARGA HORARIA DEL SEMESTRE ACADÉMICO: " . $carga_horaria[0]['semestre'] . "
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
                        <td class='bg-azul text-center' colspan='7'><b>SEMESTRE ACADÉMICO: &nbsp;&nbsp;" . $carga_horaria[0]['semestre'] . "</b></td>
                    </tr>
                    <tr>
                      <td class='bg-azul text-center' style='vertical-align: middle; width: 180px;' colspan='7'>
                        <b>UNIDAD ACADÉMICA: &nbsp;&nbsp; " . $carga_horaria[0]['unidad'] . "</b>
                      </td>
                    </tr>
                </tbody>
              </table>";
  foreach ($carga_horaria[0]['programas'] as $carga) {
    /* OBTENIENDO DATOS DEL CICLO ACADÉMICO */
    $ciclos = $carga['ciclos'];
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
      $fila_ciclo = 0;
      foreach ($ciclos as $ciclo) {
        /* OBTENIENDO DATOS DE LOS CURSOS */
        $filas_by_ciclo = get_nro_total_filas($carga_horaria, 'ciclo', $ciclo['cgc_id']);
        $cursos = $ciclo['cursos'];
        $html .= "<tr>";
        $html .= "<td class='text-center' style='vertical-align: middle; width: 50px;' rowspan='" . ($filas_by_ciclo == 0 ? '' : $filas_by_ciclo) . "'>
                      " . convertirARomano($ciclo['ciclo']) . "
                    </td>";
        if (count($cursos) > 0) {
          $fila_curso = 0;
          foreach ($cursos as $curso) {
            $filas_by_curso = get_nro_total_filas($carga_horaria, 'curso', $curso['chc_id']);
            $html .= $fila_curso == 0 ? '' : '<tr>';
            $html .= "<td class='text-center' style='vertical-align: middle; width: 300px;' rowspan='" . ($filas_by_curso == 0 ? '' : $filas_by_curso) . "'>
                            " . $curso['curso'] . "<br>" . ($curso['cur_calidad'] == '0001' ? '<b>(ELECTIVO)</b>' : '') . "
                          </td>
                          <td class='text-center' style='vertical-align: middle; width: 50px;' rowspan='" . ($filas_by_curso == 0 ? '' : $filas_by_curso) . "'>
                            " . $curso['cur_creditos'] . "
                          </td>
                          <td class='text-center' style='vertical-align: middle; width: 80px;' rowspan='" . ($filas_by_curso == 0 ? '' : $filas_by_curso) . "'>
                            " . $curso['chc_horas'] . "
                          </td>";
            /* OBTENIENDO DATOS DE LOS GRUPOS */
            $grupos = $curso['grupos'];
            if (count($grupos) > 0) {
              $fila_grupo = 0;
              foreach ($grupos as $grupo) {
                $filas_by_grupo = get_nro_total_filas($carga_horaria, 'grupo', $grupo['ccg_id']);
                $html .= $fila_grupo == 0 ? '' : '<tr>';
                $html .= "<td class='text-center' style='vertical-align: middle; width: 80px;' rowspan='" . ($filas_by_grupo == 0 ? '' : $filas_by_grupo) . "'>
                              " . ($grupo['grupo'] == 1 ? 'A' : 'B') . "
                              </td>";
                /* OBTENIENDO DATOS DE LOS DOCENTES */
                $docentes = $grupo['docentes'];
                /* OBTENIENDO DATOS DE LAS FECHAS */
                $fechas = $grupo['fechas'];
                if (count($docentes) > 0) {
                  $fila_docente = 0;
                  foreach ($docentes as $docente) {
                    $html .= $fila_docente == 0 ? '' : '<tr>';
                    $html .= "<td class='text-center' style='vertical-align: middle; width: 300px;'>
                                  " . $docente['doc_nombres'] . "<br>" . ($docente['titular'] == 1 ? '<b>(TITULAR)</b>' : '') . "
                                  </td>";
                    $html .= "<td class='text-center' style='vertical-align: middle; width: 120px;'>
                                  " . $docente['doc_condicion'] . "
                                  </td>";
                    if ($fila_docente == 0) {
                      $html .= "<td class='text-center' style='vertical-align: middle; width: 150px;' rowspan='" . (count($docentes) == 0 ? '' : count($docentes)) . "'>";
                      $fila_fecha = 0;
                      foreach ($fechas as $fecha) {
                        if ($fila_fecha == 0) {
                          $html .= "<p><b>Inicio:</b> " . formatearFecha($fecha['fecha']) . "</p><br>";
                        }
                        if ($fila_fecha == count($fechas) - 1) {
                          $html .= "<p><b>Fin:</b> " . formatearFecha($fecha['fecha']) . "</p>";
                        }
                        $fila_fecha ++;
                      }
                      $html .= "</td>";
                    }
                    $html .= "</tr>";
                    $fila_docente ++;
                  }
                } else {
                  $html .= "<td class='text-center' style='vertical-align: middle;' colspan='2'>
                                  Sin asignar docente
                                </td>";
                  $html .= "<td class='text-center' style='vertical-align: middle; width: 150px;' rowspan='" . (count($docentes) == 0 ? '' : count($docentes)) . "'>";
                  $fila_fecha = 0;
                  foreach ($fechas as $fecha) {
                    if ($fila_fecha == 0) {
                      $html .= "<p><b>Inicio:</b> " . formatearFecha($fecha['chf_fecha']) . "</p><br>";
                    }
                    if ($fila_fecha == count($fechas) - 1) {
                      $html .= "<p><b>Fin:</b> " . formatearFecha($fecha['chf_fecha']) . "</p>";
                    }
                  }
                  $html .= "</td></tr>";
                  $fila_fecha++;
                }
                $fila_grupo++;
              }
            }
            $fila_curso ++;
          }
        } else {
          $html .= "<td class='text-center' style='vertical-align: middle;' colspan='6'>
                          Sin cursos registrados.
                        </td></tr>";
        }
        $html .= $fila_ciclo == count($ciclos) - 1 ? "</tbody></table>" : "";
        $fila_ciclo++;
      }
    }
  }
  $html .= "</body>";
} else {
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
$mpdf->WriteHTML($stylesheet1, \Mpdf\HTMLParserMode::HEADER_CSS);

// Write some HTML code:
$mpdf->WriteHTML($html, \Mpdf\HTMLParserMode::HTML_BODY);

// Nombre del archivo PDF
$nombreArchivo = 'CARGA_HORARIA_' . $carga_horaria[0]['unidad'] . '_' . $carga_horaria[0]['semestre'] . '.pdf';

// Output a PDF file directly to the browser with a specific filename
$mpdf->Output($nombreArchivo, \Mpdf\Output\Destination::INLINE);
?>