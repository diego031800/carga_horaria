<?php 
require_once '../../../vendor/autoload.php';

date_default_timezone_set('America/Lima');

class CredencialDocente{

    private $html;
    private $footer;
    private $mpdf;
    private $rutaGuardado;

    public function __construct()
    {
        $this->mpdf = new \Mpdf\Mpdf();
        $this->mpdf->defaultfooterline = 0;
        $this->rutaGuardado = '../../credenciales_temp/';
    }

    private function generarBodyCredencial($nombre,$doc,$token,$sem){
        $this->html = "<header>
        </header>
        <body>
        <div style='text-align: center;'>
            <p style='color: #1F497D; font-size: 30px; font-family: 'Gill Sans MT''><strong>Sistema Integrado de Gestión Académica de Posgrado</strong></p>
        </div>
        <div style='text-align: center; margin-bottom: 10px;'>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Nombre del docente: </span>".$nombre."</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Documento Docente: </span>".$doc."</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Token Docente: </span>".$token."</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Código del semestre: </span>".$sem."</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>
        LINK DE ACCESO:</span> <a href='http://www.epgnew.unitru.edu.pe'>www.epgnew.unitru.edu.pe</a></p>
        </div>";
    }

    private function generarFooter($sem){
        $year = substr($sem, -4);
        $this->footer = '<footer style="border-top: solid black 1px; text-align: left; font-size: 10px; position: fixed; bottom: 0; font-weight: bold;">  
                        </footer>
                        <div style="text-align: right; margin-top: 20px;">
                        <p style="font-size: 20px;color: #00517E;"><strong>AJZS - UTIC</strong></p>
                        </div>
                        <div style="text-align: center">
                        <p style="font-size: 19px;color: #00517E;"><b>Perú - Trujillo</b></p>
                        <p style="font-size: 19px;color: #00517E;"><strong>'.$year.'</strong><p>
                        </div>
                      </body>';
    }

    public function generarCredencial($nombre,$doc,$token,$sem){
        $nombreArchivo='';
        $this->html ='';
        $this->footer='';
        $this->generarBodyCredencial($nombre,$doc,$token,$sem);
        $this->generarFooter($sem);
        // Configurar el pie de página
        $this->mpdf->SetFooter($this->footer);
        //Imagen de fondo
        $this->mpdf->SetDefaultBodyCSS('background', "url('../../../assets/images/credencial/fondo.jpg')");
        $this->mpdf->SetDefaultBodyCSS('background-image-resize', 6);
        //Cambiando el tamaño y la orientación de la página
        $this->mpdf->SetAutoPageBreak('auto', 1); // Puedes ajustar el margen inferior según tus necesidades
        $this->mpdf->AddPage('L'); 
        $this->mpdf->useSubstitutions = false; // Desactivar las sustituciones de fuentes, que pueden aumentar el tamaño del archivo
        $this->mpdf->defaultfooterfontsize = 8; 
        // Write some HTML code:
        $this->mpdf->WriteHTML($this->html, \Mpdf\HTMLParserMode::HTML_BODY);
        
        // Nombre del archivo PDF
        $nombreArchivo = $nombre.'.pdf';
        $ruta= $this->rutaGuardado.$nombreArchivo;
        $this->mpdf->Output($ruta, \Mpdf\Output\Destination::FILE);
        return $ruta;
    }

}      
?>