<?php
require '../../vendor/phpmailer/phpmailer/src/Exception.php';
require '../../vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../../vendor/phpmailer/phpmailer/src/SMTP.php';
include_once '../../models/main/datosEnvio.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class CorreoCargaHoraria
{
    private $mail;

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
        $this->mail->Password = 'ufly sryj hxeg skxp';
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

    public function enviarCredenciales($datos)
    {
        $datosEnvio = new datosEnvio();
        $itemsEnviados = array();
        try {
            $total = count($datos);
        $this->mail->Subject = 'Envío de credenciales';
        $rutaImagenAdjunta = 'assets/images/documentos/img_upg.png';
        $this->mail->addEmbeddedImage($rutaImagenAdjunta, 'NOMBRE');
        $enviosCorrectos = 0;
        foreach ($datos as $item) {
            $this->mail->isHTML(true);
            $this->mail->Body = $this->generarMensajeCorreo($item['nombre']);
            $this->mail->addAddress($item['correo'],$item['nombre']);
            $itemEnviado = array(
                'nombre' => $item['nombre'],
                'correo' => $item['correo'],
                'envio' => 0,
                'fechahora' => '',
                'error' => ''
            );
            if ($this->mail->send()) {
                $enviosCorrectos +=1;
                $itemEnviado['envio'] = 1;
            } else {
                $itemEnviado['envio'] = 0;
                $error = $this->mail->ErrorInfo;
                $itemEnviado['error'] = $error;
            }
            $itemEnviado['fechahora'] = date('Y-m-d H:i:s');
            $itemsEnviados[] = $itemEnviado;
            $this->mail->clearAllRecipients(); 
        }
        } catch (Exception $ex) {
            die("Error: " . $ex);
        }
        $datosEnvio->save_reporte($itemsEnviados);
        return $itemsEnviados;
    }

    private function generarMensajeCorreo($nombre)
    {
        $mensaje = '<p>Buenos días '.$nombre.', les saluda cordialmente la Unidad de Tecnologías Informáticas y Comunicaciones / Sistemas de la EPG para comunicarles lo siguiente:</p>';
        $mensaje .= '<p>Según la Propuesta de Evaluación y Seguimiento al Desempeño Docente de la Escuela de Posgrado de la Universidad Nacional de Trujillo, se les hace llegar
         a ustedes la encuesta de Desempeño Docente de forma sistemática al término de cada curso del Semestre Académico 2023-I.</p>';
        return $mensaje;
    }
}
?>