<?php 

date_default_timezone_set('America/Lima');
require '../../vendor/phpmailer/phpmailer/src/Exception.php';
require '../../vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../../vendor/phpmailer/phpmailer/src/SMTP.php';
include_once '../../controllers/main/utilidades/pdfCredencial.php';
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$correo="";
$codigo="";
$nombre="";
$dni="";
$cod_sem="";


if (isset($_POST['correo'])) 
{
    $correo = $_POST['correo'];
}
if (isset($_POST['codigo_docente'])) 
{
    $codigo = $_POST['codigo_docente'];
}
if (isset($_POST['nombre'])) 
{
    $nombre = $_POST['nombre'];
}
if (isset($_POST['dni'])) 
{
    $dni = $_POST['dni'];
}
if (isset($_POST['semestre'])) 
{
    $cod_sem = $_POST['semestre'];
}


try {
    $mail = new PHPMailer;
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->Port = 465;
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->SMTPAuth = true;
    $mail->Username = 'upg_utic@unitru.edu.pe';
    $mail->Password = 'ojvg gftu qpbd urtr';
    $mail->setFrom('upg_utic@unitru.edu.pe', 'UTIC POSGRADO');
    $mail->CharSet = 'UTF-8';  
    $mail->Subject = 'ENTREGA DE CREEDENCIALES DEL SIGAP - DOCENTE';
    $rutaManual = '../../assets/docs/ManualSigap.pdf';
    $mail->addAddress($correo,$nombre);
    $mail->isHTML(true);
    $mail->Body = generarMensajeCorreo();
    $pdf = new CredencialDocente();
    $rutaPdf = $pdf->generarCredencial($nombre,$dni,$codigo,$cod_sem);
    $mail->addAttachment($rutaManual,'Manual de docente para SIGAP');
    $mail->addAttachment($rutaPdf, $nombre);
    if ($mail->send()) {
        echo "SI";
    } else {
        echo "NO";
    }
    unlink($rutaPdf);
    $mail->smtpClose();
} catch (Exception $ex) {
    die("Error: " . $ex);
}


function generarMensajeCorreo()
{
    $mensaje = ' <p>Buenas tardes estimado Docentes de la ESCUELA DE POSGRADO, que vienen brindando sus servicios en distintos cursos asignados por la unidad académica, con el fin de regularizar 
    y sistematizar nuestros procesos constantemente hacemos llegar su credencial de acceso al sistema de registro de notas online, Dirigido por la Unidad de Tecnologías Informáticas y Comunicaciones de la EPG.</p>';
    $mensaje .= '<p>Este registro de notas online permitirá dar por finalizado el curso asignado a su carga horaria.</p>';
    $mensaje .= '<p>Se adjunta su Credencial y Manual de Docente para el registro de notas online.</p>';
    $mensaje .= '<p>Para soporte o ayuda con el registro o accesos al sistema comuníquese con los siguientes números:</p>';
    $mensaje .= '<ul><li>Anderson J. Zavaleta Simón / UTIC-EPG: 984 599 249</li><li>Ronald Córdova Paredes / SISTEMAS-EPG: 978 468 194</li></ul>';
    $mensaje .= '<p><a href="http://www.epgnew.unitru.edu.pe">www.epgnew.unitru.edu.pe</a></p>';
    $mensaje .= '<p>Video tutorial para el proceso de registro de notas online: <a href="https://drive.google.com/file/d/150q2t4Wo3k7RH_5L0UE9qaK4WiGjdtvB/view?usp=drive_link">Enlace al video</a></p>';
    $mensaje .='<p>ATTE. Unidad de Tecnologías Informáticas y Comunicaciones de la EPG.</p>';
    return $mensaje;
}



?>