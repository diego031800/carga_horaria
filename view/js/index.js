// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');

var listacursos = [{ index: 0, curso: "Curso 1", horas: "64" }];
var fechascursos = [{ index: 0, id: 0, fecha: "27/08/2023" }];
var listadocentes= [{ index: 0, id :0, docente: "Docente 1", condicion:"Invitado Nacional",grado:"dr", codigo:"64", dni:"74",correo:"gggg", telefono:"9"}]
var id_current =1 

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

function agregar() {
  var cursonombre = document.getElementById("cursoNombre").value;
  var cursohoras = document.getElementById("cursoHoras").value;
  let fechas = document.getElementById("newTratFechaIni").value;
  if (cursonombre == "" || cursohoras == "" || fechas == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  let i = listacursos.length;
  listacursos.push({ index: id_current, curso: cursonombre, horas: cursohoras });
  agregarFechas(fechas, id_current);
  llenarTabla();
  limpiarInputs();
  id_current += 1;
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

function editar(indexb) {
  var curso = listacursos.find(cursoI => cursoI.index === indexb);
  $("#cursoNombre").val(curso.curso);
  $("#cursoHoras").val(curso.horas);
  var fechasMostrar = fechascursos.map(function (fecha) {
    if(indexb===fecha.id){
      var partes = fecha.fecha.split("/");
      return new Date(partes[2], partes[1] - 1, partes[0]);
    }
  });
  $("#cursoEditar").val(indexb);
  $(".datepicker3").datepicker('setDates', fechasMostrar);
  document.getElementById("agregar").disabled = true;
  document.getElementById("guardar").disabled = false;
  document.getElementById("cancelar").disabled = false;
}
function eliminar(index){
  listacursos= listacursos.filter((item) => item.index != index);
  fechascursos= fechascursos.filter((item) => item.id != index);
  llenarTabla();
}

function guardar() {
  var index = parseInt(document.getElementById("cursoEditar").value);
  var cursonombre = document.getElementById("cursoNombre").value;
  var cursohoras = document.getElementById("cursoHoras").value;
  fechascursos= fechascursos.filter((item) => item.id != index);
  var fechas = document.getElementById("newTratFechaIni").value;
  agregarFechas(fechas, index);
  listacursos.find(cursoI => cursoI.index === index).curso = cursonombre;
  listacursos.find(cursoI => cursoI.index === index).horas = cursohoras;
  limpiarInputs();
  llenarTabla();
  document.getElementById("guardar").disabled = true;
  document.getElementById("cancelar").disabled = true;
  document.getElementById("agregar").disabled = false;
}

function cancelar(){
  limpiarInputs();
  document.getElementById("agregar").disabled = false;
  document.getElementById("guardar").disabled = true;
  document.getElementById("cancelar").disabled = true;
  $("#cursoEditar").val("");
}


function llenarTabla() {
  $("#cursosTabla tbody").empty();
  if(listacursos.length ==0){
    return;
  }
  listacursos.forEach((elementC) => {
    let stringFecha = fechascursos
      .filter(element => elementC.index === element.id)
      .map(element => element.fecha)
      .join(',');
    let nombre;
    let doc = listadocentes.find(item => item.id === elementC.index);
    if(doc == null && doc === undefined ){
      nombre = "Sin asignar docente";
    }else{
      nombre = doc.docente
    }
    fila =
    '<tr><th scope="row">' +
    elementC.curso +
    "</th><td>" +
    elementC.horas +
    "</td><td>" +
    stringFecha +
    '<td><button class="btn btn-info" onClick="editar(' +
    elementC.index +
    ');">Editar</button><button class="btn btn-danger" onClick="eliminar('+
    elementC.index +
    ')";>Eliminar</button></td>' +
    '<td>'+nombre+'</td>' +
    '<td><button class="btn btn-danger" onClick="abrir_docente_modal('+
    elementC.index+
    ');">Ver</button></td></tr>';
    $("#cursosTabla tbody").append(fila);
  });
}

function guardar_docente(){
  var indx = listadocentes.length;
  var id_curso_modal = parseInt(document.getElementById("id-curso-docente").value);
  var doc_modal = document.getElementById("doc-docente").value;
  var email_modal = document.getElementById("email-docente").value;
  var telefono_modal = document.getElementById("telefono-docente").value;
  var condicion_modal = document.getElementById("condicion-docente").value;
  var nombre_docente_modal = document.getElementById("nombre-docente").value;
  var codigo_modal = document.getElementById("codigo-docente").value;
  var grado_modal = document.getElementById("grado-docente").value;
  if (listadocentes.find(item => item.id === id_curso_modal) != null && listadocentes.find(item => item.id === id_curso_modal) !== undefined ) {
    listadocentes.find(item => item.id === id_curso_modal).docente = nombre_docente_modal;
    listadocentes.find(item => item.id === id_curso_modal).condicion = condicion_modal;
    listadocentes.find(item => item.id === id_curso_modal).grado = grado_modal;
    listadocentes.find(item => item.id === id_curso_modal).codigo = codigo_modal;
    listadocentes.find(item => item.id === id_curso_modal).dni = doc_modal;
    listadocentes.find(item => item.id === id_curso_modal).correo = email_modal;
    listadocentes.find(item => item.id === id_curso_modal).telefono = telefono_modal;
  }else{
    listadocentes.push({index:indx, id:id_curso_modal, docente:nombre_docente_modal, condicion:condicion_modal,
    grado:grado_modal, codigo:codigo_modal,dni:doc_modal,correo:email_modal,telefono:telefono_modal});
  }
  limpiarInputsModal();
  document.getElementById('myModal').style.display = "none";
  llenarTabla();
}
//[{ index: 0, id :0, docente: "Profesor 1", condicion:"Invitado Nacional",grado:"dr", codigo:"64", dni:"74",correo:"gggg", telefono:"9"}]
function limpiarInputsModal(){
  $("#id-curso-docente").val("");
  $("#doc-docente").val("");
  $("#email-docente").val("");
  $("#codigo-docente").val("");
  $("#telefono-docente").val("");
}

function abrir_docente_modal(index){
  var docente = listadocentes.find(item => item.id === index);
  if (docente != null && docente !== undefined ) {
    $("#nombre-docente").val(docente.docente);
    $("#condicion-docente").val(docente.condicion);
    $("#grado-docente").val(docente.grado);
    $("#codigo-docente").val(docente.codigo);
    $("#doc-docente").val(docente.dni);
    $("#email-docente").val(docente.correo);
    $("#telefono-docente").val(docente.telefono);
  }
  document.getElementById('myModal').style.display = "block";
  $("#id-curso-docente").val(index);
  $('#nombre-docente').select2({
    dropdownCssClass: "limitar-opciones",
    dropdownParent: $("#myModal")
  });
}

function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  get_cbo_programas();
  cboSemestre.addEventListener("change", get_cbo_unidades, get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
}

// MODAL JS

document.getElementById('closeModal').addEventListener('click', function() {
  document.getElementById('myModal').style.display = "none";
  limpiarInputsModal();
});

window.onclick = function(event) {
  if (event.target === document.getElementById('myModal')) {
      document.getElementById('myModal').style.display = "none";
      limpiarInputsModal();
  }
}

// EVENTOS
window.addEventListener("load", load_document);
