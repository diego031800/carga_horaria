<?php 
require_once '../../vendor/autoload.php';

date_default_timezone_set('America/Lima');

$html = "<header>
        </header>
        <body>
        <div style='text-align: center;'>
            <p style='color: #1F497D; font-size: 30px; font-family: 'Gill Sans MT''><strong>Sistema Integrado de Gestión Académica de Posgrado</strong></p>
        </div>
        <div style='text-align: center; margin-bottom: 10px;'>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Nombre del docente:</span>PEDRO EVER DE LA CRUZ RODRIGUEZ</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Documento:</span> DERO9538</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Token:</span> DERO9538</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>Contraseña / código del semestre:</span> SMTR58592023</p>
        <p style='font-size: 18px; font-family:Calibri;'><span style='color: #FF0000;'>
        LINK DE ACCESO:</span> <a href='http://www.epgnew.unitru.edu.pe'>www.epgnew.unitru.edu.pe</a></p>
        </div>
              
        ";

    $mpdf = new \Mpdf\Mpdf();
    
    $mpdf->defaultfooterline = 0;

    //$mpdf->SetWatermarkImage('../../assets/images/credencial/fondo.jpg',0.5);
    //$mpdf->showWatermarkImage = true;
    // Definir contenido para el pie de página
    $footerContent = '<footer style="border-top: solid black 1px; text-align: left; font-size: 10px; position: fixed; bottom: 0; font-weight: bold;">
                           
                        </footer>
                        <div style="text-align: right; margin-top: 20px;">
                        <p style="font-size: 20px;color: #00517E;"><strong>AJZS - UTIC</strong></p>
                        </div>
                        <div style="text-align: center">
                        <p style="font-size: 19px;color: #00517E;"><b>Perú - Trujillo</b></p>
                        <p style="font-size: 19px;color: #00517E;"><strong>2023</strong><p>
                        </div>
                      </body>';
    
    // Configurar el pie de página
    $mpdf->SetFooter($footerContent);
    
    $mpdf->SetDefaultBodyCSS('background', "url('../../assets/images/credencial/fondo.jpg')");
    $mpdf->SetDefaultBodyCSS('background-image-resize', 6);

    $mpdf->SetAutoPageBreak('auto', 1); // Puedes ajustar el margen inferior según tus necesidades
    $mpdf->AddPage('L'); 

    //$mpdf->image_dpi = 96; // Puedes ajustar la resolución de las imágenes según tus necesidades
    $mpdf->useSubstitutions = false; // Desactivar las sustituciones de fuentes, que pueden aumentar el tamaño del archivo
    $mpdf->defaultfooterfontsize = 8; 

    // Write some HTML code:
    $mpdf->WriteHTML($html, \Mpdf\HTMLParserMode::HTML_BODY);
    
    // Nombre del archivo PDF
    $nombreArchivo = 'Credencial.pdf';
    
    // Output a PDF file directly to the browser with a specific filename
    $mpdf->Output($nombreArchivo, \Mpdf\Output\Destination::INLINE);    
?>