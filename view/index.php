<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../assets/css/bootstrap.min.css">
    <title>Document</title>
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
                    <label for="" class="form-label">Nombre del curso</label>
                    <select name="" id="" class="form-control">
                        <option value="">Curso 1</option>
                    </select>
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

</body>
<script src="../assets/js/jquery-3.7.0.min.js"></script>
<script src="../assets/js/bootstrap.min.js"></script>
<script src="../view/js/index.js"></script>

</html>