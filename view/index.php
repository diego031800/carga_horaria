<?php
include_once '../models/config.php';
session_start();
if (!isset($_SESSION['login'])) {
    header("Location:../index.php");
} else {
    date_default_timezone_set('America/Lima');
?>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- BOOTSTRAP -->
        <link rel="stylesheet" href="../assets/css/bootstrap.min.css">
        <link rel="stylesheet" href="../assets/css/bootstrap-theme.min.css">
        <link rel="stylesheet" href="../assets/css/bootstrap-datepicker3.min.css">
        <link rel="stylesheet" href="../assets/css/bootstrapValidator.min.css">
        <!-- SELECT 2 -->
        <link rel="stylesheet" href="../assets/css/select2/select2.css">
        <!-- ESTILOS PROPIOS -->
        <link rel="stylesheet" href="/carga_horaria/view/css/styles.css">
        <title>CARGA HORARIA</title>
    </head>

    <body>
        <div class="container-fluid px-5 my-5">
            <div class="row mb-2">
                <h3>Registro de la carga horaria</h3>
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
                    <button class="btn btn-outline-secondary" disabled>Editar</button>
                </div>
            </div>
            <div class="row">
                <h3>Datos del curso</h3>
                <div class="col-lg-2 col-6 mb-3">
                    <label class="form-label" for="cboCiclo">Ciclo</label>
                    <select name="ciclo" class="form-select" id="cboCiclo">
                    </select>
                </div>
                <div class="col-lg-5 col-6 mb-3">
                    <label for="" class="form-label">Curso</label>
                    <select name="cboCurso" id="cboCurso" class="form-select" disabled>
                        <option value="SD">Antes selecciona un ciclo ...</option>
                    </select>
                </div>
                <div class="col-lg-5 col-6 mb-3">
                    <label for="" class="form-label">Fecha</label>
                    <div class="input-group input-group-lg date datepicker3 container-calendar" id="newTratFechaInii">
                        <input type="text" class="form-control puntero-i prohibido-no" name="newinputTratFechaIni" id="newTratFechaIni" value="" placeholder="Selecciona la fecha" required>
                        <span class="input-group-addon manito-clic ">
                            <i class="glyphicon glyphicon-calendar"></i>
                        </span>
                    </div>
                </div>
                <div class="col-lg-2 col-6 mb-3">
                    <label for="" class="form-label">Horas</label>
                    <input type="number" class="form-control" name="txtHoras" id="txtHoras" required>
                </div>
                <div class="col-lg-12 col-6 mb-3">
                    <button class="btn btn-success" onClick="agregar();" id="btnAgregarCurso">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><style>svg{fill:#ffffff}</style><path d="M256 80c0-17.7-14.3-32-32-32s-32 14.3-32 32V224H48c-17.7 0-32 14.3-32 32s14.3 32 32 32H192V432c0 17.7 14.3 32 32 32s32-14.3 32-32V288H400c17.7 0 32-14.3 32-32s-14.3-32-32-32H256V80z"/></svg>
                        &nbsp; Agregar curso
                    </button>
                    <input type="number" hidden id="cursoEditar">
                    <button id="guardar" class="btn btn-warning" onClick="guardar();" disabled="true" id="btnGuardarCurso">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 384 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><style>svg{fill:#1d2d49}</style><path d="M0 48V487.7C0 501.1 10.9 512 24.3 512c5 0 9.9-1.5 14-4.4L192 400 345.7 507.6c4.1 2.9 9 4.4 14 4.4c13.4 0 24.3-10.9 24.3-24.3V48c0-26.5-21.5-48-48-48H48C21.5 0 0 21.5 0 48z"/></svg>
                        &nbsp; Guardar edición
                    </button>
                    <button class="btn btn-info" onClick="cancelar();" id="cancelar" disabled="true" id="btnCancelarEditar">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 384 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><style>svg{fill:#ffffff}</style><path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"/></svg>
                        &nbsp; Cancelar
                    </button>
                </div>
            </div>

                <table class="table" id="cursosTabla" name="cursosTabla">
                    <thead>
                        <tr>
                            <th scope="col">Curso</th>
                            <th scope="col">Horas</th>
                            <th scope="col">Fechas</th>
                            <th scope="col">Acciones</th>
                            <th scope="col">Docente</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="text-center" colspan="5">Sin registros.</td>
                        </tr>
                    </tbody>
                </table>
                <div class="row">
                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                    <button class="btn btn-primary me-md-2" type="button" id="btnGuardar">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><style>svg{fill:#ffffff}</style><path d="M64 32C28.7 32 0 60.7 0 96V416c0 35.3 28.7 64 64 64H384c35.3 0 64-28.7 64-64V173.3c0-17-6.7-33.3-18.7-45.3L352 50.7C340 38.7 323.7 32 306.7 32H64zm0 96c0-17.7 14.3-32 32-32H288c17.7 0 32 14.3 32 32v64c0 17.7-14.3 32-32 32H96c-17.7 0-32-14.3-32-32V128zM224 288a64 64 0 1 1 0 128 64 64 0 1 1 0-128z"/></svg>
                        &nbsp; Guardar
                    </button>
                    <button class="btn btn-success" type="button" id="btnCerrar">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 448 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><style>svg{fill:#ffffff}</style><path d="M144 144v48H304V144c0-44.2-35.8-80-80-80s-80 35.8-80 80zM80 192V144C80 64.5 144.5 0 224 0s144 64.5 144 144v48h16c35.3 0 64 28.7 64 64V448c0 35.3-28.7 64-64 64H64c-35.3 0-64-28.7-64-64V256c0-35.3 28.7-64 64-64H80z"/></svg>
                        &nbsp; Cerrar
                    </button>
                    <button class="btn btn-danger" type="button" id="btnCancelar">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 384 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. --><style>svg{fill:#ffffff}</style><path d="M342.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 210.7 86.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L146.7 256 41.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L192 301.3 297.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L237.3 256 342.6 150.6z"/></svg>
                        &nbsp; Cancelar
                    </button>
                </div>
                </div>
            </div>
            <!-- MODALES -->
            <div class="modal" id="myModal">
                <div class="modal-content-1">
                    <span class="close-btn" id="closeModal">&times;</span>
                    <h2>Registrar docente:</h2>
                    <input type="text" hidden id="id-curso-docente">
                    <div class="row">
                        <div class="col-12 mb-3">
                            <label for="" class="form-label">Nombre:</label><br />
                            <select class="form-select" id="txtnombre-docente">
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label for="" class="form-label">Condicion:</label><br />
                            <select name="cbocondicion-docente" class="form-select" id="cbocondicion-docente">
                                <option value="UNT">UNT</option>
                                <option value="Invitado Nacional">Invitado Nacional</option>
                                <option value="Invitado Local">Invitado Local</option>
                                <option value="Invitado Internacional">Invitado Internacional</option>
                                <option value="Externo">Externo</option>
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label for="" class="form-label">Grado:</label><br />
                            <select name="cbogrado-docente" class="form-select" id="cbogrado-docente">
                                <option value="dr">Doctor</option>
                                <option value="dra">Doctora</option>
                                <option value="ms">Mister</option>
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label for="" class="form-label">Correo:</label><br />
                            <input type="email" class="form-control" id="txtemail-docente">
                        </div>
                        <div class="col-6 mb-3">
                            <label for="" class="form-label">Documento de identidad:</label><br />
                            <input type="text" class="form-control" id="txtdoc-docente">
                        </div>
                        <div class="col-6 mb-3">
                            <label for="" class="form-label">Código:</label><br />
                            <input type="text" class="form-control" id="txtcodigo-docente">
                        </div>
                        <div class="col-6 mb-3">
                            <label for="" class="form-label">Teléfono:</label><br />
                            <input type="number" class="form-control" id="txttelefono-docente">
                        </div>
                        <div class="col-12">
                            <button class="btn btn-success" id="btnGuardarDocente" onClick="guardar_docente();">Guardar</button>
                        </div>
                    </div>
                </div>
            </div>


            <!-- SCRIPTS -->
            <!-- JQUERY -->
            <script src="../assets/js/jquery-3.7.0.min.js"></script>
            <!-- BOOTSTRAP -->
            <script src="../assets/js/bootstrap.min.js"></script>
            <script src="../assets/js/datepicker/bootstrap-datepicker.min.js"></script>
            <script src="../assets/js/datepicker/bootstrap-datepicker.es.min.js"></script>
            <script src="../assets/js/datepicker/bootstrapValidator.min.js"></script>
            <!-- DATE PICKER -->
            <script src="../assets/js/datepicker/es_ES.min.js"></script>
            <!-- SELECT 2 -->
            <script src="../assets/js/select2/select2.js"></script>
            <!-- SCRIPT DESPACHO -->
            <script src="../view/js/index.js"></script>
            <!-- SCRIPT PROPIO INICIO -->
            <script>
                $(document).ready(function() {
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
                        autoclose: true,
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