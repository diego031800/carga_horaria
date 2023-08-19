// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
let cboCiclo = document.getElementById('cboCiclo');

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

function change_cbo_ciclo() {
  let unidad = $("#cboUnidad option[value='" + cboUnidad.value + "']").text();
  if (unidad == 'DOCTORADO') {
    $('#cboCiclo').html('<option value="">Selecciona un ciclo ...</option>' +
                        '<option value="1">1</option>' +
                        '<option value="2">2</option>' +
                        '<option value="3">3</option>' +
                        '<option value="4">4</option>' +
                        '<option value="5">5</option>' +
                        '<option value="6">6</option>');
  } else {
    $('#cboCiclo').html('<option value="">Selecciona un ciclo ...</option>' +
                        '<option value="1">1</option>' +
                        '<option value="2">2</option>' +
                        '<option value="3">3</option>' +
                        '<option value="4">4</option>');
  }
}

// FIN OBTENER COMBOS

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
}

function agregarFechas(fechas, index) {
  var arrayFechas = fechas.split(",");
  arrayFechas.forEach((element) => {
    let i = listacursos.length;
    fechascursos.push({ index: i, id: index, fecha:element });
  });
}

function editar(index) {
  $("#cursoNombre").val(listacursos[index].curso);
  $("#cursoHoras").val(listacursos[index].horas);
  let stringFecha="";
  fechascursos.forEach((element) => {
    if (element.id == index) {
      stringFecha = stringFecha+element.fecha+',';
    }
  });
  $("#newTratFechaIni").val(stringFecha);
  $("#cursoEditar").val(index);
  document.getElementById("agregar").disabled = true;
  document.getElementById("guardar").disabled = false;
}

function guardar() {
  let index = document.getElementById("cursoEditar").value;
  var cursonombre = document.getElementById("cursoNombre").value;
  var cursohoras = document.getElementById("cursoHoras").value;
  listacursos[index].curso = cursonombre;
  listacursos[index].horas = cursohoras;
  $("#cursoHoras").val("");
  limpiarTabla();
  llenarTabla();
  document.getElementById("guardar").disabled = true;
  document.getElementById("agregar").disabled = false;
}

function llenarTabla() {
  listacursos.forEach((element) => {
    fila =
      '<tr><th scope="row">' +
      element.curso +
      "</th><td>" +
      element.horas +
      "</td>" +
      '<td><button class="btn btn-info" onClick="editar(' +
      element.index +
      ');">Editar</button><button class="btn btn-danger">Eliminar</button></td>' +
      "<td>Nombre del docente</td>" +
      '<td><button class="btn btn-danger">Ver</button></td></tr>';
    $("#cursosTabla").append(fila);
  });
}

function limpiarTabla() {
  $("#cursosTabla tbody").empty();
}

function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  get_cbo_programas();
  change_cbo_ciclo();
  cboSemestre.addEventListener("change", get_cbo_unidades);
  cboSemestre.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", change_cbo_ciclo);
}

// EVENTOS
window.addEventListener("load", load_document);
