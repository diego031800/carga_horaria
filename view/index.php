<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-HwwvtgBNo3bZJJLYd8oVXjrBZt8cqVSpeBNS5n7C8IVInixGAoxmnlMuBnhbgrkm" crossorigin="anonymous">
    </script>
    <title>Document</title>
</head>

<body>
    <form action="">
        <div class="row">
            <div class="col-12 row">
                <h3>Unidad: AQUI VA LA UNIDAD</h3>
                <div class="col-6">
                    <label for="" class="form-label">Modo: </label>
                    <select name="" class="form-control" id="">
                        <option value="maestria">Maestria</option>
                        <option value="doctorado">Doctorado</option>
                    </select>
                </div>
                <div class="col-6">
                    <label class="form-label" for="ciclo">Mencion: </label>
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
                <div class="col-6">
                    <label class="form-label" for="ciclo">Fecha: </label>
                    <input type="text" class="form-control" name="rangoFechas" id="rangoFechas">
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


    <!-- Scripts -->

    
    <script>
        $(document).ready(function() {
            $('input[name="rangoFechas"]').daterangepicker({
                opens: 'left', // El calendario se abre a la izquierda del input
                autoApply: true, // Aplicar automáticamente el rango al seleccionar las fechas
                ranges: {
                    'Últimos 7 días': [moment().subtract(6, 'days'), moment()],
                    'Este mes': [moment().startOf('month'), moment().endOf('month')],
                    'Último mes': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1,
                        'month').endOf('month')]
                },
                locale: {
                    format: 'YYYY-MM-DD', // Formato de fecha
                    separator: ' - ', // Separador de rango de fechas
                    applyLabel: 'Aplicar',
                    cancelLabel: 'Cancelar',
                    fromLabel: 'Desde',
                    toLabel: 'Hasta',
                    customRangeLabel: 'Rango personalizado',
                    weekLabel: 'S',
                    daysOfWeek: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'],
                    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto',
                        'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
                    ],
                    firstDay: 1
                }
            });
        });
    </script>



    <!-- Archivos de javascript -->
    <script type="text/javascript" src="https://cdn.jsdelivr.net/jquery/latest/jquery.min.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />
</body>

</html>