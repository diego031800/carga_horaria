// Elementos HTML
//   Unidades
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
//   Curso
let cboCiclo = document.getElementById('cboCiclo');
let cboCurso = document.getElementById('cboCurso');
let txtHoras = document.getElementById('txtHoras');
let txtFechas= document.getElementById('newTratFechaIni');
let btnAgregarCurso = document.getElementById('btnAgregarCurso');
let btnGuardarCurso = document.getElementById('btnGuardarCurso');
let btnCancelarEditar = document.getElementById('btnCancelarEditar');
let txtIdCursoEditar = document.getElementById('cursoEditar');

// Docente modal

let txtIdModal = parseInt(document.getElementById("id-curso-docente").value);
let txtDocDocumento = document.getElementById("doc-docente");
let txtDocEmail = document.getElementById("email-docente");
let txtDocTelefono = document.getElementById("telefono-docente");
let cboDocCondicion = document.getElementById("condicion-docente");
let cboDocNombre = document.getElementById("nombre-docente");
let txtDocCodigo = document.getElementById("codigo-docente");
let cboDocGrado = document.getElementById("grado-docente");

let btnGuardar = document.getElementById('btnGuardar');
let btnCerrar = document.getElementById('btnCerrar');
let btnCancelar = document.getElementById('btnCancelar');

// VARIABLES

let cgh_id = 0;
let cgh_codigo = '';

