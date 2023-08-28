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
        <!-- modernizr css -->
        <script src="../../assets/js/vendor/modernizr-2.8.3.min.js"></script>
        <!-- SELECT 2 -->
        <link rel="stylesheet" href="../../assets/css/select2/select2.css">
        <!-- ESTILOS PROPIOS -->
        <link rel="stylesheet" href="/carga_horaria/view/css/styles.css">
        <title>CARGA HORARIA</title>
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
                    <div class="card mt-5" style="min-height: 620px;">
                        <div class="card-header bg-transparent">
                            <h3 class="card-title m-3">Carga horaria</h3>
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
                                <!-- <div class="col-lg-5 col-6 mb-3">
                                    <label class="form-label" for="cboPrograma">Programa</label><br>
                                    <select class="form-select" id="cboPrograma" disabled>
                                        <option value="SD">Antes selecciona una unidad ...</option>
                                    </select>
                                </div>
                                <div class="col-lg-1 col-6 mb-3">
                                    <label class="form-label" for="cboCiclo">Ciclo</label>
                                    <select name="ciclo" class="form-select" id="cboCiclo">
                                    </select>
                                </div> -->
                                <div class="col-lg-1 col-6 mb-3">
                                    <label class="form-label"></label><br>
                                    <button class="btn btn-info" type="button" id="btnBuscar" disabled>
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
                                <div class="col-3" style="display: none;">
                                    <div class="d-grid">
                                        <button class="btn btn-success" id="btnDescargarExc" type="button" disabled>
                                            <i class="fa fa-file-excel-o"></i>
                                            &nbsp; Descargar Excel
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="row mt-3">
                                <div class="col-12" id="tabla_carga_horaria">

                                </div>
                            </div>
                        </div>
                        <div class="card-footer bg-transparent">
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end m-3">
                                <button class="btn btn-danger" type="button" id="btnCancelar">
                                    <i class="fa fa-close"></i>
                                    &nbsp; Cancelar
                                </button>
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
        <!-- SCRIPT DESPACHO -->
        <script src="../../view/js/process/verCargaHoraria.js"></script>
        <!-- SCRIPT PROPIO INICIO -->
        <script>
            $(document).ready(function() {
                $('#cboPrograma').select2({
                    dropdownCssClass: "limitar-opciones",
                    placeholder: 'Selecciona un programa ...'
                });
            });
        </script>
    </body>

    </html>


<?php } ?>