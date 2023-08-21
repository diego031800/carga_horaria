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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" crossorigin="anonymous">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-HwwvtgBNo3bZJJLYd8oVXjrBZt8cqVSpeBNS5n7C8IVInixGAoxmnlMuBnhbgrkm" crossorigin="anonymous"></script>
    <title>Carga Horaria</title>
</head>

<body>
    <div class="modal" id="myModal"style= "">
        <div class="modal-content-1">
            <span class="close-btn" id="closeModal">&times;</span>
            <h2>Registrar docente:</h2>
            <input type="text" hidden id="id-curso-docente">
            <div class="row">
                <div class="col-12">
                    <label for="" class="form-label">Nombre:</label><br/>
                    <select name="nombre-docente" class="form-control" id="nombre-docente" >
                        <option value="Docente 1">Docente 1</option>
                        <option value="Docente 2">Docente 2</option>
                        <option value="Docente 3">Docente 3</option>
                        <option value="Docente 4">Docente 4</option>
                        <option value="Docente 5">Docente 5</option>
                        <option value="Docente 6">Docente 6</option>
                    </select>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Condicion:</label><br/>
                    <select name="condicion-docente" class="form-control" id="condicion-docente" >
                        <option value="UNT">UNT</option>
                        <option value="Invitado Nacional">Invitado Nacional</option>
                        <option value="Invitado Local">Invitado Local</option>
                        <option value="Invitado Internacional">Invitado Internacional</option>
                        <option value="Externo">Externo</option>
                    </select>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Grado:</label><br/>
                    <select name="grado-docente" class="form-control" id="grado-docente" >
                        <option value="dr">Doctor</option>
                        <option value="dra">Doctora</option>
                        <option value="ms">Mister</option>
                    </select>
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Correo:</label><br/>
                    <input type="email" class="form-control" id="email-docente">
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Documento de identidad:</label><br/>
                    <input type="text" class="form-control" id="doc-docente">
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Código:</label><br/>
                    <input type="text" class="form-control" id="codigo-docente">
                </div>
                <div class="col-6">
                    <label for="" class="form-label">Teléfono:</label><br/>
                    <input type="number" class="form-control" id="telefono-docente">
                </div>
                <div class="col-12">
                    <button class="btn btn-success" onClick="guardar_docente();">Guardar</button>
                </div>
            </div>
        </div>
    </div>
    <div class="container-fluid px-5 my-5">
        <div class="row">
            <div class="col-12 row">
                <h3>Registro de la carga horaria</h3>
                <div class="col-4">
                    <label for="" class="form-label">Semestre</label>
                    <select class="form-control" id="cboSemestre">
                    </select>
                </div>
                <div class="col-4">
                    <label for="" class="form-label">Unidad</label>
                    <select class="form-control" id="cboUnidad">
                    </select>
                </div>
                <div class="col-4">
                    <label class="form-label" for="ciclo">Programa</label>
                    <select class="form-control" id="cboPrograma">
                    </select>
                </div>
            </div>
            <div class="col-12 row">
                <h3>Datos del curso</h3>
                <div class="col-6">
                    <label class="form-label" for="ciclo">Ciclo</label>
                    <select name="ciclo" class="form-control" id="ciclo" >
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
                    <input type="number" hidden id="cursoEditar">
                    <button id="guardar" class="btn btn-warning" onClick="guardar();" disabled="true">Guardar</button>
                    <button class="btn btn-info" onClick="cancelar();" id="cancelar" disabled="true">Cancelar</button>
                </div>
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
                    <th scope="row">Curso 1</th>
                    <td>64</td>
                    <td>27/08/2023</td>
                    <td>
                        <button class="btn btn-info" onClick="editar(0);">Editar</button>
                        <button class="btn btn-danger" onClick="eliminar(0);">Eliminar</button>
                    </td>
                    <td>Docente 1</td>
                    <td><button class="btn btn-danger" onClick="abrir_docente_modal(0)";>Ver</button></td>
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