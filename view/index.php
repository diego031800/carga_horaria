<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="../assets/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="../assets/css/bootstrap-datepicker3.min.css">
    <link rel="stylesheet" href="../assets/css/bootstrapValidator.min.css">
    <link rel="stylesheet" href="../assets/css/select2/select2.css">
    <link rel="stylesheet" href="/carga_horaria/view/css/styles.css">
    <title>Carga Horaria</title>
</head>

<body>
    <form action="">
    </form>
    <div class="container">
        <div class="row">

            <div class="col-12 row">
                <h3>Registro de la carga horaria</h3>
                <div class="col-6">
                    <label for="" class="form-label">Semestre</label>
                    <select name="" class="form-control" id="">
                    </select>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Unidad</label>
                    <select name="" class="form-control" id="">
                    </select>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Modo</label>
                    <select name="" class="form-control" id="">
                        <option value="maestria">Maestria</option>
                        <option value="doctorado">Doctorado</option>
                    </select>
                </div>
                <div class="col-6">
                    <label class="form-label" for="ciclo">Mencion</label>
                    <select name="" class="form-control" id="">
                    </select>
                </div>
            </div>
            <div class="col-12 row">
                <h3>Datos del curso</h3>
                <div class="col-6">
                    <label class="form-label" for="ciclo">Ciclo</label>
                    <select name="ciclo" class="form-control cantidad-show" id="ciclo" >
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                    </select>
                </div>
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



    <script src="../assets/js/jquery-3.7.0.min.js"></script>
    <script src="../assets/js/bootstrap.min.js"></script>
    <script src="../assets/js/datepicker/bootstrap-datepicker.min.js"></script>
    <script src="../assets/js/datepicker/bootstrap-datepicker.es.min.js"></script>
    <script src="../assets/js/datepicker/bootstrapValidator.min.js"></script>
    <script src="../assets/js/datepicker/es_ES.min.js"></script>
    <script src="../assets/js/select2/select2.js"></script>
    <script src="../view/js/index.js"></script>
</body>

</html>