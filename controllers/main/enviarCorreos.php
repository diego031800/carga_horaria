<?php
date_default_timezone_set('America/Lima');
require '../../vendor/phpmailer/phpmailer/src/Exception.php';
require '../../vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../../vendor/phpmailer/phpmailer/src/SMTP.php';
include_once '../../models/main/datosEnvio.php';
include_once '../../controllers/main/pdfCredencial.php';

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
        $this->mail->Username = 'abyzuss5@gmail.com';
        $this->mail->Password = 'pdto zrga nvfk djtg';
        $this->mail->setFrom('abyzuss5@gmail.com', 'UTIC POSGRADO');
        $this->mail->CharSet = 'UTF-8'; 
    }

    public function enviarCorreoCierre($datos)
    {
        $this->mail->addAddress($datos['correo'],$datos['nombre']);
        $this->mail->Subject = 'Cierre de carga horaria del SEMESTRE 2023 DE LA UNIDAD DE CIENCIAS DE LA COMUNICACIÓN';
        

        $rutaImagenAdjunta = 'assets/images/documentos/img_upg.png';
        $this->mail->addEmbeddedImage($rutaImagenAdjunta, 'NOMBRE');

        if ($this->mail->send()) {
            echo 'Correo enviado con éxito';
        } else {
            echo 'Error al enviar el correo: ' . $this->mail->ErrorInfo;
        }
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
                'sec_id' => '',
                'prg_id' => ''
            );
            $this->mail->Subject = 'ENTREGA DE CREEDENCIALES DEL SIGAP - DOCENTE';
            $rutaManual = '../../assets/docs/ManualSigap.pdf';
            $this->mail->addAddress("geraldayala87@gmail.com",$item->nombre);
            $this->mail->isHTML(true);
            $this->mail->Body = $this->generarMensajeCorreo($item->nombre,$item->codigo,$item->documento,$item->sem);
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
            $itemEnviado['prg_id'] = intval($item->prg_id);
            //unlink($rutaPdf);
            $itemEnviado['fechahora'] = date('Y-m-d H:i:s');
        } catch (Exception $ex) {
            die("Error: " . $ex);
        }
        return $itemEnviado;
    }
    
    private function generarMensajeCorreo($nombre, $codigo, $doc, $semestre)
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

    public function cerrarConexion(){
        $this->mail->smtpClose();
    }
}

?>