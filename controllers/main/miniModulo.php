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
    $rutaFlayer = '../../assets/docs/Infografia_enlace.pdf';
    $rutaComunicado = '../../assets/docs/Comunicado_docente.pdf';
    $mail->addAddress($correo,$nombre);
    $mail->isHTML(true);
    $mail->Body = generarMensajeCorreo();
    $pdf = new CredencialDocente();
    $rutaPdf = $pdf->generarCredencial($nombre,$dni,$codigo,$cod_sem);
    $this->mail->addAttachment($rutaFlayer,'Infografia de enlaces');
    $this->mail->addAttachment($rutaComunicado,'Comunicado docentes');
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
    $mensaje .= '<p>Para soporte o ayuda con el registro o accesos al sistema comuníquese con el siguiente número:</p>';
    $mensaje .= '<ul><li>Anderson J. Zavaleta Simón / UTIC-EPG: 984 599 249</li>';
    $mensaje .= '<li>O puedes unirte al Grupo de Docentes de la EPG; Unete aquí:  : <a href="https://chat.whatsapp.com/EqKTfbg0XG1H1aWjpNLwsC ">Grupo de WhatsApp</a></li></ul>';
    $mensaje .= '<p><a href="http://www.epgnew.unitru.edu.pe">www.epgnew.unitru.edu.pe</a></p>';
    $mensaje .= '<p>Video tutorial para el proceso de registro de notas online: <a href="https://drive.google.com/file/d/1TUADa4xMJZF7cZDI65DlA9beSyxj4Rn4/view?usp=sharing">Enlace al video</a></p>';
    $mensaje .= '<p>Estimado Docente de la Escuela de Posgrado ingrese en el siguiente enlace para descargar el Manual del Docente para el uso del sistema de la EPG/UNT: <a href="https://drive.google.com/file/d/1xY3-vfL527XFuIZloVGVMFn8rYBwLFIP/view?usp=sharing">Manual SIGAP</a></p>';
    $mensaje .= '<p>Nota: Sigap es únicamente para la gestión académica, en la cual podrá registrar las asistencias y notas online, así como la validación de actas de los cursos.</p>';
    $mensaje .='<p>ATTE. Unidad de Tecnologías Informáticas y Comunicaciones de la EPG.</p>';
    return $mensaje;
}



?>