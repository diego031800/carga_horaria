// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');

// FUNCIONES
// INICIO OBTENER COMBOS
function get_cbo_semestres() {
  let opcion = "get_cbo_semestres";
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      let opciones = data;
      $('#cboSemestre').html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar: " + data);
    },
  });
}

function get_cbo_unidades() {
  let opcion = "get_cbo_unidades";
  let sem_id = cboSemestre.value;
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&sem_id=" + sem_id,
    success: function (data) {
      objeto = JSON.parse(data);
      let opciones = objeto.unidades;
      cboUnidad.disabled = false;
      if (objeto.has_data == 0) {
        cboUnidad.disabled = true;
      }
      $('#cboUnidad').html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_programas() {
  let opcion = "get_cbo_programas";
  let sem_id = cboSemestre.value;
  let sec_id = cboUnidad.value;
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&sem_id=" + sem_id +
      "&sec_id=" + sec_id,
    success: function (data) {
      objeto = JSON.parse(data);
      let opciones = objeto.programas;
      cboPrograma.disabled = false;
      if (objeto.has_data == 0) {
        cboPrograma.disabled = true;
      }
      $('#cboPrograma').html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

// FIN OBTENER COMBOS


// Date picker
$(document).ready(function () {
  $("#ciclo").select2({
    dropdownCssClass: "limitar-opciones",
  });
});

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

// Operaciones de cursos

var listacursos = [{ index: 0, curso: "Curso 1", horas: "64" }];
var fechascursos = [{ index: 0, id: 0, fecha: "27/08/2023" }];

function agregar() {
  var cursonombre = document.getElementById("cursoNombre").value;
  var cursohoras = document.getElementById("cursoHoras").value;
  let fechas = document.getElementById("newTratFechaIni").value;
  if (cursonombre == "" || cursohoras == "" || fechas == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  let i = listacursos.length;
  listacursos.push({ index: i, curso: cursonombre, horas: cursohoras });
  agregarFechas(fechas, i);
  fila =
    '<tr><th scope="row">' +
    cursonombre +
    "</th><td>" +
    cursohoras +
    "</td><td>" +
    fechas +
    '</td><td><button class="btn btn-info" onClick="editar(' +
    i +
    ');">Editar</button><button class="btn btn-danger">Eliminar</button></td>' +
    "<td>Nombre del docente</td>" +
    '<td><button class="btn btn-danger">Ver</button></td></tr>';
  $("#cursosTabla").append(fila);
  limpiarInputs()
}

function agregarFechas(fechas, index) {
  var arrayFechas = fechas.split(",");
  var i = listacursos.length-2;
  arrayFechas.forEach((element) => {
    i +=1;
    fechascursos.push({ index: i, id: index, fecha: element });
  });
}

function limpiarInputs(){
  $(".datepicker3").datepicker('clearDates');
  $("#newTratFechaIni").val('');
  $("#cursoHoras").val("");
}

function editar(index) {
  $("#cursoNombre").val(listacursos[index].curso);
  $("#cursoHoras").val(listacursos[index].horas);
  var fechasMostrar = fechascursos.map(function (fecha) {
    if(index==fecha.id){
      var partes = fecha.fecha.split("/");
      return new Date(partes[2], partes[1] - 1, partes[0]);
    }
  });
  $("#cursoEditar").val(index);
  $(".datepicker3").datepicker('setDates', fechasMostrar);
  document.getElementById("agregar").disabled = true;
  document.getElementById("guardar").disabled = false;
}

function guardar() {
  var index = document.getElementById("cursoEditar").value;
  var cursonombre = document.getElementById("cursoNombre").value;
  var cursohoras = document.getElementById("cursoHoras").value;
  console.log(index);
  fechascursos.forEach(element => {
    if (index == element.id) {
      fechascursos.splice(element.index);
    }
  });
  var fechas = document.getElementById("newTratFechaIni").value;
  agregarFechas(fechas, index);
  listacursos[index].curso = cursonombre;
  listacursos[index].horas = cursohoras;
  limpiarInputs()
  llenarTabla();
  document.getElementById("guardar").disabled = true;
  document.getElementById("agregar").disabled = false;
}

function llenarTabla() {
  $("#cursosTabla tbody").empty();
  listacursos.forEach((element) => {
    let stringFecha = "";
    let primero = true;
    fechascursos.forEach(element => {
      if (primero) {
        stringFecha += element.fecha;
        primero = false;
      } else {
        stringFecha += ',' + element.fecha;
      }
    });
    fila =
      '<tr><th scope="row">' +
      element.curso +
      "</th><td>" +
      element.horas +
      "</td><td>" +
      stringFecha +
      '<td><button class="btn btn-info" onClick="editar(' +
      element.index +
      ');">Editar</button><button class="btn btn-danger">Eliminar</button></td>' +
      "<td>Nombre del docente</td>" +
      '<td><button class="btn btn-danger">Ver</button></td></tr>';
    $("#cursosTabla").append(fila);
  });
}

function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  get_cbo_programas();
  cboSemestre.addEventListener("change", get_cbo_unidades, get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
}

// EVENTOS
window.addEventListener("load", load_document);
