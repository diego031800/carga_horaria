// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');

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

// FIN OBTENER COMBOS

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

var listacursos = [{ curso: "Curso 1", horas: 64 }];
function agregar() {
  var cursonombre = document.getElementById("cursoNombre").value;
  var cursohoras = document.getElementById("cursoHoras").value;
  if (cursonombre == "" || cursohoras == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  listacursos.push({ curso: cursonombre, horas: cursohoras });
  let index = listacursos.length - 1;
  fila =
    '<tr><th scope="row">' +
    cursonombre +
    "</th><td>" +
    cursohoras +
    "</td>" +
    '<td><button class="btn btn-info" onClick="editar(' +
    index +
    ');">Editar</button><button class="btn btn-danger">Eliminar</button></td>' +
    "<td>Nombre del docente</td>" +
    '<td><button class="btn btn-danger">Ver</button></td></tr>';
  $("#cursosTabla").append(fila);
}
function editar(index) {
  $("#cursoNombre").val(listacursos[index].curso);
  $("#cursoHoras").val(listacursos[index].horas);
  document.getElementById("guardar").disabled = false;
}
function guardar() {
  let index = document.getElementById("cursoEditar").value;
  listacursos[index].curso = document.getElementById("cursoNombre").value;
  listacursos[index].horas = document.getElementById("cursoHoras").value;
  $("#cursoHoras"). val("");
  document.getElementById("guardar").disabled = true;
}

function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  cboSemestre.addEventListener("change", get_cbo_unidades);
}

// EVENTOS
window.addEventListener("load", load_document);
