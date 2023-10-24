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
$mail->Body = '<p>Buenos días, les saluda cordialmente la Unidad de Tecnologías Informáticas y Comunicaciones / Sistemas de la EPG para comunicarles lo siguiente:</p>
    
<p>Según la Propuesta de Evaluación y Seguimiento al Desempeño Docente de la Escuela de Posgrado de la Universidad Nacional de Trujillo, se les hace llegar a ustedes la encuesta de Desempeño Docente de forma sistemática al término de cada curso del Semestre Académico 2023-I.</p>

<p>Indicaciones:</p>
<ul>
    <li>Para participar en la encuesta, es necesario ingresar al PDF adjunto y hacer clic en el botón ""INICIAR ENCUESTA"" que lo llevará al formulario de la encuesta.</li>
    <li>Una vez ingrese al formulario, usted DEBERÁ seleccionar al profesor y el curso que le dictó, y responder a las preguntas.</li>
    <li>RECUERDE que usted deberá responder la encuesta una vez (1) por cada curso que haya culminado. Por ejemplo, si lleva 4 cursos este ciclo y ya terminó 3, usted DEBERÁ responder el formulario 3 veces, solo para los cursos que ya terminó (RECORDAR: SOLO DE LOS CURSOS QUE YA CULMINARON).</li>
    <li>Si anteriormente ya ha respondido la encuesta para un curso, NO DEBERÁ responder de nuevo la encuesta para dicho curso. Por ejemplo, si lleva 4 cursos, culminó 3 y ya respondió el formulario para un (1) curso, DEBERÁ responder el formulario para los 2 cursos restantes ya culminados.</li>
</ul>

<p>Atentamente,<br>Unidad de Tecnologías Informáticas y Comunicaciones / Sistemas de la EPG.</p><br>
<img src="cid:NOMBRE" alt="Imagen incrustada">
';

$rutaImagenAdjunta = 'assets/images/documentos/img_upg.png';
$mail->addEmbeddedImage($rutaImagenAdjunta, 'NOMBRE');

if ($mail->send()) {
    echo 'Correo enviado con éxito';
} else {
    echo 'Error al enviar el correo: ' . $mail->ErrorInfo;
}
