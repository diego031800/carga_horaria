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
                        <h3 class="card-title m-3">Registro de la carga horaria</h3>
                    </div>
                    <div class="card-body">
                        <div class="row mb-2">
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
                            <div class="col-lg-5 col-6 mb-3">
                                <label class="form-label" for="cboPrograma">Programa</label>
                                <select class="form-select" id="cboPrograma" disabled>
                                    <option value="SD">Antes selecciona una unidad ...</option>
                                </select>
                            </div>
                            <div class="col-lg-2 col-6 mb-3">
                                <label class="form-label" for="cboCiclo">Ciclo</label>
                                <select name="ciclo" class="form-select" id="cboCiclo">
                                </select>
                            </div>
                            <div class="col-lg-2 col-6 mb-3">
                                <button class="btn btn-outline-success" id="btneditarCargaHoraria"
                                    onClick="editarCarga();" disabled>Confirmar</button>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12 col-6 mb-3">
                                <button class="btn btn-success" onClick="abrirAgregarCurso();" id="btnAgregarCurso">
                                    <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512">
                                        <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
                                        <style>
                                        svg {
                                            fill: #ffffff
                                        }
                                        </style>
                                        <path
                                            d="M256 80c0-17.7-14.3-32-32-32s-32 14.3-32 32V224H48c-17.7 0-32 14.3-32 32s14.3 32 32 32H192V432c0 17.7 14.3 32 32 32s32-14.3 32-32V288H400c17.7 0 32-14.3 32-32s-14.3-32-32-32H256V80z" />
                                    </svg>
                                    &nbsp; Agregar curso
                                </button>

                            </div>
                        </div>

                        <table class="table" id="cursosTabla" name="cursosTabla">
                            <thead>
                                <tr>
                                    <th scope="col">Acciones</th>
                                    <th scope="col">Curso</th>
                                    <th scope="col">Número de Grupos:</th>
                                    <th scope="col">Gestionar Grupos:</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="text-center" colspan="6">Sin registros.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="card-footer bg-transparent">
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end m-3">
                            <button class="btn btn-primary me-md-2" type="button" id="btnGuardar">
                                <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512">
                                    <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
                                    <style>
                                    svg {
                                        fill: #ffffff
                                    }
                                    </style>
                                    <path
                                        d="M64 32C28.7 32 0 60.7 0 96V416c0 35.3 28.7 64 64 64H384c35.3 0 64-28.7 64-64V173.3c0-17-6.7-33.3-18.7-45.3L352 50.7C340 38.7 323.7 32 306.7 32H64zm0 96c0-17.7 14.3-32 32-32H288c17.7 0 32 14.3 32 32v64c0 17.7-14.3 32-32 32H96c-17.7 0-32-14.3-32-32V128zM224 288a64 64 0 1 1 0 128 64 64 0 1 1 0-128z" />
                                </svg>
                                &nbsp; Guardar
                            </button>
                            <button class="btn btn-success" type="button" id="btnCerrar">
                                <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512">
                                    <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
                                    <style>
                                    svg {
                                        fill: #ffffff
                                    }
                                    </style>
                                    <path
                                        d="M144 144v48H304V144c0-44.2-35.8-80-80-80s-80 35.8-80 80zM80 192V144C80 64.5 144.5 0 224 0s144 64.5 144 144v48h16c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V256c0-35.3 28.7-64 64-64H80z" />
                                </svg>
                                &nbsp; Cerrar
                            </button>
                            <button class="btn btn-danger" type="button" id="btnCancelar"
                                onClick="cancelarEditarCarga();">
                                <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 384 512">
                                    <!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
                                    <style>
                                    svg {
                                        fill: #ffffff
                                    }
                                    </style>
                                    <path
                                        d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z" />
                                </svg>
                                &nbsp; Cancelar
                            </button>
                        </div>
                    </div>
                </div>
                <!-- MODALES -->
                <!-- MODAL DOCENTE -->
                <div class="modal" id="myModal">
                    <div class="modal-dialog modal-dialog-centered modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Registrar docente</h5>
                                <span class="close-btn" id="closeModal">&times;</span>
                            </div>
                            <div class="modal-body">
                                <input type="text" hidden id="id-curso-docente">
                                <div class="row">
                                    <div class="col-12 mb-12 row">
                                        <div class="col-12 mb-12">
                                            <label for="" class="form-label">Grupo:</label><br />
                                        </div>
                                        <div class="col-5 mb-12">
                                            <select class="form-select" id="cbo-grupodocente">
                                            </select>
                                        </div>
                                        <div class="col-7 mb-12" style="display: flex; justify-content: space-between;">
                                            <button class="btn btn-outline-warning" style="height: 90%;"
                                                onClick="agregarGrupo();" id="btn-addGrupo">Agregar grupo</button>
                                            <button class="btn btn-outline-danger" style="height: 90%;"
                                                onClick="eliminarGrupo();" id="btn-deleteGrupo">Eliminar grupo</button>
                                        </div>
                                    </div>
                                    <div class="col-12 mb-3 row">
                                        <div class="col-12 mb-12">
                                            <label for="" class="form-label">Nombre:</label><br />
                                        </div>
                                        <div class="col-6 mb-8">
                                            <select class="form-select" id="nombre-docente">
                                            </select>
                                        </div>
                                        <div class="col-6 mb-4" style="display: flex; justify-content: space-between;">
                                            <div class="form-check form-switch">
                                                <input class="form-check-input" type="checkbox" role="switch"
                                                    id="tglSuplente">
                                                <label class="form-check-label" for="tglSuplente">Ver Suplente</label>
                                            </div>
                                            <button class="btn btn-outline-danger" style="height: 90%;" onClick="eliminarDocente();"
                                                id="btn-deleteDocente" >Eliminar docente</button>
                                        </div>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label for="" class="form-label">Condicion:</label><br />
                                        <select name="condicion-docente" class="form-select" id="condicion-docente">
                                            <option value="UNT">UNT</option>
                                            <option value="Invitado Nacional">Invitado Nacional</option>
                                            <option value="Invitado Local">Invitado Local</option>
                                            <option value="Invitado Internacional">Invitado Internacional</option>
                                            <option value="Externo">Externo</option>
                                        </select>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label for="" class="form-label">Grado:</label><br />
                                        <select name="grado-docente" class="form-select" id="grado-docente">
                                            <option value="dr">Doctor</option>
                                            <option value="dra">Doctora</option>
                                            <option value="ms">Mister</option>
                                        </select>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label for="" class="form-label">Correo:</label><br />
                                        <input type="email" class="form-control" id="email-docente">
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label for="" class="form-label">Documento de identidad:</label><br />
                                        <input type="text" class="form-control" id="doc-docente">
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label for="" class="form-label">Código:</label><br />
                                        <input type="text" class="form-control" id="codigo-docente" disabled>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label for="" class="form-label">Teléfono:</label><br />
                                        <input type="number" class="form-control" id="telefono-docente">
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-success" onClick="guardar_docente();">
                                    Guardar
                                </button>
                                <button class="btn btn-danger" onClick="$('#myModal').fadeOut();">
                                    Cerrar
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- MODAL CURSO -->
                <div class="modal" id="myModal-curso">
                    <div class="modal-dialog modal-dialog-centered modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Registrar curso</h5>
                            </div>
                            <div class="modal-body">
                                <input type="number" id="cursoEditar" hidden>
                                <div class="row">
                                    <div class="col-lg-12 col-12">
                                        <label for="" class="form-label">Curso</label><br>
                                        <select name="cboCurso" id="cboCurso" class="form-select" disabled>
                                            <option value="SD">Antes selecciona un ciclo ...</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-success" id="btnAgregarCursoModal"
                                    onClick="accionBtnGuardarCurso();">
                                    Guardar
                                </button>
                                <button class="btn btn-danger" onClick="$('#myModal-curso').fadeOut();">
                                    Cerrar
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- MODAL GRUPO -->
                <div class="modal" id="myModal-grupo">
                    <div class="modal-dialog modal-dialog-centered modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Gestionar grupos</h5>
                            </div>
                            <div class="modal-body">
                                <input type="number" id="cursoEditar" hidden>
                                <div class="row">
                                    <div class="col-lg-10 col-6 mb-3">
                                        <label for="" class="form-label">Fecha</label>
                                        <div class="input-group input-group-lg date datepicker3 container-calendar"
                                            id="newTratFechaInii">
                                            <input type="text" class="form-control puntero-i prohibido-no"
                                                name="newinputTratFechaIni" id="newTratFechaIni" value=""
                                                placeholder="Selecciona la fecha" required>
                                            <span class="input-group-addon manito-clic ">
                                                <i class="glyphicon glyphicon-calendar"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-2 col-6 mb-3">
                                        <label for="" class="form-label">Horas</label>
                                        <input type="number" class="form-control" name="txtHoras" id="txtHoras"
                                            required>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button class="btn btn-success" id="btnAgregarCursoModal"
                                    onClick="accionBtnGuardarCurso();">
                                    Guardar
                                </button>
                                <button class="btn btn-danger" onClick="$('#myModal-curso').fadeOut();">
                                    Cerrar
                                </button>
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
    <script src="../../view/js/index.js"></script>
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

        $('#cboCurso').select2({
            dropdownCssClass: "limitar-opciones",
            placeholder: 'Selecciona un curso ...'
        });

        $('#cboPrograma').select2({
            dropdownCssClass: "limitar-opciones",
            placeholder: 'Selecciona un programa ...'
        });

        $(".registerFormFcMv").bootstrapValidator({
            live: "enabled",
            fields: {
                newinputTratFechaIni: {
                    validators: {
                        date: {
                            format: "DD/MM/YYYY",
                            message: "ESTE VALOR NO COINCIDE CON UNA FECHA",
                        },
                        stringLength: {
                            min: 10,
                            max: 10,
                            message: "LA LONGITUD MÁXIMA ES DE 10 INCLUYENDO /",
                        },
                        regexp: {
                            regexp: /^[0-9-/]+$/,
                            message: "LA FECHA SOLO PUEDE TENER NÚMEROS Y /",
                        },
                    },
                },
            },
        });

        $(".datepicker3").datepicker({
            container: ".container-calendar",
            autoclose: false,
            todayHighlight: true,
            calendarWeeks: true,
            format: "dd/mm/yyyy",
            language: "es",
            multidate: true,
        });
    });
    </script>
</body>

</html>


<?php } ?>