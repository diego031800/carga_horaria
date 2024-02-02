<?php
include_once '../../models/config.php';
include_once '../../models/main/Menu.php';
session_start();
if (!isset($_SESSION['login'])) {
    header("Location:../../index.php");
} else {
    $menu = new Menu();
    $GLOBALS['paginas'] = $menu->get_paginas($_SESSION['usu_id']);
    $GLOBALS['parents'] = $menu->get_parents($_SESSION['usu_id']);
    $GLOBALS['menu'] = $menu->get_menu($_SESSION['usu_id']);
    $borrar = '/carga_horaria';
    $currentUrl = $_SERVER['REQUEST_URI'];
    /*
    foreach ($GLOBALS['paginas'] as $item) {
        $url = $borrar.$item['url'];
        error_log($url);
        if ($currentUrl == $url) {
            $_SESSION['id_pag_activa'] = $item['id'];
            error_log("======================");
            error_log($_SESSION['id_pag_activa']);
            error_log($item['id']);
        }
    }*/
    $_SESSION['id_pag_activa'] = 10;
    if (!in_array($_SESSION['id_pag_activa'], $_SESSION['permisos'])) {
        header("Location:../mensajes/SinPermiso.php");
    }
    date_default_timezone_set('America/Lima');
?>
    <!DOCTYPE html>
    <html lang="es">

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
        <link rel="stylesheet" href="../../assets/css/data_table/responsive.dataTables.min.css">
        <!-- ESTILOS PROPIOS -->
        <link rel="stylesheet" href="../css/styles.css">
        <title>CARGA HORARIA</title>
    </head>

    <body>
        <input type="hidden" id="sem_id" value="<?php echo $_GET['sem_id'] ?>">
        <input type="hidden" id="sec_id" value="<?php echo $_GET['sec_id'] ?>">
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
                            <button class="btn btn-primary" type="button" id="btnAtras">
                                <i class="fa fa-arrow-left"></i>
                            </button>
                            <h3 class="card-title m-3" id="lblTitulo">Cargas Horarias</h3>
                            <div>
                                <button class="btn btn-danger" type="button" id="btnVerPdf">
                                    <i class="fa fa-file-pdf-o"></i> &nbsp;&nbsp; Ver PDF
                                </button>
                                <button class="btn btn-primary" type="button" id="btnNuevaCarga">
                                    <i class="fa fa-plus-square"></i> &nbsp;&nbsp; Carga Horaria
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="card" style="color: #ffffff; background-color:rgba(135, 135, 135, 0.09); border-radius: 18px;">
                                <div class="card-body">
                                    <div class="row d-flex justify-content-center">
                                        <div class="col-lg-3 col-6">
                                            <select class="form-select" id="cboPrograma">
                                            </select>
                                            <small style="color: #666666;"><b>Filtar</b> por Programa</small>
                                        </div>
                                        <div class="col-lg-2 col-6">
                                            <select name="ciclo" class="form-select" id="cboCiclo">
                                            </select>
                                            <small style="color: #666666;"><b>Filtar</b> por Ciclo</small>
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
                                                <th class="text-center">ESTADO</th>
                                                <th class="text-center">CÓDIGO</th>
                                                <th class="text-center">SEMESTRE</th>
                                                <th class="text-center">UNIDAD</th>
                                                <th class="text-center">PROGRAMA</th>
                                                <th class="text-center">CICLO</th>
                                                <th class="text-center">CREADO</th>
                                                <th class="text-center">CREADO POR</th>
                                                <th class="text-center">EDITADO</th>
                                                <th class="text-center">EDITADO POR</th>
                                            </tr>
                                        </thead>
                                        <tbody id="cuerpo_ch"></tbody>
                                    </table>
                                    <div id="tbl_spinner"></div>
                                </div>
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

        <!-- MODALES -->
        <!-- MODAL ELIMINAR -->
        <div class="modal" tabindex="-1" id="modal_eliminar" style="display: none;">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">ELIMINAR</h5>
                    <button type="button" class="btn-close" aria-label="Close" onclick="$('#modal_eliminar').hide()"></button>
                </div>
                <div class="modal-body">
                    <p>¿Esta seguro que quiere eliminar esta carga?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="btnCerrar">Cerrar</button>
                    <button type="button" class="btn btn-danger" id="btnEliminar">Eliminar</button>
                </div>
                </div>
            </div>
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
        <script src="../../assets/js/data_table/dataTables.responsive.min.js"></script>
        <!-- SCRIPT DESPACHO -->
        <script src="../../view/js/process/detalleCargaHoraria.js"></script>
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


<?php } ?>