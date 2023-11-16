<?php
date_default_timezone_set('America/Lima');
require '../../vendor/phpmailer/phpmailer/src/Exception.php';
require '../../vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../../vendor/phpmailer/phpmailer/src/SMTP.php';
include_once '../../models/main/datosEnvio.php';
//include_once '../../controllers/main/pdfCredencial.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;


class CorreoCargaHoraria
{
    private $mail;
    //private $pdf;

     public function __construct()
    {
        $this->mail = new PHPMailer;
        $this->configurarSMTP();
    }

    private function configurarSMTP()
    {
        $this->mail->isSMTP();
        $this->mail->Host = 'smtp.gmail.com';
        $this->mail->Port = 465;
        $this->mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $this->mail->SMTPAuth = true;
        $this->mail->Username = 'upg_utic@unitru.edu.pe';
        $this->mail->Password = 'ojvg gftu qpbd urtr';
        $this->mail->setFrom('upg_utic@unitru.edu.pe', 'UTIC POSGRADO');
        $this->mail->CharSet = 'UTF-8'; 
    }

    public function enviarCorreoCierre($datos, $rutapdf, $nombreUnidad)
    {
        $respuesta= '';
        try {
            $this->mail->addAddress($datos['correo'],$datos['nombre']);
            $this->mail->Subject = 'Cierre de carga horaria del SEMESTRE 2023 DE LA UNIDAD DE: '.$nombreUnidad;
            $this->mail->Body = $this->generarMensajeCorreoCierre($nombreUnidad);
            $this->mail->addAttachment($rutapdf, $nombreUnidad);
            if ($this->mail->send()) {
                $respuesta= 'Correo enviado con éxito';
            } else {
                $respuesta= 'Error al enviar el correo: ' . $this->mail->ErrorInfo;
            }
        } catch (Exception $ex) {
            die("Error: " . $ex);
        }
        return $respuesta; 
    }

    public function enviarCredencial($item,$rutaPdf)
    {
        try {
            $itemEnviado = array(
                'nombre' => $item->nombre,
                'correo' => $item->correo,
                'envio' => 0,
                'fechahora' => '',
                'error' => '',
                'sem_id' => '',
                'sec_id' => ''
            );
            $this->mail->Subject = 'ENTREGA DE CREEDENCIALES DEL SIGAP - DOCENTE';
            $rutaManual = '../../assets/docs/ManualSigap.pdf';
            $this->mail->addAddress("geraldayala87@gmail.com",$item->nombre);
            $this->mail->isHTML(true);
            $this->mail->Body = $this->generarMensajeCorreo();
            $this->mail->addAttachment($rutaManual,'Manual de docente para SIGAP');
            $this->mail->addAttachment($rutaPdf, $item->nombre);
            if ($this->mail->send()) {
                $itemEnviado['envio'] = 1;
                //$itemEnviado['fechahora'] = date('Y-m-d H:i:s');
            } else {
                $itemEnviado['envio'] = 0;
                $error = $this->mail->ErrorInfo;
                $itemEnviado['error'] = $error;
            }
            $itemEnviado['sem_id'] = intval($item->sem_id);
            $itemEnviado['sec_id'] = intval($item->sec_id);
            //unlink($rutaPdf);
            $itemEnviado['fechahora'] = date('Y-m-d H:i:s');
        } catch (Exception $ex) {
            die("Error: " . $ex);
        }
        return $itemEnviado;
    }
    
    private function generarMensajeCorreo()
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

    private function generarMensajeCorreoCierre($unidad)
    {
        $mensaje = '';
        return $mensaje;
    }

    public function cerrarConexion(){
        $this->mail->smtpClose();
    }
}

?>