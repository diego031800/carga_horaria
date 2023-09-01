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
let btnAgregarCursoModal = document.getElementById('btnAgregarCursoModal');
let txtIdCursoEditar = document.getElementById('cursoEditar');
let btnEditarCarga = document.getElementById('btneditarCargaHoraria');


// Docente modal

let txtIdModal = document.getElementById("id-curso-docente");
let txtDocDocumento = document.getElementById("doc-docente");
let txtDocEmail = document.getElementById("email-docente");
let txtDocTelefono = document.getElementById("telefono-docente");
let cboDocCondicion = document.getElementById("condicion-docente");
let cboDocNombre = document.getElementById("nombre-docente");
let txtDocCodigo = document.getElementById("codigo-docente");
let cboDocGrado = document.getElementById("grado-docente");
let cboDocGrupo = document.getElementById("cbo-grupodocente");
let tglDocSuplente = document.getElementById("tglSuplente");

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
      //cboCurso.disabled = false;
      btnEditarCarga.disabled = false;
      if (objeto.has_data == 0) {
        //cboCurso.disabled = true;
        btnEditarCarga.disabled = true;
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

// OPERACIONES

function abrirAgregarCurso(){
  $('#myModal-curso').fadeIn();
  txtIdCursoEditar.value = 0;
}

function accionBtnGuardarCurso(){
  if(txtIdCursoEditar.value == 0){
    agregar();
  }else{
    guardar();
  }
}

function agregar() {
  let id = parseInt(cboCurso.value);
  let cur_option = $('#cboCurso option:selected');
  let txtCurso = cur_option.data("nombre");
  let txtCursoCodigo = cur_option.data("codigo");
  let txtCursoCiclo = cur_option.data("ciclo");
  let txtCursoCreditos = cur_option.data("creditos");
  let cursohoras = txtHoras.value;
  let fechas = txtFechas.value;
  if(cursoAgregado(id)){
    alert("Ya has agregado el curso");
    return;
  }
  if (txtCurso == "" || cursohoras == "" || fechas == "") {
    alert("No deben haber campos vacíos");
    return;
  }
  let i = listacursos.length;
  let fechasagregar=  agregarFechas(fechas);
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
      grupos: [{id: 1, cod_docente: 0, nombre : 'Grupo A',docentes: []}]
    }
  );
  llenarTabla();
  limpiarInputs();
  $('#myModal-curso').fadeOut();
}

function guardar() {
  let index = parseInt(txtIdCursoEditar.value);
  let idNuevo = parseInt(cboCurso.value);
  let cur_option = $('#cboCurso option:selected');
  let txtCurso = cur_option.data("nombre");
  let txtCursoCodigo = cur_option.data("codigo");
  let txtCursoCiclo = cur_option.data("ciclo");
  let txtCursoCreditos = cur_option.data("creditos");
  let cursohoras = txtHoras.value;
  let fechas = txtFechas.value;
  let fechasNuevas = agregarFechas(fechas);
  listacursos.find(cursoI => cursoI.index === index).curso = txtCurso;
  listacursos.find(cursoI => cursoI.index === index).cur_codigo = txtCursoCodigo;
  listacursos.find(cursoI => cursoI.index === index).cur_ciclo = txtCursoCiclo;
  listacursos.find(cursoI => cursoI.index === index).cur_creditos = txtCursoCreditos;
  listacursos.find(cursoI => cursoI.index === index).horas = cursohoras;
  listacursos.find(cursoI => cursoI.index === index).fechas = fechasNuevas;
  listacursos.find(cursoI => cursoI.index === index).index = idNuevo;
  limpiarInputs();
  llenarTabla();
  $('#myModal-curso').fadeOut();
}

function editar(indexb) {
  $('#myModal-curso').fadeIn();
  let curso = listacursos.find(cursoI => cursoI.index === indexb);
  cboCurso.value = curso.index;
  txtHoras.value = curso.horas;
  var fechasMostrar = curso.fechas.map(function (fecha) {
      var partes = fecha.fecha.split("/");
      return new Date(partes[2], partes[1] - 1, partes[0]);
  });
  $("#cboCurso").val(indexb);
  txtIdCursoEditar.value = indexb;
  $(".datepicker3").datepicker('setDates', fechasMostrar);
}

function cursoAgregado(index){
  if(listacursos.find(cursoI => cursoI.index === index) != null && listacursos.find(cursoI => cursoI.index === index) != undefined){
    return true;
  }else{
    return false;
  }
}

function agregarGrupo(){
  let id_curso_modal = txtIdModal.value;
  listacursos.find(cursoI => cursoI.index == id_curso_modal).grupos.push(
    {id: 2, cod_docente: 0, nombre : 'Grupo B',docentes: []}
  );
  actualizarCboGrupoDoc(id_curso_modal);
  $("#btn-addGrupo").hide();
  $("#btn-deleteGrupo").show();
}

