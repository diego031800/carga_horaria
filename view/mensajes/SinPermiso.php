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
    <link rel="stylesheet" href="../css/styles.css">
    <!-- ESTILOS PROPIOS -->
    <link rel="stylesheet" href="../css/styles.css">
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
                    <div
                        class="card-header bg-transparent d-flex justify-content-between align-items-center text-center">
                        &nbsp;
                        <h3 class="card-title m-3" id="lblTitulo">NO TIENE PERMISO PARA ENTRAR A ESTAR PÁGINA</h3>
                        &nbsp;
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
        <script src="../../assets/js/data_table/dataTables.responsive.min.js"></script>
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