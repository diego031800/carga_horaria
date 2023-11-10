<?php 

date_default_timezone_set('America/Lima');
require '../../vendor/phpmailer/phpmailer/src/Exception.php';
require '../../vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../../vendor/phpmailer/phpmailer/src/SMTP.php';
include_once '../../controllers/main/pdfCredencial.php';
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$destinatarios = array(
    /*(object) array('correo' => 'bgutierrez@unitru.edu.pe', 'nombre' => 'GUTIERREZ PEREZ BLANCA NELLY','codigo' => 'GUPÉ9545', 'documento'=> '18197726'),
    (object) array('correo' => 'cvenegas@unitru.edu.pe', 'nombre' => 'PIMINCHUMO CECILIO VENEGAS','codigo' => 'VEPI4596', 'documento'=> '17971014'),
    (object) array('correo' => 'alacruz@unitru.edu.pe', 'nombre' => 'LA CRUZ TORRES ANGEL IGNACIO','codigo' => 'DETO7692', 'documento'=> '17891610'),
    (object) array('correo' => 'arafaels@unitru.edu.pe', 'nombre' => 'RAFAEL SANCHEZ AUREA ELIZABETH','codigo' => 'RASA4549', 'documento'=> '17930565'),
    (object) array('correo' => 'ranticona@unitru.edu.pe', 'nombre' => 'ANTICONA SANDOVAL ROSA UBALDINA','codigo' => 'ANSA7169', 'documento'=> '17855357'),*/
    (object) array('correo' => 'mbocanegra@unitru.edu.pe', 'nombre' => 'BOCANEGRA RODRIGUEZ DE CASTRO MARIA DEL PILAR','codigo' => 'BORO4259', 'documento'=> '18834971'),
    (object) array('correo' => 'manzanillo1962@gmail.com', 'nombre' => 'PONCE RUIZ DIONISIO VITALIO','codigo' => 'PORU4057', 'documento'=> '1756436430'),
    (object) array('correo' => 'edcampechano@unitru.edu.pe', 'nombre' => 'CAMPECHANO ESCALONA EDUARDO JOSE','codigo' => 'CAES8006', 'documento'=> '00157237'),
    (object) array('correo' => 'eaguilarc@unitru.edu.pe', 'nombre' => 'AGUILAR CARRERA ERIKA DEL CARMEN','codigo' => 'AGCA7939', 'documento'=> '19082578')
    // Agrega más objetos/anotaciones según sea necesario
);
// Crea el PDF con los datos del usuario y lo guarda en una variable


try {
    foreach ($destinatarios as $item) {
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
        $mail->addAddress($item->correo,$item->nombre);
        $mail->isHTML(true);
        $mail->Body = generarMensajeCorreo($item->nombre,$item->documento,$item->codigo,'SMTR58592023');
        $pdf = new CredencialDocente();
        $rutaPdf = $pdf->generarCredencial($item->nombre,$item->documento,$item->codigo,'SMTR58592023');
        $mail->addAttachment($rutaManual,'Manual de docente para SIGAP');
        $mail->addAttachment($rutaPdf, $item->nombre);
        //unlink($rutaPdf);
        $mail->smtpClose();
        if ($mail->send()) {
            echo $item->nombre.' SI --';
        } else {
            echo $item->nombre.' NO --';
        }
        
    }
} catch (Exception $ex) {
    die("Error: " . $ex);
}


function generarMensajeCorreo($nombre, $codigo, $doc, $semestre)
{
    $mensaje = '<p>Buenos días dr(a): '.$nombre.', les saluda cordialmente la Unidad de Tecnologías Informáticas y Comunicaciones / Sistemas de la EPG:</p>';
    $mensaje .= '<p>Se recomienda que descargue la lista de estudiantes por curso para llevar el control de asistencias.</p>';
    $mensaje .= '<p>Se adjunta su Credencial y Manual de Docente para el registro de notas online.</p>';
    $mensaje .= '<p>Si necesita Soporte informático o ayuda con el registro o acceso comuníquese con los siguientes números:</p>';
    $mensaje .= '<p>Anderson J. Zavaleta Simón /UTIC-EPG: 984 599 249</p>';
    $mensaje .= '<p>Ronald Córdova Paredes /SISTEMAS-EPG: 978 468 194</p>';
    $mensaje .= '<p>Documento Docente: '.$doc.'</p>';
    $mensaje .= '<p>Token Docente: '.$codigo.'</p>';
    $mensaje .= '<p>Código del semestre: '.$semestre.'</p>';
    $mensaje .= '<p><a href="http://www.epgnew.unitru.edu.pe">www.epgnew.unitru.edu.pe</a></p>';
    $mensaje .= '<p>Si en algún momento llega a recibir credenciales o datos que no son suyos, comuniquese con la unidad.</p>';
    $mensaje .= '<p>ATTE. Unidad de Tecnologías Informáticas y Comunicaciones o Sistemas de la EPG.</p>';
    return $mensaje;
}



?>