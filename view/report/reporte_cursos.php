<?php
include_once '../../models/config.php';
include_once '../../models/main/Menu.php';
session_start();
if (!isset($_SESSION['login'])) {
    header("Location:../../index.php");
} else {
    $borrar = '/carga_horaria';
    $currentUrl = $_SERVER['REQUEST_URI'];
    foreach ($_SESSION['paginas'] as $item) {
        $url = $item['url'];
        if ($currentUrl === $url) {
            $_SESSION['id_pag_activa'] = $item['id'];
        }
    }
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
    <link rel="stylesheet" href="https://www.amcharts.com/lib/3/plugins/export/export.css" type="text/css"
        media="all" />
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
    <title>Reporte de cursos</title>
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
                    <div
                        class="card-header bg-transparent d-flex justify-content-between align-items-center text-center">
                        &nbsp;
                        <h3 class="card-title m-3" id="lblTitulo">REPORTE DE CURSOS</h3>
                        &nbsp;
                    </div>
                    <div class="card mt-4"
                        style="color: #ffffff; background-color:rgba(135, 135, 135, 0.09); border-radius: 18px;">
                        <div class="card-body">
                            <h5 style="color: #666666;">Filtros academicos</h5>
                            <div class="row d-flex justify-content-center align-items-center">
                                <div class="col-lg-2 col-6">
                                    <select class="form-select" id="cboSemestre">
                                    </select>
                                    <small style="color: #666666;"><b>Filtar</b> por semestre</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card mt-4"
                        style="color: #ffffff; background-color:rgba(135, 135, 135, 0.09); border-radius: 18px;">
                        <div class="card-body">
                            <h5 style="color: #666666;">Acciones</h5>
                            <div class="row d-flex justify-content-center align-items-center">
                                <div class="col-lg-2 col-6">
                                    <button class="btn btn-info text-light m-4" id="btnBuscar">
                                        <i class="fa fa-search"></i>&nbsp;&nbsp; Buscar</button>
                                </div>
                                <div class="col-lg-2 col-6">
                                    <a class="btn btn-info text-light m-4" id="btnDetalles"
                                        href="/view/report/detalle_reporte_cursos.php">
                                        <i class="fa fa-search"></i>&nbsp;&nbsp; Detalles</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card mt-4"
                        style="color: #ffffff; background-color:rgba(135, 135, 135, 0.09); border-radius: 18px;">
                        <div class="card-body">
                            <h5 style="color: #666666;">Gráficos</h5>
                            <div class="row">
                                <div class="col-12">
                                    <canvas id="cursosXunidad" width="400" height="100"></canvas>
                                </div>
                                <div class="col-12">
                                    <hr style="height: 2px; background-color: black; margin-left: 35%; width: 25%;"
                                        id="separador_1">
                                </div>
                                <div class="col-6">
                                    <canvas id="cursosXgrupo" width="400" height="100"></canvas>
                                </div>
                                <div class="col-6" style="margin-top: 50px;">
                                    <table id="tbl_cursos_grupos_leyenda"
                                        class="table table-striped table-hover table-sm">
                                        <thead>
                                            <tr>
                                                <th class="text-center">Cantidad de grupos</th>
                                                <th class="text-center">Cantidad de cursos</th>
                                                <th class="text-center">Porcentaje</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                                <div class="col-12">
                                    <hr style="height: 2px; background-color: black; margin-left: 35%; width: 25%;"
                                        id="separador_2">
                                </div>
                                <div class="col-6">
                                    <canvas id="cursosXhoras" width="300" height="200"></canvas>
                                </div>
                                <div class="col-6">
                                    <table id="tbl_cursos_horas_leyenda" class="table table-bordered">
                                        <thead>
                                            <tr class="table-info">
                                                <th class="text-center">HORAS</th>
                                                <th class="text-center">CANTIDAD</th>
                                                <th class="text-center">PORCENTAJE</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tbl_cuerpo_2"></tbody>
                                    </table>
                                </div>
                                <div class="col-12">
                                    <hr style="height: 2px; background-color: black; margin-left: 35%; width: 25%;"
                                        id="separador_3">
                                </div>
                                <div class="col-12">
                                    <label style="color: #666666;" id="title_tbl_cursos_t_nt_unidad"><b>Cantidad de
                                            cursos terminados y no terminados por cada unidad</b></label><br>
                                    <table id="tbl_cursos_t_nt_unidad"
                                        class="table table-bordered dt-responsive table-hover">
                                        <thead>
                                            <tr class="table-info">
                                                <th class="text-center">N°</th>
                                                <th class="text-center">UNIDAD</th>
                                                <th class="text-center">CURSOS SIN TERMINAR</th>
                                                <th class="text-center">CURSOS TERMINADOS</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tbl_cuerpo_3"></tbody>
                                    </table>
                                    <span style="color: #666666;" id="nota_tbl_cursos_t_nt_unidad">No se tomaron en
                                        cuenta los cursos sin fechas</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
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
    <script src="../../assets/js/data_table/dataTables.responsive.min.js"></script>
    <!-- SCRIPT TOASTR -->
    <script src="../../assets/js/js_toastr.min.js"></script>
    <!-- CHART JS -->
    <script src="../../assets/js/chartjs/chart.min.js"></script>
    <script src="../../assets/js/chartjs/chart.umd.js"></script>
    <script src="../../assets/js/chartjs/helpers.min.js"></script>
    <!-- SCRIPT DESPACHO -->
    <script src="../../view/js/report/reporte_cursos.js"></script>
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