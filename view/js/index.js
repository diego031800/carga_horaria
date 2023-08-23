// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
let cboCiclo = document.getElementById('cboCiclo');
let btnBuscar = document.getElementById('btnBuscar');
let cursoNombre = document.getElementById('cursoNombre');
let btnGuardar = document.getElementById('btnGuardar');
let btnCerrar = document.getElementById('btnCerrar');
let btnCancelar = document.getElementById('btnCancelar');

let cgh_id = 0;
let cgh_codigo = '';

var listacursos = [];
var fechascursos = [];
var listadocentes= [];
var id_current = 0;

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

function buscar_cursos() {
  let opcion = 'get_cursos_by_programa';
  let semestre = cboSemestre.value;
  let programa = cboPrograma.value;
  let ciclo = cboCiclo.value;

  btnBuscar.disabled = true;
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&sem_id=" + semestre +
      "&prg_id=" + programa + 
      "&ciclo=" + ciclo,
    success: function (data) {
      btnBuscar.disabled = false;
      objeto = JSON.parse(data);
      let opciones = objeto.cursos;
      cursoNombre.disabled = false;
      if (objeto.has_data == 0) {
        cursoNombre.disabled = true;
      }
      $('#cursoNombre').html(opciones);
    },
    error: function (data) {
      btnBuscar.disabled = false;
      alert("Error al mostrar");
    },
  });
}


// FIN OBTENER COMBOS

function agregar() {
  var id = parseInt(cursoNombre.value);
  var cursonombre = cursoNombre.options[cursoNombre.selectedIndex].text;
  var cursohoras = document.getElementById("cursoHoras").value;
  let fechas = document.getElementById("newTratFechaIni").value;
  if(cursoAgregado(id)){
    alert("Ya has agregado el curso");
    return;
  }
  if (cursonombre == "" || cursohoras == "" || fechas == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  let i = listacursos.length;
  var fechasagregar=  agregarFechas(fechas);
  listacursos.push({ index: id, curso: cursonombre, horas: cursohoras, fechas:fechasagregar, docente_principal:null });
  llenarTabla();
  limpiarInputs();
}

function cursoAgregado(index){
  if(listacursos.find(cursoI => cursoI.index === index) != null && listacursos.find(cursoI => cursoI.index === index) != undefined){
    return true;
  }else{
    return false;
  }
}

function agregarFechas(fechas) {
  var arrayFechas = fechas.split(",");
  var i = 0;
  var fechasdevolver = [];
  arrayFechas.forEach((element) => {
    i +=1;
    fechasdevolver.push({ index: i, fecha: element });
  });
  return fechasdevolver;
}

function limpiarInputs(){
  $(".datepicker3").datepicker('clearDates');
  $("#newTratFechaIni").val('');
  $("#cursoHoras").val("");
}

function editar(indexb) {
  var curso = listacursos.find(cursoI => cursoI.index === indexb);
  $("#cursoNombre").val(curso.index);
  $("#cursoHoras").val(curso.horas);
  var fechasMostrar = curso.fechas.map(function (fecha) {
      var partes = fecha.fecha.split("/");
      return new Date(partes[2], partes[1] - 1, partes[0]);
  });
  $("#cursoEditar").val(indexb);
  $(".datepicker3").datepicker('setDates', fechasMostrar);
  document.getElementById("agregar").disabled = true;
  document.getElementById("guardar").disabled = false;
  document.getElementById("cancelar").disabled = false;
}

function eliminar(index){
  listacursos= listacursos.filter((item) => item.index != index);
  llenarTabla();
}

function guardar() {
  var index = parseInt(document.getElementById("cursoEditar").value);
  var idNuevo = parseInt(cursoNombre.value);
  var cursonombreN = cursoNombre.options[cursoNombre.selectedIndex].text;
  var cursohoras = document.getElementById("cursoHoras").value;
  var fechas = document.getElementById("newTratFechaIni").value;
  var fechasNuevas = agregarFechas(fechas);
  listacursos.find(cursoI => cursoI.index === index).curso = cursonombreN;
  listacursos.find(cursoI => cursoI.index === index).horas = cursohoras;
  listacursos.find(cursoI => cursoI.index === index).fechas = fechasNuevas;
  listacursos.find(cursoI => cursoI.index === index).index = idNuevo;
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
    let stringFecha = elementC.fechas
      .map(element => element.fecha)
      .join(',');
    let nombre;
    let doc = elementC.docente_principal;
    if(doc == null){
      nombre = "Sin asignar docente";
    }else{
      nombre = doc.docente;
    }
    fila =
    '<tr><th scope="row">' +
    elementC.curso +
    "</th><td>" +
    elementC.horas +
    "</td><td>" +
    stringFecha +
    '<td><button class="btn btn-info" style="margin-right: 10px;" onClick="editar(' +
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
  var id_curso_modal = parseInt(document.getElementById("id-curso-docente").value);
  var doc_modal = document.getElementById("doc-docente").value;
  var email_modal = document.getElementById("email-docente").value;
  var telefono_modal = document.getElementById("telefono-docente").value;
  var condicion_modal = document.getElementById("condicion-docente").value;
  var nombre_docente_modal = document.getElementById("nombre-docente").value;
  var codigo_modal = document.getElementById("codigo-docente").value;
  var grado_modal = document.getElementById("grado-docente").value;
  if (listacursos.find(item => item.index === id_curso_modal).docente_principal != null) {
    listacursos.find(item => item.index === id_curso_modal).docente_principal.docente = nombre_docente_modal;
    listacursos.find(item => item.index === id_curso_modal).docente_principal.condicion = condicion_modal;
    listacursos.find(item => item.index === id_curso_modal).docente_principal.grado = grado_modal;
    listacursos.find(item => item.index === id_curso_modal).docente_principal.codigo = codigo_modal;
    listacursos.find(item => item.index === id_curso_modal).docente_principal.dni = doc_modal;
    listacursos.find(item => item.index === id_curso_modal).docente_principal.correo = email_modal;
    listacursos.find(item => item.index === id_curso_modal).docente_principal.telefono = telefono_modal;
  }else{
    listacursos.find(item => item.index === id_curso_modal).docente_principal={docente:nombre_docente_modal, condicion:condicion_modal,
    grado:grado_modal, codigo:codigo_modal,dni:doc_modal,correo:email_modal,telefono:telefono_modal};
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
  var docente = listacursos.find(item => item.index === index).docente_principal;
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

/* GUARDAR CARGA HORARIA */
function saveCargaHoraria() {

}

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  get_cbo_programas();
  change_cbo_ciclo();
  cboSemestre.addEventListener("change", get_cbo_unidades);
  cboSemestre.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", change_cbo_ciclo);
  btnBuscar.addEventListener("click", buscar_cursos);
  
}

// EVENTOS
window.addEventListener("load", load_document);
