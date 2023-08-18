<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="../assets/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="../assets/css/bootstrap-datepicker3.min.css">
    <link rel="stylesheet" href="../assets/css/bootstrapValidator.min.css">
    <title>Carga Horaria</title>
</head>

<body>
    <form action="">
        <div class="row">
            <div class="col-12 row">
                <h3>Unidad: AQUI VA LA UNIDAD</h3>
                <div class="col-6">
                    <label for="" class="form-label">Modo</label>
                    <select name="" class="form-control" id="">
                        <option value="maestria">Maestria</option>
                        <option value="doctorado">Doctorado</option>
                    </select>
                </div>
                <div class="col-6">
                    <label class="form-label" for="ciclo">Programa</label>
                    <select name="" class="form-control" id="">
                        <option value="pr1">Programa 1</option>
                        <option value="pr2">Programa 2</option>
                    </select>
                </div>
            </div>
            <div class="col-12 row">
                <h3>Datos del curso</h3>
                <div class="col-6">
                    <label for="" class="form-label">Nombre del curso</label>
                    <select name="cursoNombre" id="cursoNombre" class="form-control">
                        <option value="">Curso 1</option>
                    </select>
                </div>
                <div class="col-6">
                    <label class="form-label" for="ciclo">Ciclo</label>
                    <select name="ciclo" class="form-control" id="ciclo">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
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
                    <input type="number" class="form-control" name="cursoHoras" id="cursoHoras">
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Acciones</label><br>
                    <button class="btn btn-info" onClick="ver();">Ver</button><br>
                    <button class="btn btn-success">Agregar</button>
                </div>
            </div>
        </div>
    </form>

    <table class="table">
        <thead>
            <tr>
                <th scope="col">Curso</th>
                <th scope="col">Acciones</th>
                <th scope="col">Docente</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <th scope="row">Curso 1</th>
                <td>
                    <button class="btn btn-info">Editar</button>
                    <button class="btn btn-danger">Eliminar</button>
                </td>
                <td>Nombre del docente</td>
                <td><button class="btn btn-danger">Ver</button></td>
            </tr>
        </tbody>
    </table>


    <script src="../assets/js/jquery-3.7.0.min.js"></script>
    <script src="../assets/js/bootstrap.min.js"></script>
    <script src="../view/js/index.js"></script>
    <script src="../assets/js/datepicker/bootstrap-datepicker.min.js"></script>
    <script src="../assets/js/datepicker/bootstrap-datepicker.es.min.js"></script>
    <script src="../assets/js/datepicker/bootstrapValidator.min.js"></script>
    <script src="../assets/js/datepicker/es_ES.min.js"></script>
    <script>
    $(document).ready(function() {
        $('.registerFormFcMv').bootstrapValidator({
            live: 'enabled',
            fields: {
                newinputTratFechaIni: {
                    validators: {
                        date: {
                            format: 'DD/MM/YYYY',
                            message: 'ESTE VALOR NO COINCIDE CON UNA FECHA'
                        },
                        stringLength: {
                            min: 10,
                            max: 10,
                            message: 'LA LONGITUD MÁXIMA ES DE 10 INCLUYENDO /'
                        },
                        regexp: {
                            regexp: /^[0-9-/]+$/,
                            message: 'LA FECHA SOLO PUEDE TENER NÚMEROS Y /'
                        }
                    }
                }
            }
        });

        $('.datepicker3').datepicker({
            container: '.container-calendar',
            autoclose: true,
            todayHighlight: true,
            calendarWeeks: true,
            format: 'dd/mm/yyyy',
            language: 'es',
            multidate: true
        });
    });
    </script>
    <script>
        function ver(){
            var text = document.getElementById("newTratFechaIni").value;
            alert(text);
        }
    </script>
    <script>
        function agregar(){
            var nombre-curso = document.getElementById("cursoNombre").value;
            var nombre-curso = document.getElementById("cursoNombre").value;
            alert(text);
        }
    </script>
</body>

</html>