<?php
date_default_timezone_set('America/Lima');
require '../../vendor/phpmailer/phpmailer/src/Exception.php';
require '../../vendor/phpmailer/phpmailer/src/PHPMailer.php';
require '../../vendor/phpmailer/phpmailer/src/SMTP.php';
include_once '../../models/report/enviocredencialesReport.php';
require_once '../config_correos.php';
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
        $this->mail->Host = host_email;
        $this->mail->Port = 465;
        $this->mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $this->mail->SMTPAuth = true;
        $this->mail->Username = username_email;
        $this->mail->Password = password_email;
        $this->mail->setFrom(username_email, name_from);
        $this->mail->CharSet = chart_set; 
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
                'doc_id' => 0
            );
            $this->mail->Subject = 'ENTREGA DE CREEDENCIALES DEL SIGAP - DOCENTE';
            $rutaFlayer = '../../assets/docs/Infografia_enlace.pdf';
            $rutaComunicado = '../../assets/docs/Comunicado_docente.pdf';
            $this->mail->addAddress($item->correo,$item->nombre);
            $this->mail->isHTML(true);
            $this->mail->Body = $this->generarMensajeCorreo();
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
            $itemEnviado['doc_id'] = intval($item->doc_id);
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
        $mensaje = '<h1>¡Bienvenido al semestre 2024-I!</h1>';
        $mensaje .= ' <p>Buenos días estimado Docente de la ESCUELA DE POSGRADO, se le hace el envío de sus credenciales para ingresar al sistema SIGAP correspondiente al semestre
        2024-I; en el cual podrán descargar la lista de estudiantes matriculados en el curso que esté dictando, en la infografía podrá ver de manera gráfica los pasos a seguir.</p>';
        $mensaje .= '<p>En el menú de la izquierda, verá una opción que dice “Aula virtual” (como se muestra en el comunicado) en la cual podrá ir al aula virtual, las formas de 
        acceder se explican detalladamente en el comunicado.</p>';
        $mensaje .= '<p>Para soporte o ayuda comuníquese con el siguiente número:</p>';
        $mensaje .= '<ul><li>Anderson J. Zavaleta Simón / UTIC-EPG: 984 599 249</li>';
        $mensaje .= '<li>O puedes unirte al Grupo de Docentes de la EPG; Unete aquí:  : <a href="https://chat.whatsapp.com/EqKTfbg0XG1H1aWjpNLwsC ">Grupo de WhatsApp</a></li></ul>';
        $mensaje .= '<p><a href="http://www.epgnew.unitru.edu.pe">www.epgnew.unitru.edu.pe</a></p>';
        $mensaje .= '<p>Video tutorial para el proceso de registro de notas online: <a href="https://drive.google.com/file/d/18llmBIV26TAclC73gD849o7NXGlSsIot/view?usp=drive_link">Enlace al video</a></p>';
        $mensaje .= '<p>Estimado Docente de la Escuela de Posgrado ingrese en el siguiente enlace para descargar el Manual del Docente para el uso del sistema de la EPG/UNT: <a href="https://drive.google.com/file/d/1xY3-vfL527XFuIZloVGVMFn8rYBwLFIP/view?usp=sharing">Manual SIGAP</a></p>';
        $mensaje .= '<p>Nota: Sigap es únicamente para la gestión académica, en la cual podrá registrar las asistencias y notas online, así como la validación de actas de los cursos.</p>';
        $mensaje .= '<p>ATTE. Unidad de Tecnologías Informáticas y Comunicaciones de la EPG.</p>';
        return $mensaje;
    }

    private function generarMensajeCorreo_Asesores()
    {
        $mensaje = '<h1>¡Bienvenido al semestre 2024-I!</h1>';
        $mensaje .= '<p>Buenos días estimado Docente de la ESCUELA DE POSGRADO, se le hace el envío de sus credenciales para ingresar al sistema SIGAP correspondiente al semestre
        2024-I; en el cual podrán descargar la lista de estudiantes a los que esté asesorando, en la infografía podrá ver de manera gráfica los pasos a seguir.</p>';
        $mensaje .= '<p>Recordar, si ya ha dictado un curso este semestre, las credenciales presentes en este correo, son las mismas que las que se envió al inicio del semestre.</p>';
        $mensaje .= '<p>Para soporte o ayuda comuníquese con el siguiente número:</p>';
        $mensaje .= '<ul><li>Anderson J. Zavaleta Simón / UTIC-EPG: 984 599 249</li>';
        $mensaje .= '<li>O puedes unirte al Grupo de Docentes de la EPG; Unete aquí:  : <a href="https://chat.whatsapp.com/EqKTfbg0XG1H1aWjpNLwsC ">Grupo de WhatsApp</a></li></ul>';
        $mensaje .= '<p><a href="http://www.epgnew.unitru.edu.pe">www.epgnew.unitru.edu.pe</a></p>';
        $mensaje .= '<p>Video tutorial para el proceso de registro de notas online: <a href="https://drive.google.com/file/d/1tWDH4GhpmtW3mulvoW3Cib2J0EqZtzjx/view?usp=drive_link">Enlace al video</a></p>';
        $mensaje .= '<p>Estimado Docente de la Escuela de Posgrado ingrese en el siguiente enlace para descargar el Manual del Docente para el uso del sistema de la EPG/UNT: <a href="https://drive.google.com/file/d/1xY3-vfL527XFuIZloVGVMFn8rYBwLFIP/view?usp=sharing">Manual SIGAP</a></p>';
        $mensaje .= '<p>Nota: Sigap es únicamente para la gestión académica, en la cual podrá registrar notas online, así como la validación de actas de los cursos.</p>';
        $mensaje .= '<p>ATTE. Unidad de Tecnologías Informáticas y Comunicaciones de la EPG.</p>';
        return $mensaje;
    }

    public function cerrarConexion(){
        $this->mail->smtpClose();
    }
}

?>