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
            $rutaFlayer = '../../assets/docs/Infografia_enlace.pdf';
            $rutaComunicado = '../../assets/docs/Comunicado_docente.pdf';
            $this->mail->addAddress($item->correo,$item->nombre);
            $this->mail->isHTML(true);
            $this->mail->Body = $this->generarMensajeCorreo();
            $this->mail->addAttachment($rutaManual,'Manual de docente para SIGAP');
            $this->mail->addAttachment($rutaFlayer,'Infografia de enlaces');
            $this->mail->addAttachment($rutaComunicado,'Comunicado docentes');
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