function eliminarGrupo(){
  let id_curso_modal = txtIdModal.value;
  listacursos.find(cursoI => cursoI.index == id_curso_modal).grupos.pop();
  actualizarCboGrupoDoc(id_curso_modal);
  $("#btn-addGrupo").show();
  $("#btn-deleteGrupo").hide();
}

function actualizarCboGrupoDoc(ind){
  $("#cbo-grupodocente").empty();
  let opciones = listacursos.find(cursoI => cursoI.index == ind).grupos;
  opciones.forEach(element => {
    $("#cbo-grupodocente").append('<option value="'+ element.id +'">'+element.nombre+'</option>')
  });
}

function agregarFechas(fechas) {
  let arrayFechas = fechas.split(",");
  let i = 0;
  let fechasdevolver = [];
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
  txtFechas.value ='';
  txtHoras.value ='';
  $("#cboCurso").val(null).trigger("change");
}

function eliminar(index){
  listacursos= listacursos.filter((item) => item.index != index);
  llenarTabla();
}

function llenarTabla() {
  $("#cursosTabla tbody").empty();
  if(listacursos.length ==0){
    $("#cursosTabla tbody").append('<tr><td class="text-center" colspan="6">Sin registros.</td></tr>');
    return;
  }
  listacursos.forEach((elementC) => {
    let stringG=elementC.grupos.length;
    fila =
    '<tr><td scope="row">' +
    elementC.curso +
    '</td><td><button class="btn btn-info" style="margin-right: 10px;" onClick="editar(' +
    elementC.index +
    ');">Editar</button><button class="btn btn-danger" onClick="eliminar('+
    elementC.index +
    ')";>Eliminar</button></td>' +
    '<td><table>'+stringG+'</table></td>' +
    '<td><button class="btn btn-danger" onClick="abrir_docente_modal('+
    elementC.index+
    ');">Ver</button></td></tr>';
    $("#cursosTabla tbody").append(fila);
  });
}

function actualizarDatosDocenteGrupo(){
  let id_curso_modal = txtIdModal.value;
  let id_grupo_docente = cboDocGrupo.value;
  let indxCurso = listacursos.findIndex(item => item.index == id_curso_modal);
  let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(item => item.id == id_grupo_docente);
  tglDocSuplente.checked = false;
  if(comprobarDocenteAsignado(id_curso_modal,id_grupo_docente,1)){
    let codDG = listacursos[indxCurso].grupos[indxGrupoCurso].docentes.find(item => item.titular == 1).doc_id;
    $("#nombre-docente").val(null).trigger("change");
    $("#nombre-docente").val(codDG).trigger("change");
  }else{
    $("#nombre-docente").val(null).trigger("change");
  }
  seleccionar_datos_docente();
}

function guardar_docente(){
  let id_curso_modal = txtIdModal.value;
  let id_grupo_docente = cboDocGrupo.value;
  let doc_modal = txtDocDocumento.value;
  let email_modal = txtDocEmail.value;
  let telefono_modal = txtDocTelefono.value;
  let condicion_modal = cboDocCondicion.value;
  let nombre_docente_modal = cboDocNombre.value;
  let doc_opcion = $('#nombre-docente option:selected');
  let txtDocente = doc_opcion.text();
  let codigo_modal = txtDocCodigo.value;
  let grado_modal = cboDocGrado.value;
  let indxCurso = listacursos.findIndex(item => item.index == id_curso_modal);
  let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(item => item.id == id_grupo_docente);
  let pos = !tglDocSuplente.checked ? 1:0;
  if(comprobarDocenteAsignado(id_curso_modal,id_grupo_docente,pos)){
    let indxDocente =listacursos[indxCurso].grupos[indxGrupoCurso].docentes.findIndex(item => item.titular == pos); 
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].doc_id = nombre_docente_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].docente = txtDocente
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].condicion = condicion_modal
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].grado = grado_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].codigo = codigo_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].dni = doc_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].correo = email_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].telefono = telefono_modal;
  }else{
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes.push({
      chd_id: 0,
      titular: pos,
      doc_id: nombre_docente_modal,
      docente: txtDocente,
      condicion: condicion_modal,
      grado: grado_modal,
      codigo: codigo_modal,
      dni: doc_modal,
      correo: email_modal,
      telefono: telefono_modal
    });
  }
  limpiarInputsModal();
  //document.getElementById('myModal').style.display = "none";
  llenarTabla();
}

function alternarDatosDoc(){
  let id_curso_modal = txtIdModal.value;
  let id_grupo_docente = cboDocGrupo.value;
  let indxCurso = listacursos.findIndex(item => item.index == id_curso_modal);
  let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(item => item.id == id_grupo_docente);
  let pos = !tglDocSuplente.checked ? 1:0;
  if(comprobarDocenteAsignado(id_curso_modal,id_grupo_docente,pos)){
    let codDG = listacursos[indxCurso].grupos[indxGrupoCurso].docentes.find(item => item.titular == pos).doc_id;
    $("#nombre-docente").val(null).trigger("change");
    $("#nombre-docente").val(codDG).trigger("change");
  }else{
    $("#nombre-docente").val(null).trigger("change");
  }
  seleccionar_datos_docente();
}

