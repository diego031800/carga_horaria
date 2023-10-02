<?php
include_once '../../models/config.php';
session_start();
if (!isset($_SESSION['login'])) {
    header("Location:../../index.php");
} else {
    date_default_timezone_set('America/Lima');
?>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- ICONO DE LA PAG WEB -->
        <link rel="icon" href="../../assets/images/untr.ico">
        <!-- BOOTSTRAP -->
        <link rel="stylesheet" href="../../assets/css/bootstrap.min.css">
        <!-- <link rel="stylesheet" href="../../assets/css/bootstrap-theme.min.css"> -->
        <link rel="stylesheet" href="../../assets/css/bootstrap-datepicker3.min.css">
        <link rel="stylesheet" href="../../assets/css/bootstrapValidator.min.css">
        <!-- TEMPLATE -->
        <link rel="stylesheet" href="../../assets/css/font-awesome.min.css">
        <link rel="stylesheet" href="../../assets/css/themify-icons.css">
        <link rel="stylesheet" href="../../assets/css/metisMenu.css">
        <link rel="stylesheet" href="../../assets/css/owl.carousel.min.css">
        <link rel="stylesheet" href="../../assets/css/slicknav.min.css">
        <!-- amchart css -->
        <link rel="stylesheet" href="https://www.amcharts.com/lib/3/plugins/export/export.css" type="text/css" media="all" />
        <!-- others css -->
        <link rel="stylesheet" href="../../assets/css/typography.css">
        <link rel="stylesheet" href="../../assets/css/default-css.css">
        <link rel="stylesheet" href="../../assets/css/styles.css">
        <link rel="stylesheet" href="../../assets/css/responsive.css">
        <link rel="stylesheet" href="../../assets/css/css_toastr.min.css">
        <!-- modernizr css -->
        <script src="../../assets/js/vendor/modernizr-2.8.3.min.js"></script>
        <!-- SELECT 2 -->
        <link rel="stylesheet" href="../../assets/css/select2/select2.css">
        <!-- DATA TABLE -->
        <link rel="stylesheet" href="../../assets/css/data_table/jquery.dataTables.min.css">
        <link rel="stylesheet" href="../css/styles.css">
        <!-- ESTILOS PROPIOS -->
        <link rel="stylesheet" href="/carga_horaria/view/css/styles.css">
        <title>ENVIO CREDENCIALES</title>
    </head>

    <body>
        <div class="page-container">
            <!-- START SIDE BAR -->
            <?php require_once('../left_sidebar.php') ?>
            <!-- END SIDE BAR -->

            <!-- main content area start -->
            <div class="main-content" style="height: 100%;">
                <!-- START NAV BAR -->
                <?php require_once('../navbar.php') ?>
                <!-- END NAV BAR -->
                <div class="main-content-inner">
                    <div class="card shadow p-3 mb-5 bg-body-tertiary rounded mt-5" style="min-height: 620px;">
                        <div class="card-header bg-transparent d-flex justify-content-between align-items-center text-center">
                            &nbsp;
                            <h3 class="card-title m-3" id="lblTitulo">Envio Credenciales</h3>
                            &nbsp;
                        </div>
                        <div class="card-body">
                            <div class="card" style="color: #ffffff; background-color:rgba(135, 135, 135, 0.09); border-radius: 18px;">
                                <div class="card-body">
                                    <div class="row d-flex justify-content-center">
                                        <div class="col-lg-2 col-6">
                                            <select class="form-select" id="cboSemestre">
                                            </select>
                                            <small style="color: #666666;"><b>Filtar</b> por semestre</small>
                                        </div>
                                        <div class="col-lg-3 col-6">
                                            <select class="form-select" id="cboUnidad">
                                            </select>
                                            <small style="color: #666666;"><b>Filtar</b> por Unidad</small>
                                        </div>
                                        <div class="col-lg-3 col-6">
                                            <select class="form-select" id="cboPrograma">
                                            </select>
                                            <small style="color: #666666;"><b>Filtar</b> por Programa</small>
                                        </div>
                                        <div class="col-lg-2 col-md-4 col-6 align-items-center">
                                            <button class="btn btn-primary" type="button" id="btnBuscar">
                                                <i class="fa fa-search"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card mt-4" style="color: #ffffff; background-color:rgba(135, 135, 135, 0.09); border-radius: 18px;">
                                <div class="card-body">
                                    <table id="table_ch" class="table table-bordered dt-responsive table-hover">
                                        <thead>
                                            <tr class="table-info">
                                                <th class="text-center">N°</th>
                                                <th class="text-center">ACCIONES</th>
                                                <th class="text-center">CICLO</th>
                                                <th class="text-center">CURSO</th>
                                                <th class="text-center">GRUPO</th>
                                                <th class="text-center">DOCENTE</th>
                                                <th class="text-center">CORREO</th>
                                                <th class="text-center">INICIO</th>
                                                <th class="text-center">FIN</th>
                                            </tr>
                                        </thead>
                                        <tbody id="cuerpo_asignacion"></tbody>
                                    </table>
                                    <div id="tbl_spinner"></div>
                                </div>
                            </div>
                            <div>
                                <button class="btn btn-info" id="enviarDatos"><i class="fa fa-send-o text-info"></i> Enviar Correos</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- main content area end -->

            <!-- START FOOTER -->
            <?php require_once('../footer.php') ?>
            <!-- END FOOTER -->
 
        </div>

        <!-- SCRIPTS -->

        <!-- JQUERY -->
        <script src="../../assets/js/jquery-3.7.0.min.js"></script>
        <!-- BOOTSTRAP -->
        <script src="../../assets/js/popper.min.js"></script>
        <script src="../../assets/js/bootstrap.min.js"></script>
        <script src="../../assets/js/datepicker/bootstrap-datepicker.min.js"></script>
        <script src="../../assets/js/datepicker/bootstrap-datepicker.es.min.js"></script>
        <script src="../../assets/js/datepicker/bootstrapValidator.min.js"></script>
        <script src="../../assets/js/owl.carousel.min.js"></script>
        <script src="../../assets/js/metisMenu.min.js"></script>
        <script src="../../assets/js/jquery.slimscroll.min.js"></script>
        <script src="../../assets/js/jquery.slicknav.min.js"></script>
        <!-- DATE PICKER -->
        <script src="../../assets/js/datepicker/es_ES.min.js"></script>
        <!-- SELECT 2 -->
        <script src="../../assets/js/select2/select2.js"></script>
        <!-- others plugins -->
        <script src="../../assets/js/plugins.js"></script>
        <script src="../../assets/js/scripts.js"></script>
        <!-- DATA TABLE -->
        <script src="../../assets/js/data_table/jquery.dataTables.min.js"></script>
        <!-- SCRIPT DESPACHO -->
        <script src="../../view/js/process/envioCredenciales.js"></script>
        <!-- SCRIPT TOASTR -->
        <script src="../../assets/js/js_toastr.min.js"></script>
        <!-- SCRIPT PROPIO INICIO -->
        <script>
            $(document).ready(function() {
                toastr.options = {
                    "closeButton": false,
                    "debug": false,
                    "newestOnTop": true,
                    "progressBar": true,
                    "positionClass": "toast-top-right",
                    "preventDuplicates": false,
                    "onclick": null,
                    "showDuration": "300",
                    "hideDuration": "1000",
                    "timeOut": "5000",
                    "extendedTimeOut": "1000",
                    "showEasing": "swing",
                    "hideEasing": "linear",
                    "showMethod": "fadeIn",
                    "hideMethod": "fadeOut"
                }
            });
        </script>
    </body>

    </html>


<?php 
} 
?>
