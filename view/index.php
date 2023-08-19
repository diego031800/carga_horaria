<?php 
    include_once '../models/config.php';
    session_start();  
    if(!isset($_SESSION['login']))
    {
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
        <div class="row">
            <h3 class="mb-5">Registro de carga horaria</h3>
            <div class="col-lg-2 col-6 mb-5">
                <label for="" class="form-label">Semestre</label>
                <select class="form-select" id="cboSemestre">
                </select>
            </div>
            <div class="col-lg-4 col-6 mb-5">
                <label for="" class="form-label">Unidad</label>
                <select class="form-select" id="cboUnidad">
                </select>
            </div>
            <div class="col-lg-4 col-6 mb-5">
                <label class="form-label" for="ciclo">Programa</label>
                <select class="form-select" id="cboPrograma">
                </select>
            </div>
            <div class="col-lg-2 col-6 mb-5">
                <label class="form-label" for="ciclo">Ciclo</label>
                <select name="ciclo" class="form-select" id="cboCiclo" >
                </select>
            </div>
            <div class="col-12 row">
                <h3>Datos del curso</h3>
                <div class="col-6">
                    <label for="" class="form-label">Nombre del curso</label>
                    <select name="cursoNombre" id="cursoNombre" class="form-control">
                        <option value="Curso 1">Curso 1</option>
                        <option value="Curso 2">Curso 2</option>
                        <option value="Curso 3">Curso 3</option>
                        <option value="Curso 4">Curso 4</option>
                    </select>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Fecha</label>
                    <div class="input-group input-group-lg date datepicker3 container-calendar" id="newTratFechaInii">
                        <input type="text" class="form-control puntero-i prohibido-no" name="newinputTratFechaIni"
                            id="newTratFechaIni" value="" placeholder="Selecciona la fecha" required>
                        <span class="input-group-addon manito-clic ">
                            <i class="glyphicon glyphicon-calendar"></i>
                        </span>
                    </div>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Horas</label>
                    <input type="number" class="form-control" name="cursoHoras" id="cursoHoras" required>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Acciones</label><br>
                    <button class="btn btn-success" onClick="agregar();" id="agregar">Agregar</button>
                    <input type="text" hidden id="cursoEditar">
                    <button id="guardar" class="btn btn-warning" onClick="guardar();" disabled="true">Guardar</button>
                </div>
            </div>
        </div>

        <table class="table" id="cursosTabla">
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
                    <th scope="row">Curso 1</th>
                    <td>64</td>
                    <td>
                        <button class="btn btn-info" onClick="editar(0);">Editar</button>
                        <button class="btn btn-danger">Eliminar</button>
                    </td>
                    <td>Nombre del docente</td>
                    <td><button class="btn btn-danger">Ver</button></td>
                </tr>
            </tbody>
        </table>
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
        $(document).ready(function () {
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