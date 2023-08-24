// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
let cboCiclo = document.getElementById('cboCiclo');
let cboCurso = document.getElementById('cboCurso');
let btnGuardar = document.getElementById('btnGuardar');
let btnCerrar = document.getElementById('btnCerrar');
let btnCancelar = document.getElementById('btnCancelar');

let cgh_id = 0;
let cgh_codigo = '';

var listacursos = [];

// FUNCIONES
// INICIO OBTENER COMBOS
function get_cbo_semestres() {
  let opcion = "get_cbo_semestres";
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
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
    url: "../../controllers/main/CargaHorariaController.php",
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
    url: "../../controllers/main/CargaHorariaController.php",
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
    url: "../../controllers/main/CargaHorariaController.php",
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
    url: "../../controllers/main/CargaHorariaController.php",
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

function agregar() {
  var id = parseInt(cboCurso.value);
  let cur_option = $('#cboCurso option:selected');
  let txtCurso = cur_option.data("nombre");
  let txtCursoCodigo = cur_option.data("codigo");
  let txtCursoCiclo = cur_option.data("ciclo");
  let txtCursoCreditos = cur_option.data("creditos");
  var cursohoras = document.getElementById("cursoHoras").value;
  let fechas = document.getElementById("newTratFechaIni").value;
  if(cursoAgregado(id)){
    alert("Ya has agregado el curso");
    return;
  }
  if (txtCurso == "" || cursohoras == "" || fechas == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  let i = listacursos.length;
  var fechasagregar=  agregarFechas(fechas);
  listacursos.push(
    { 
      chc_id: 0,
      index: id, 
      curso: txtCurso, 
      cur_codigo: txtCursoCodigo,
      cur_ciclo: txtCursoCiclo, 
      cur_creditos: txtCursoCreditos,
      horas: cursohoras, 
      fechas: fechasagregar, 
      docentes: [],
    }
  );
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
    fechasdevolver.push(
      { 
        p_chf_id: 0,
        index: i, 
        fecha: element 
      }
    );
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
  $("#cboCurso").val(curso.index);
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
  var idNuevo = parseInt(cboCurso.value);
  var cboCursoN = cboCurso.options[cboCurso.selectedIndex].text;
  var cursohoras = document.getElementById("cursoHoras").value;
  var fechas = document.getElementById("newTratFechaIni").value;
  var fechasNuevas = agregarFechas(fechas);
  listacursos.find(cursoI => cursoI.index === index).curso = cboCursoN;
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
    let doc = elementC.docentes[0];
    if(doc == null){
      nombre = "Sin asignar docente";
    }else{
      nombre = doc.docente;
    }
    fila =
    '<tr><td scope="row">' +
    elementC.curso +
    "</td><td>" +
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
  let doc_opcion = $('#nombre-docente option:selected');
  let txtDocente = doc_opcion.text();
  var codigo_modal = document.getElementById("codigo-docente").value;
  var grado_modal = document.getElementById("grado-docente").value;
  if (listacursos.find(item => item.index === id_curso_modal).docentes.length != 0) {
    listacursos.find(item => item.index === id_curso_modal).docentes[0].doc_id = nombre_docente_modal;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].docente = txtDocente;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].condicion = condicion_modal;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].grado = grado_modal;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].codigo = codigo_modal;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].dni = doc_modal;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].correo = email_modal;
    listacursos.find(item => item.index === id_curso_modal).docentes[0].telefono = telefono_modal;
  }else{
    listacursos.find(item => item.index === id_curso_modal).docentes.push(
      {
        chd_id: 0,
        titular: 1,
        doc_id: nombre_docente_modal,
        docente: txtDocente,
        condicion: condicion_modal,
        grado: grado_modal,
        codigo: codigo_modal,
        dni: doc_modal,
        correo: email_modal,
        telefono: telefono_modal
      }
    );
  }
  limpiarInputsModal();
  document.getElementById('myModal').style.display = "none";
  llenarTabla();
}
//[{ index: 0, id :0, docente: "Profesor 1", condicion:"Invitado Nacional",grado:"dr", codigo:"64", dni:"74",correo:"gggg", telefono:"9"}]
function limpiarInputsModal(){
  $("#nombre-docente").val(null).trigger("change");
  $("#id-curso-docente").val("");
  $("#doc-docente").val("");
  $("#email-docente").val("");
  $("#codigo-docente").val("");
  $("#telefono-docente").val("");
}

function abrir_docente_modal(index){
  var docente = listacursos.find(item => item.index === index).docentes[0];
  if (docente != null && docente !== undefined ) {
    $("#nombre-docente").val(docente.doc_id);
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
  
  /* CURSOS */
  let p_cursos = JSON.stringify(listacursos);

  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
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
      "&p_cgh_estado=" + p_cgh_estado + 
      "&p_cursos=" + p_cursos,
    beforeSend: function() {
      btnGuardar.disabled = true;
      btnCerrar.disabled = true;
      btnCancelar.disabled = true;
    },
    success: function (data) {
      btnGuardar.disabled = false;
      btnCerrar.disabled = false;
      btnCancelar.disabled = false;
      objeto = JSON.parse(data);
      let respuesta = objeto[1];
      if (respuesta.respuesta == 1) {
        alert(respuesta.mensaje);
        location.href = 'verCargaHoraria.php';
      } else {
        alert(respuesta.mensaje);
      }
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
