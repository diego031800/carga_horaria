<?php 
include_once '../../controllers/main/enviarCorreos.php';
require_once '../../vendor/autoload.php';


session_start();

$destinatarios = array(
    array('correo' => 'gayalam@unitru.edu.pe', 'nombre' => 'Gerald'),
    array('correo' => 'geraldayala87@gmail.com', 'nombre' => 'Eduardo')
    // Agrega más objetos/anotaciones según sea necesario
);

$correoCargaHoraria = new CorreoCargaHoraria();
$datareporte = $correoCargaHoraria->enviarCredenciales($destinatarios);

$html = "<header>
<table style='width: 100%;'>
  <tbody>
    <tr>
      <td style='width: 30%;'> <img src='../../assets/images/documentos/img_upg_CMYK.png' style='width: 160px; height: auto;'> </td>
      <td class='text-center' style='width: 40%;'>
        <div style='text-align: center; font-weight: bold;'>
          Reporte de envio de credenciales: 
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
          <td class='bg-azul text-center' colspan='7'><b>SEMESTRE ACADÉMICO: &nbsp;&nbsp; PRUEBA</b></td>
      </tr>
      <tr>
        <td class='bg-azul text-center' style='vertical-align: middle; width: 180px;' colspan='7'>
          <b>UNIDAD ACADÉMICA: &nbsp;&nbsp; PRUEBA</b>
        </td>
      </tr>
  </tbody>
</table>";

?>