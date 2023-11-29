<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/phpmailer/phpmailer/src/Exception.php';
require 'vendor/phpmailer/phpmailer/src/PHPMailer.php';
require 'vendor/phpmailer/phpmailer/src/SMTP.php';

$parametros = array();
$parametros['sec_id'] = '';
$parametros['prg_id'] = '';

if (isset($_POST['opcion'])) {
    $parametros['opcion'] = $_POST['opcion'];
}

$mail = new PHPMailer;
$mail->isSMTP();
$mail->Host = 'smtp.gmail.com';
$mail->Port = 465;
$mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
$mail->SMTPAuth = true;
$mail->Username = 'upg_utic@unitru.edu.pe';
$mail->Password = 'ojvg gftu qpbd urtr';
$mail->setFrom('upg_utic@unitru.edu.pe', 'UTIC POSGRADO');
$mail->addAddress('gayalam@unitru.edu.pe', 'Gerald');
$mail->Subject = 'Cierre de carga horaria del SEMESTRE ACTUAL DE LA UNIDAD DE CIENCIAS DE LA COMUNICACIÓN';
$mail->isHTML(true);
$mensaje = '<h1>¡Bienvenido al semestre 2023-II!</h1>';
$mensaje .= ' <p>Buenos días estimado Docentes de la ESCUELA DE POSGRADO, se le hace el envío de sus credenciales para ingresar al sistema SIGAP correspondiente al semestre
2023-II; en el cual podrán descargar la lista de alumnos matriculados en el curso que esté dictando, en la infografía podrá ver de manera gráfica los pasos a seguir.</p>';
$mensaje .= '<p>En el menú de la izquierda, verá una opción que dice “Aula virtual” (como se muestra en el comunicado) en la cual podrá ir al aula virtual, las formas de 
acceder se explican detalladamente en el comunicado.</p>';
$mensaje .= '<p>Para soporte o ayuda comuníquese con los siguientes números:</p>';
$mensaje .= '<ul><li>Anderson J. Zavaleta Simón / UTIC-EPG: 984 599 249</li><li>Ronald Córdova Paredes / SISTEMAS-EPG: 978 468 194</li></ul>';
$mensaje .= '<p><a href="http://www.epgnew.unitru.edu.pe">www.epgnew.unitru.edu.pe</a></p>';
$mensaje .= '<p>Video tutorial para el proceso de registro de notas online: <a href="https://drive.google.com/file/d/1tWDH4GhpmtW3mulvoW3Cib2J0EqZtzjx/view?usp=drive_link">Enlace al video</a></p>';
$mensaje .='<p>ATTE. Unidad de Tecnologías Informáticas y Comunicaciones de la EPG.</p>';
$mail->Body = $mensaje;

$rutaManual = 'assets/docs/ManualSigap.pdf';
$rutaFlayer = 'assets/docs/Infografia_enlace.pdf';
$rutaComunicado = 'assets/docs/Comunicado_docente.pdf';
$mail->addAttachment($rutaManual,'Manual de docente para SIGAP');
$mail->addAttachment($rutaFlayer,'Infografia de enlaces');
$mail->addAttachment($rutaComunicado,'Comunicado docentes');

$itemEnviado = array(
    'nombre' => 'Gerald',
    'correo' => 'gayalam@unitru.edu.pe',
    'envio' => 0,
    'fechahora' => '',
    'error' => '',
    'sem_id' => '',
    'sec_id' => '',
    'doc_id' => 0
);

if ($mail->send()) {
    $itemEnviado['envio'] = 1;
} else {
    $itemEnviado['envio'] = 0;
    $error = $this->mail->ErrorInfo;
    $itemEnviado['error'] = $error;
}
$itemEnviado['doc_id'] = 1;
$itemEnviado['sem_id'] = 70;
$itemEnviado['sec_id'] = 4;
//unlink($rutaPdf);
$itemEnviado['fechahora'] = date('Y-m-d H:i:s');

echo 'SÍ';