function comprobarDocenteAsignado(idRegistro, idGrupo, puesto){
  let grup = listacursos.find(item => item.index == idRegistro).grupos.find(item => item.id == idGrupo);
  if(grup.docentes.length != 0){
    let doc = grup.docentes.find(item => item.titular == puesto);
    if(doc != null && doc != undefined){
      return true;
    }else{
      return false;
    }
  }else{
    return false;
  }
}

function seleccionar_datos_docente() {
  let doc_opcion = $('#nombre-docente option:selected');
  let doc_documento = doc_opcion.data('documento');
  let doc_email = doc_opcion.data('email');
  let doc_codigo = doc_opcion.data('codigo');
  let doc_celular = doc_opcion.data('celular');
  $("#doc-docente").val(doc_documento);
  $("#email-docente").val(doc_email);
  $("#codigo-docente").val(doc_codigo);
  $("#telefono-docente").val(doc_celular);
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
  let docente = listacursos.find(item => item.index == index).grupos[0].docentes[0];
  let grupos = listacursos.find(item => item.index == index).grupos;
  $('#myModal').fadeIn();
  if (docente != null && docente !== undefined ) {
    $("#nombre-docente").val(docente.doc_id);
    $("#condicion-docente").val(docente.condicion);
    $("#grado-docente").val(docente.grado);
    $("#codigo-docente").val(docente.codigo);
    $("#doc-docente").val(docente.dni);
    $("#email-docente").val(docente.correo);
    $("#telefono-docente").val(docente.telefono);
  } else {
    limpiarInputsModal();
  }
  $("#id-curso-docente").val(index);
  $('#nombre-docente').select2({
    dropdownCssClass: "limitar-opciones",
    dropdownParent: $("#myModal"),
    placeholder: 'Selecciona un docente ...'
  });
  $('#nombre-docente').on('change', function() {
    seleccionar_datos_docente();
  });
  if(grupos.length == 1){
    $("#btn-addGrupo").show();
    $("#btn-deleteGrupo").hide();
  }else{
    $("#btn-addGrupo").hide();
    $("#btn-deleteGrupo").show();
  }
  actualizarCboGrupoDoc(index);
  actualizarDatosDocenteGrupo();
}

// Funcionalidades

function cancelarEditarCurso(){
  limpiarInputs();
  btnAgregarCurso.disabled = false;
  btnGuardarCurso.disabled = true;
  btnCancelarEditar.disabled = true;
  $("#cursoEditar").val("");
}

function camposUnidad(bol){
  cboSemestre.disabled = bol;
  cboUnidad.disabled =bol;
  cboPrograma.disabled = bol;
  cboCiclo.disabled = bol;
}

function camposCursos(bol){
  cboCurso.disabled = bol;
  btnAgregarCurso.disabled = bol;
}

function editarCarga(){
  let sem =cboSemestre.value;
  let unidad = cboUnidad.value;
  let programa = cboPrograma.value;
  let ciclo = cboCiclo.value;
  btnGuardar.disabled = false;
  btnCerrar.disabled = false;
  btnCancelar.disabled = false;
  camposCursos(false,2);
  camposUnidad(true);
  console.log(sem + " _ "+ unidad + " _ "+ programa + " _ "+ciclo);
  if( sem != "" && unidad != "" && programa != "" && ciclo != "" ){
    console.log("Editar" + unidad);
  }else{
    console.log("No pueden haber campos vacios");
  }
}

function cancelarEditarCarga(){
  listacursos =[]
  camposCursos(true,1);
  camposUnidad(false);
  llenarTabla();
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
      if (objeto.respuesta == 1) {
        alert(objeto.mensaje);
        location.href = 'verCargaHoraria.php';
      } else {
        alert(objeto.mensaje);
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
  camposCursos(true,1);
  btnGuardar.disabled = true;
  btnCerrar.disabled = true;
  btnCancelar.disabled = true;
  /* CAMPOS GENERALES */
  cboSemestre.addEventListener("change", get_cbo_unidades);
  cboSemestre.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", change_cbo_ciclo);
  cboCiclo.addEventListener("change", buscar_cursos);
  btnGuardar.addEventListener("click", saveCargaHoraria);
  cboDocGrupo.addEventListener("change",actualizarDatosDocenteGrupo);
  tglDocSuplente.addEventListener("change",alternarDatosDoc);
}

// EVENTOS
window.addEventListener("load", load_document);

// MODAL JS
document.getElementById('closeModal').addEventListener('click', function() {
  $('#myModal').fadeOut();
  limpiarInputsModal();
});

window.onclick = function(event) {
  if (event.target === document.getElementById('myModal')) {
    $('#myModal').fadeOut();
    limpiarInputsModal();
  }
}
window.onclick = function(event) {
  if (event.target === document.getElementById('myModal-curso')) {
    $('#myModal-curso').fadeOut();
  }
}
