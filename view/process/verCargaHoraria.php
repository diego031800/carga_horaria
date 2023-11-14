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
        <!-- SELECT 2 -->
        <link rel="stylesheet" href="../../assets/css/css_toastr.min.css">
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
        <!-- modernizr css -->
        <script src="../../assets/js/vendor/modernizr-2.8.3.min.js"></script>
        <!-- SELECT 2 -->
        <link rel="stylesheet" href="../../assets/css/select2/select2.css">
        <!-- ESTILOS PROPIOS -->
        <link rel="stylesheet" href="../css/styles.css">
        <title>CARGA HORARIA</title>
    </head>

    <body>
        <input type="hidden" id="txtSemestre" value="<?php echo empty($_GET['sem_id']) ? '' : $_GET['sem_id'] ?>">
        <input type="hidden" id="txtUnidad" value="<?php echo empty($_GET['sec_id']) ? '' : $_GET['sec_id'] ?>">
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
                        <div class="card-header bg-transparent d-flex justify-content-between align-items-center">
                            <button class="btn btn-primary" type="button" id="btnAtras">
                                <i class="fa fa-arrow-left"></i>
                            </button>
                            <h3 class="card-title m-3">Carga horaria</h3>
                            <div style="color: white;">&nbsp;</div>
                        </div>
                        <div class="card-body">
                            <div class="row mb-2 d-flex justify-content-center">
                                <div class="col-lg-2 col-6 mb-3">
                                    <label for="" class="form-label">Semestre</label>
                                    <select class="form-select" id="cboSemestre">
                                    </select>
                                </div>
                                <div class="col-lg-3 col-6 mb-3">
                                    <label for="cboUnidad" class="form-label">Unidad</label>
                                    <select class="form-select" id="cboUnidad">
                                    </select>
                                </div>
                                <div class="col-lg-1 col-6 mb-3">
                                    <label class="form-label"></label><br>
                                    <button class="btn btn-primary" type="button" id="btnBuscar" disabled>
                                        <i class="fa fa-search"></i>
                                        &nbsp; Buscar
                                    </button>
                                </div>
                            </div>
                            <div class="row mt-3 mb-3 d-flex justify-content-center">
                                <div class="col-3">
                                    <div class="d-grid">
                                        <button class="btn btn-danger" id="btnDescargarPdf" type="button" disabled>
                                            <i class="fa fa-file-pdf-o"></i>
                                            &nbsp; Descargar PDF
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-12" id="tabla_carga_horaria">

                                </div>
                            </div>
                        </div>
                        <!-- <div class="card-footer bg-transparent">
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end m-3">
                                <button class="btn btn-danger" type="button" id="btnCancelar">
                                    <i class="fa fa-close"></i>
                                    &nbsp; Cancelar
                                </button>
                            </div>
                        </div> -->
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
        <!-- SCRIPT TOASTR -->
        <script src="../../assets/js/js_toastr.min.js"></script>
        <!-- SCRIPT DESPACHO -->
        <script src="../../view/js/process/verCargaHoraria.js"></script>
        <!-- SCRIPT PROPIO INICIO -->
        <script>
            $(document).ready(function() {
                $('#cboPrograma').select2({
                    dropdownCssClass: "limitar-opciones",
                    placeholder: 'Selecciona un programa ...'
                });

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


<?php } ?>