var listacursos = [];

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
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      let opciones = data;
      $('#cboUnidad').html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_programas() {
  let opcion = "get_cbo_programas";
  let sec_id = cboUnidad.value;
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
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
  let opcion = 'get_cursos_by_ciclo';
  let ciclo = cboCiclo.value;

  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&ciclo=" + ciclo,
    success: function (data) {
      objeto = JSON.parse(data);
      let opciones = objeto.cursos;
      cboCurso.disabled = false;
      if (objeto.has_data == 0) {
        cboCurso.disabled = true;
      }
      $('#cboCurso').html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_docentes() {
  let opcion = 'get_docentes';
  
  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      let opciones = data;
      $('#nombre-docente').html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

// FIN OBTENER COMBOS

// FUNCIONALIDADES

function empezarEditar(){
  
}

// OPERACIONES

function agregar() {
  let id = parseInt(cboCurso.value);
  let cursonombre = cboCurso.options[cboCurso.selectedIndex].text;
  let cursohoras = txtHoras.value;
  let fechas = txtFechas.value;
  if(cursoAgregado(id)){
    alert("Ya has agregado el curso");
    return;
  }
  if (cursonombre == "" || cursohoras == "" || fechas == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  let fechasagregar=  agregarFechas(fechas);
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
  let arrayFechas = fechas.split(",");
  let i = 0;
  let fechasdevolver = [];
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
  let curso = listacursos.find(cursoI => cursoI.index === indexb);
  $("#cboCurso").val(curso.index);
  $("#txtHoras").val(curso.horas);
  let fechasMostrar = curso.fechas.map(function (fecha) {
      var partes = fecha.fecha.split("/");
      return new Date(partes[2], partes[1] - 1, partes[0]);
  });
  $("#cursoEditar").val(indexb);
  $(".datepicker3").datepicker('setDates', fechasMostrar);
  btnAgregarCurso.disabled = true;
  btnGuardarCurso.disabled = false;
  btnCancelarEditar.disabled = false;
}

function eliminar(index){
  listacursos= listacursos.filter((item) => item.index != index);
  llenarTabla();
}

function guardar() {
  let index = parseInt(txtIdCursoEditar.value);
  let idNuevo = parseInt(cboCurso.value);
  let cursonombreN = cboCurso.options[cboCurso.selectedIndex].text;
  let cursohoras = txtHoras.value;
  let fechas = txtFechas.value;
  let fechasNuevas = agregarFechas(fechas);
  listacursos.find(cursoI => cursoI.index === index).curso = cursonombreN;
  listacursos.find(cursoI => cursoI.index === index).horas = cursohoras;
  listacursos.find(cursoI => cursoI.index === index).fechas = fechasNuevas;
  listacursos.find(cursoI => cursoI.index === index).index = idNuevo;
  limpiarInputs();
  llenarTabla();
  btnAgregarCurso.disabled = false;
  btnGuardarCurso.disabled = true;
  btnCancelarEditar.disabled = true;
}

function cancelar(){
  limpiarInputs();
  btnAgregarCurso.disabled = false;
  btnGuardarCurso.disabled = true;
  btnCancelarEditar.disabled = true;
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
  let id_curso_modal = txtIdModal;
  let doc_modal = txtDocDocumento.value;
  let email_modal = txtDocEmail.value;
  let telefono_modal = txtDocTelefono.value;
  let condicion_modal = cboDocCondicion.value;
  let nombre_docente_modal = cboDocNombre.value;
  let codigo_modal = txtDocCodigo.value;
  let grado_modal = cboDocGrado.value;
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
  let docente = listacursos.find(item => item.index === index).docente_principal;
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
    dropdownParent: $("#myModal"),
    placeholder: 'Selecciona un docente ...'
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
  if ($('#cboSemestre').val()==="" || $('#cboUnidad').val()==="" || $('#cboPrograma').val()==="" || $('#cboCiclo').val()==="") {
    alert('Llenar todos los campos');
    return
  }
  if (listacursos.length == 0) {
    alert('Agregar cursos a la carga horaria');
  } else if (listadocentes.length == 0) {
    alert('Agregar docentes a la carga horaria');
  }

  let opcion = "saveCargaHoraria";
  let p_cgh_id = cgh_id;
  let p_cgh_codigo = cgh_codigo;
  let sem_option = $('#cboSemestre option:selected');
  let p_sem_id = cboSemestre.value;
  let p_sem_codigo = sem_option.data("codigo");
  let p_sem_descripcion = sem_option.text();
  let sec_option = $('#cboUnidad option:selected'); 
  let p_sec_id = cboUnidad.value;
  let p_sec_descripcion = sec_option.text();
  let prg_option = $('#cboPrograma option:selected');
  let p_prg_id = cboPrograma.value;
  let p_prg_mencion = prg_option.text();
  let p_cgh_ciclo = cboCiclo.value;
  let p_cgh_estado = '0001';

  btnGuardar.disabled = true;
  btnCerrar.disabled = true;
  btnCancelar.disabled = true;

  $.ajax({
    type: "POST",
    url: "../../../carga_horaria/controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&p_cgh_id=" + p_cgh_id +
      "&p_cgh_codigo=" + p_cgh_codigo +
      "&p_sem_id=" + p_sem_id +
      "&p_sem_codigo=" + p_sem_codigo +
      "&p_sem_descripcion=" + p_sem_descripcion +
      "&p_sec_id=" + p_sec_id +
      "&p_sec_descripcion=" + p_sec_descripcion +
      "&p_prg_id=" + p_prg_id +
      "&p_prg_mencion=" + p_prg_mencion +
      "&p_cgh_ciclo=" + p_cgh_ciclo +
      "&p_cgh_estado=" + p_cgh_estado,
    success: function (data) {
      btnGuardar.disabled = false;
      btnCerrar.disabled = false;
      btnCancelar.disabled = false;
      objeto = JSON.parse(data);
      let opciones = objeto.cursos;
      cboCurso.disabled = false;
      if (objeto.has_data == 0) {
        cboCurso.disabled = true;
      }
      $('#cboCurso').html(opciones);
    },
    error: function (data) {
      btnBuscar.disabled = false;
      alert("Error al mostrar");
    },
  });
}

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  change_cbo_ciclo();
  get_docentes();

  cboSemestre.addEventListener("change", get_cbo_unidades);
  cboSemestre.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", change_cbo_ciclo);
  cboCiclo.addEventListener("change", buscar_cursos);
  btnGuardar.addEventListener("click", saveCargaHoraria);
}

// EVENTOS
window.addEventListener("load", load_document);
