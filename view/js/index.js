// Elementos HTML
let btnAtras = document.getElementById('btnAtras');

//   Unidades
let cboSemestre = document.getElementById("cboSemestre");
let cboUnidad = document.getElementById("cboUnidad");
let cboPrograma = document.getElementById("cboPrograma");

// Variables $_GET[]
let txtCgh_Id = document.getElementById("txtCgh_Id");
let txtCgc_Id = document.getElementById("txtCgc_Id");
let txtSem_id = document.getElementById("txtSem_id");
let txtSec_id = document.getElementById("txtSec_Id");

//   Curso
let cboCiclo = document.getElementById("cboCiclo");
let cboCurso = document.getElementById("cboCurso");
let txtHoras = document.getElementById("txtHoras");
let txtFechas = document.getElementById("newTratFechaIni");
let btnGuardarCurso = document.getElementById("btnGuardarCurso");
let txtIdCursoEditar = document.getElementById("cursoEditar");
let btnEditarCarga = document.getElementById("btneditarCargaHoraria");
let cboGrupoCurso = document.getElementById("cbo-grupo");

// Grupo
let txtIdCursoGrupo = document.getElementById("cursoIdModalGrupo");
let txtTituloModalGrupo = document.getElementById("title-Grupo");

// Docente modal

let txtTituloModalDocente = document.getElementById("title-Docente");
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

let btnGuardar = document.getElementById("btnGuardar");
let btnCancelar = document.getElementById("btnCancelar");

// VARIABLES
let cgh_id = 0;
let chu_id = 0;
let chp_id = 0;
let cgh_codigo = "";

var listacursos = [];
let stdEditarCarga = 0;
let arrayEliminadoC = [];
let arrayEliminadoG = [];
let arrayEliminadoD = [];
let arrayEliminadoF = [];
// FUNCIONES
// NAVEGACION
/* FUNCION PARA IR ATRAS */
function back() {
  window.history.back();
}

// INICIO OBTENER COMBOS
function get_carga_horaria_by_id() {
  let opcion = "get_carga_horaria_by_id";
  let p_cgh_id = txtCgh_Id.value;
  let p_cgc_id = txtCgc_Id.value;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&p_cgh_id=" + p_cgh_id +
      "&p_cgc_id=" + p_cgc_id,
    success: function (data) {
      let respuesta = JSON.parse(data);
      setDatosUnidadSem(respuesta);
    },
    error: function (data) {
      alert("Error al mostrar: " + data);
    },
  });
}

function get_cbo_semestres() {
  return new Promise(function (resolve, reject) {
    let opcion = "get_cbo_semestres";
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion,
      success: function (data) {
        let opciones = data;
        $("#cboSemestre").html(opciones);
        resolve();
      },
      error: function (data) {
        reject("Error al mostrar: " + data);
      },
    });
  });
}

function get_cbo_unidades() {
  return new Promise(function (resolve, reject) {
    let opcion = "get_cbo_unidades";
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion,
      success: function (data) {
        let opciones = data;
        $("#cboUnidad").html(opciones);
        resolve();
      },
      error: function (data) {
        reject("Error al mostrar");
      },
    });
  });
}

function get_cbo_programas() {
  let opcion = "get_cbo_programas";
  let sec_id = cboUnidad.value;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion + "&sec_id=" + sec_id,
    success: function (data) {
      objeto = JSON.parse(data);
      let opciones = objeto.programas;
      cboPrograma.disabled = false;
      if (objeto.has_data == 0) {
        cboPrograma.disabled = true;
      }
      $("#cboPrograma").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_programasPromesa() {
  return new Promise(function (resolve, reject) {
    let opcion = "get_cbo_programas";
    let sec_id = cboUnidad.value;

    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion + "&sec_id=" + sec_id,
      success: function (data) {
        objeto = JSON.parse(data);
        let opciones = objeto.programas;
        cboPrograma.disabled = false;
        if (objeto.has_data == 0) {
          cboPrograma.disabled = true;
        }
        $("#cboPrograma").html(opciones);
        resolve(); // Resuelve la promesa cuando los datos estén disponibles
      },
      error: function (data) {
        reject("Error al mostrar"); // Rechaza la promesa en caso de error
      },
    });
  });
}

function change_cbo_ciclo() {
  let unidad = $("#cboUnidad option[value='" + cboUnidad.value + "']").text();
  if (unidad == "DOCTORADO") {
    $("#cboCiclo").html(
      '<option value="">Selecciona un ciclo ...</option>' +
      '<option value="1">1</option>' +
      '<option value="2">2</option>' +
      '<option value="3">3</option>' +
      '<option value="4">4</option>' +
      '<option value="5">5</option>' +
      '<option value="6">6</option>'
    );
  } else {
    $("#cboCiclo").html(
      '<option value="">Selecciona un ciclo ...</option>' +
      '<option value="1">1</option>' +
      '<option value="2">2</option>' +
      '<option value="3">3</option>' +
      '<option value="4">4</option>'
    );
  }
}

function buscar_cursos() {
  let opcion = "get_cursos_by_ciclo";
  let ciclo = cboCiclo.value;

  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion + "&ciclo=" + ciclo,
    success: function (data) {
      objeto = JSON.parse(data);
      let opciones = objeto.cursos;
      //cboCurso.disabled = false;
      btnEditarCarga.disabled = false;
      if (objeto.has_data == 0) {
        //cboCurso.disabled = true;
        btnEditarCarga.disabled = true;
      }
      $("#cboCurso").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function buscar_cursosPromesa() {
  return new Promise(function (resolve, reject) {
    let opcion = "get_cursos_by_ciclo";
    let ciclo = cboCiclo.value;

    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion + "&ciclo=" + ciclo,
      success: function (data) {
        objeto = JSON.parse(data);
        let opciones = objeto.cursos;
        //cboCurso.disabled = false;
        btnEditarCarga.disabled = false;
        if (objeto.has_data == 0) {
          //cboCurso.disabled = true;
          btnEditarCarga.disabled = true;
        }
        $("#cboCurso").html(opciones);
        resolve();
      },
      error: function (data) {
        reject("Error al mostrar");
      },
    });
  });
}

function get_docentes() {
  let opcion = "get_docentes";

  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      let opciones = data;
      $("#nombre-docente").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

// FIN OBTENER COMBOS

// OPERACIONES

function abrirAgregarCurso() {
  limpiarInputs();
  $("#myModal-curso").fadeIn();
  txtIdCursoEditar.value = 0;
}

function accionBtnGuardarCurso() {
  if (txtIdCursoEditar.value == 0) {
    agregar();
  } else {
    guardar();
  }
}

function agregar() {
  let id = parseInt(cboCurso.value);
  let cur_option = $("#cboCurso option:selected");
  let txtCurso = cur_option.data("nombre");
  let txtCursoCodigo = cur_option.data("codigo");
  let txtCursoCiclo = cur_option.data("ciclo");
  let txtCursoCreditos = cur_option.data("creditos");
  let txtCursoTipo = cur_option.data("tipo");
  let txtCursoCalidad = cur_option.data("calidad");
  if (cboCurso.value == '' || txtHoras.value == "") {
    toastr["error"]("No deben haber campos vacíos", "Agregar curso");
    return;
  }
  let cursohoras = parseInt(txtHoras.value);
  if (cursoAgregado(id, 0, 0) || validarHoras(cursohoras)) {
    return;
  }
  listacursos.push({
    chc_id: 0,
    index: id,
    curso: txtCurso,
    cur_codigo: txtCursoCodigo,
    cur_ciclo: txtCursoCiclo,
    cur_creditos: txtCursoCreditos,
    cur_tipo: ("0000" + txtCursoTipo).slice(-4),
    cur_calidad: ("0000" + txtCursoCalidad).slice(-4),
    horas: cursohoras,
    grupos: [{ ccg_id: 0, id: 1, nombre: "Grupo A", docentes: [], fechas: [] }],
  });
  llenarTabla();
  limpiarInputs();
  $("#myModal-curso").fadeOut();
  toastr["success"]("El curso se ha agregado con éxito", "Agregar curso");
}

function actualizarCboGrupoCurso(ind) {
  $("#cbo-grupo").empty();
  let opciones = listacursos.find((cursoI) => cursoI.index == ind).grupos;
  opciones.forEach((element) => {
    $("#cbo-grupo").append(
      '<option value="' + element.id + '">' + element.nombre + "</option>"
    );
  });
}

function agregarGrupo() {
  let id_curso_modal = txtIdCursoGrupo.value;
  listacursos
    .find((cursoI) => cursoI.index == id_curso_modal)
    .grupos.push({
      ccg_id: 0,
      id: 2,
      nombre: "Grupo B",
      docentes: [],
      fechas: [],
      horas: 0,
    });
  actualizarCboGrupoCurso(id_curso_modal);
  toastr["success"]("El grupo se ha agregado con éxito", "Agregar grupo");
  $("#btn-addGrupo").hide();
  $("#btn-deleteGrupo").show();
  llenarTabla();
}

function eliminarGrupo() {
  if (confirm('Se eliminará el grupo B ¿está de acuerdo?')) {
    let id_curso_modal = txtIdCursoGrupo.value;
    if (stdEditarCarga == 1) {
      grupo = listacursos.find((cursoI) => cursoI.index == id_curso_modal).grupos[1];
      if (grupo.ccg_id != 0) {
        arrayEliminadoG.push(grupo);
      }
    }
    listacursos.find((cursoI) => cursoI.index == id_curso_modal).grupos.pop();
    actualizarCboGrupoCurso(id_curso_modal);
    alternarDatosGrupo();
    $("#btn-addGrupo").show();
    $("#btn-deleteGrupo").hide();
    toastr["warning"]("El grupo se ha eliminado con éxito", "Eliminar grupo");
    llenarTabla();
  }
}

function guardarDatosGrupo() {
  let id = parseInt(txtIdCursoGrupo.value);
  let fechas = txtFechas.value;
  let indxC = listacursos.findIndex((item) => item.index == id);
  let id_grupo_docente = cboGrupoCurso.value;
  let indxGrupoCurso = listacursos[indxC].grupos.findIndex(
    (item) => item.id == id_grupo_docente
  );
  if (fechas == "") {
    toastr["error"]("No deben haber campos vacíos", "Guardar datos grupo");
    return;
  }
  let fechasagregar = agregarFechas(fechas);
  if (stdEditarCarga = 0) {
    listacursos[indxC].grupos[indxGrupoCurso].fechas = fechasagregar;
  } else {
    if (listacursos[indxC].grupos.ccg_id != 0) {
      if (listacursos[indxC].grupos[indxGrupoCurso].fechas != null || listacursos[indxC].grupos[indxGrupoCurso].fechas != undefined) {
        if (listacursos[indxC].grupos[indxGrupoCurso].fechas[0].cgf_id != 0) {
          fechasEdicion = comprobarfechas(fechasagregar, listacursos[indxC].grupos[indxGrupoCurso].fechas, listacursos[indxC].grupos[indxGrupoCurso].ccg_id);
          listacursos[indxC].grupos[indxGrupoCurso].fechas = fechasEdicion;
        } else {
          listacursos[indxC].grupos[indxGrupoCurso].fechas = fechasagregar;
        }
      } else {
        listacursos[indxC].grupos[indxGrupoCurso].fechas = fechasagregar;
      }
    } else {
      listacursos[indxC].grupos[indxGrupoCurso].fechas = fechasagregar;
    }
  }
  toastr["success"](
    "Datos del grupo guardados con éxito",
    "Guardar datos grupo"
  );
}

function alternarDatosGrupo() {
  let idGrupo = cboGrupoCurso.value;
  let index = parseInt(txtIdCursoGrupo.value);
  let grupo = listacursos
    .find((it) => it.index == index)
    .grupos.find((it) => it.id == idGrupo);
  if (grupo.fechas.length != 0) {
    var fechasMostrar = grupo.fechas.map(function (fecha) {
      var partes = fecha.fecha.split("/");
      return new Date(partes[2], partes[1] - 1, partes[0]);
    });
    $(".datepicker3").datepicker("setDates", fechasMostrar);
  } else {
    $(".datepicker3").datepicker("clearDates");
  }
}
/* Guarda los nuevos datos de un curso en el array */
function guardar() {
  let index = parseInt(txtIdCursoEditar.value);
  let idNuevo = parseInt(cboCurso.value);
  let cur_option = $("#cboCurso option:selected");
  let txtCurso = cur_option.data("nombre");
  let txtCursoCodigo = cur_option.data("codigo");
  let txtCursoCiclo = cur_option.data("ciclo");
  let txtCursoCreditos = cur_option.data("creditos");
  let txtCursoTipo = cur_option.data("tipo");
  let txtCursoCalidad = cur_option.data("calidad");
  if (txtCurso == "" || txtHoras.value == "") {
    toastr["error"]("No deben haber campos vacíos", "Agregar curso");
    return;
  }
  let cursohoras = parseInt(txtHoras.value);
  if (cursoAgregado(index, 1, idNuevo) || validarHoras(cursohoras)) {
    return;
  }
  let idArray = listacursos.findIndex((cursoI) => cursoI.index === index);
  listacursos[idArray].curso = txtCurso;
  listacursos[idArray].cur_codigo = txtCursoCodigo;
  listacursos[idArray].cur_ciclo = txtCursoCiclo;
  listacursos[idArray].cur_creditos = txtCursoCreditos;
  listacursos[idArray].cur_tipo = ("0000" + txtCursoTipo).slice(-4);
  listacursos[idArray].cur_calidad = ("0000" + txtCursoCalidad).slice(-4);
  listacursos[idArray].index = idNuevo;
  listacursos[idArray].horas = cursohoras;
  llenarTabla();
  limpiarInputs();
  $("#myModal-curso").fadeOut();
  toastr["success"]("El curso se ha guardado con éxito", "Agregar curso");
}

function abrir_grupo_modal(idCurso) {
  let curso = listacursos.find((cursoI) => cursoI.index === idCurso);
  txtTituloModalGrupo.textContent = "REGISTRAR GRUPOS PARA EL CURSO: " + curso.curso;
  $("#myModal-grupo").fadeIn();
  if (curso.grupos.length == 1) {
    $("#btn-addGrupo").show();
    $("#btn-deleteGrupo").hide();
  } else {
    $("#btn-addGrupo").hide();
    $("#btn-deleteGrupo").show();
  }
  txtIdCursoGrupo.value = idCurso;
  actualizarCboGrupoCurso(idCurso);
  alternarDatosGrupo();
}

/* Abre el modal de curso, con los datos del curso para editar */
function editar(indexb) {
  $("#myModal-curso").fadeIn();
  let curso = listacursos.find((cursoI) => cursoI.index === indexb);
  txtHoras.value = curso.horas;
  $("#cboCurso").val(indexb).trigger("change");
  txtIdCursoEditar.value = indexb;
}

/* Valida que el curso que se va a agregar no esté en registrado y 
si se edita, evita que no se guarde un curso ya guardado y que si es el mismo no haya conflicto */
function cursoAgregado(index, accion, indexnuevo) {
  if (accion == 0) {
    if (
      listacursos.find((cursoI) => cursoI.index === index) != null &&
      listacursos.find((cursoI) => cursoI.index === index) != undefined
    ) {
      toastr["warning"]("Ya has agregador el curso", "Agregar curso");
      return true;
    } else {
      return false;
    }
  } else {
    if (indexnuevo == index) {
      return false;
    } else {
      if (
        listacursos.find((cursoI) => cursoI.index === indexnuevo) != null &&
        listacursos.find((cursoI) => cursoI.index === indexnuevo) != undefined
      ) {
        toastr["warning"]("Ya has agregador el curso", "Agregar curso");
        return true;
      } else {
        return false;
      }
    }
  }
}

/* Valida que las horas no sean negativas */
function validarHoras(int) {
  if (int < 0) {
    toastr["error"]("Número de horas invalidas", "Agregar curso");
    return true;
  } else {
    return false;
  }
}

/* Poner los grupos de un curso en el cbo del modal de grupos */
function actualizarCboGrupoDoc(ind) {
  $("#cbo-grupodocente").empty();
  let opciones = listacursos.find((cursoI) => cursoI.index == ind).grupos;
  opciones.forEach((element) => {
    $("#cbo-grupodocente").append(
      '<option value="' + element.id + '">' + element.nombre + "</option>"
    );
  });
}

/* Genera un array segun la fechas registradas */
function agregarFechas(fechas) {
  let arrayFechas = fechas.split(",");
  let i = 1;
  let fechasdevolver = [];
  arrayFechas.forEach((element) => {
    i += 1;
    fechasdevolver.push({
      cgf_id: 0,
      index: i,
      fecha: element,
      ccg_id: 0
    });
  });
  return fechasdevolver;
}

function comprobarfechas(fechasNuevas, fechasGuardadas, ccg) {
  fechasGuardadas.forEach(element => {
    if (fechasNuevas.findIndex((item) => item.fecha === element.fecha) == -1) {
      element.fecha = '';
    }
  });
  fechasNuevas.forEach(element => {
    if (fechasGuardadas.findIndex((item) => item.fecha === element.fecha) == -1) {
      element.ccg_id = ccg;
      fechasGuardadas.push(element);
    }
  });
  return fechasGuardadas;
}

function limpiarInputs() {
  txtHoras.value = "";
  $("#cboCurso").val(null).trigger("change");
}

function eliminar(index) {
  if (confirm('¿Está seguro que quiere borrar este curso?')) {
    if (stdEditarCarga == 1) {
      curso = listacursos.find((item) => item.index == index);
      if(curso.chc_id != 0){
        arrayEliminadoC.push(curso);
      }
    }
    listacursos = listacursos.filter((item) => item.index != index);
    llenarTabla();
    toastr["warning"]("El curso se ha eliminado con éxito", "Eliminar curso");
  }
}


/* Actualiza los datos de los cursos en la tabla */
function llenarTabla() {
  $("#cursosTabla tbody").empty();
  if (listacursos.length == 0) {
    $("#cursosTabla tbody").append(
      '<tr><td class="text-center" colspan="6">Sin registros.</td></tr>'
    );
    return;
  }
  listacursos.forEach((elementC) => {
    let stringG = elementC.grupos.length;
    let acciones = menuAcciones(elementC.index);
    fila =
      '<tr><td scope="row">' +
      acciones +
      '</td><td>' +
      elementC.curso +
      "</td><td>" +
      stringG +
      '</td><td>' +
      '<button class="btn btn-dark" data-bs-toggle="tooltip" title="Asignar docentes a los grupos" onClick="abrir_docente_modal(' +
      elementC.index +
      ');"><i class="fa fa-user"></i> Abrir</button>' +
      '</td><td>' +
      '<button class="btn btn-secondary" data-bs-toggle="tooltip" title="Registrar fechas y agregar grupo" onClick="abrir_grupo_modal(' +
      elementC.index +
      ');"><i class="fa fa-group"></i> Abrir</button>' +
      '</td></tr>';
    $("#cursosTabla tbody").append(fila);
  });
  $('[data-bs-toggle="tooltip"]').tooltip();
}

/* Genera el menú desplegable de acciones para cada curso */
function menuAcciones(id) {
  let string =
    '<button class="btn btn-primary dropdown-toggle" data-bs-toggle="tooltip" title="Acciones del curso, editar o eliminar" type="button" data-toggle="dropdown" aria-expanded="false">' +
    'Acciones</button>' +
    '<div  class="dropdown-menu">' +
    '<button class="dropdown-item" onClick="editar(' + id + ');"><i class="fa fa-pencil-square-o text-primary"></i> Editar curso</button>' +
    '<button class="dropdown-item" onClick="eliminar(' + id + ');"><i class="fa fa-trash-o text-danger"></i> Eliminar curso</button>' +
    '</div>';
  return string;
}

function actualizarDatosDocenteGrupo() {
  let id_curso_modal = txtIdModal.value;
  let id_grupo_docente = cboDocGrupo.value;
  let indxCurso = listacursos.findIndex((item) => item.index == id_curso_modal);
  let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(
    (item) => item.id == id_grupo_docente
  );
  tglDocSuplente.checked = false;
  if (comprobarDocenteAsignado(id_curso_modal, id_grupo_docente, 1)) {
    let codDG = listacursos[indxCurso].grupos[indxGrupoCurso].docentes.find(
      (item) => item.titular == 1
    ).doc_id;
    $("#nombre-docente").val(null).trigger("change");
    $("#nombre-docente").val(codDG).trigger("change");
  } else {
    $("#nombre-docente").val(null).trigger("change");
  }
  seleccionar_datos_docente();
}

function guardar_docente() {
  let id_curso_modal = txtIdModal.value;
  let id_grupo_docente = cboDocGrupo.value;
  let doc_modal = txtDocDocumento.value;
  let email_modal = txtDocEmail.value;
  let telefono_modal = txtDocTelefono.value;
  let condicion_modal = cboDocCondicion.value;
  let nombre_docente_modal = cboDocNombre.value;
  let doc_opcion = $("#nombre-docente option:selected");
  let txtDocente = doc_opcion.text();
  let codigo_modal = txtDocCodigo.value;
  let grado_modal = cboDocGrado.value;
  let indxCurso = listacursos.findIndex((item) => item.index == id_curso_modal);
  let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(
    (item) => item.id == id_grupo_docente
  );
  let pos = !tglDocSuplente.checked ? 1 : 0;
  let mensaje =
    pos == 1
      ? "El docente titular se ha asignado con éxito"
      : "El docente suplente se ha asignado con éxito";
  if (comprobarDocenteAsignado(id_curso_modal, id_grupo_docente, pos)) {
    let indxDocente = listacursos[indxCurso].grupos[
      indxGrupoCurso
    ].docentes.findIndex((item) => item.titular == pos);
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].doc_id =
      nombre_docente_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[
      indxDocente
    ].docente = txtDocente;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[
      indxDocente
    ].condicion = condicion_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].grado =
      grado_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].codigo =
      codigo_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].dni =
      doc_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente].correo =
      email_modal;
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes[
      indxDocente
    ].telefono = telefono_modal;
  } else {
    listacursos[indxCurso].grupos[indxGrupoCurso].docentes.push({
      cgd_id: 0,
      titular: pos,
      doc_id: nombre_docente_modal,
      docente: txtDocente,
      condicion: condicion_modal,
      grado: grado_modal,
      codigo: codigo_modal,
      dni: doc_modal,
      correo: email_modal,
      telefono: telefono_modal,
    });
  }
  toastr["success"](mensaje, "Docente asignado");
  llenarTabla();
}

function eliminarDocente() {
  if (confirm('¿Está seguro que quiere borrar este curso?')) {
    let id_curso_modal = txtIdModal.value;
    let id_grupo_docente = cboDocGrupo.value;
    let pos = !tglDocSuplente.checked ? 1 : 0;
    let mensaje =
      pos == 1
        ? "El docente titular se ha eliminado con éxito"
        : "El docente suplente se ha eliminado con éxito";
    let indxCurso = listacursos.findIndex((item) => item.index == id_curso_modal);
    let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(
      (item) => item.id == id_grupo_docente
    );
    let indxDocente = listacursos[indxCurso].grupos[
      indxGrupoCurso
    ].docentes.findIndex((item) => item.titular == pos);
    if (comprobarDocenteAsignado(id_curso_modal, id_grupo_docente, pos)) {
      if (stdEditarCarga == 1) {
        arrayEliminadoD.push(listacursos[indxCurso].grupos[indxGrupoCurso].docentes[indxDocente]);
      }
      listacursos[indxCurso].grupos[indxGrupoCurso].docentes.splice(
        indxDocente,
        1
      );
      $("#nombre-docente").val(null).trigger("change");
      seleccionar_datos_docente();
      toastr["warning"](mensaje, "Eliminar Docente");
    } else {
      toastr["error"](
        "El docente que estás tratando de eliminar, no existe",
        "Eliminar Docente"
      );
    }
  }
}


/* Cambiar los datos de los docentes, según el grupo que se selecciona */
function alternarDatosDoc() {
  let id_curso_modal = txtIdModal.value;
  let id_grupo_docente = cboDocGrupo.value;
  let indxCurso = listacursos.findIndex((item) => item.index == id_curso_modal);
  let indxGrupoCurso = listacursos[indxCurso].grupos.findIndex(
    (item) => item.id == id_grupo_docente
  );
  let pos = !tglDocSuplente.checked ? 1 : 0;
  if (comprobarDocenteAsignado(id_curso_modal, id_grupo_docente, pos)) {
    let codDG = listacursos[indxCurso].grupos[indxGrupoCurso].docentes.find(
      (item) => item.titular == pos
    ).doc_id;
    $("#nombre-docente").val(null).trigger("change");
    $("#nombre-docente").val(codDG).trigger("change");
  } else {
    $("#nombre-docente").val(null).trigger("change");
  }
  seleccionar_datos_docente();
}

function comprobarDocenteAsignado(idRegistro, idGrupo, puesto) {
  let grup = listacursos
    .find((item) => item.index == idRegistro)
    .grupos.find((item) => item.id == idGrupo);
  if (grup.docentes.length != 0) {
    let doc = grup.docentes.find((item) => item.titular == puesto);
    if (doc != null && doc != undefined) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

function seleccionar_datos_docente() {
  let doc_opcion = $("#nombre-docente option:selected");
  let doc_documento = doc_opcion.data("documento");
  let doc_email = doc_opcion.data("email");
  let doc_codigo = doc_opcion.data("codigo");
  let doc_celular = doc_opcion.data("celular");
  $("#doc-docente").val(doc_documento);
  $("#email-docente").val(doc_email);
  $("#codigo-docente").val(doc_codigo);
  $("#telefono-docente").val(doc_celular);
}

//[{ index: 0, id :0, docente: "Profesor 1", condicion:"Invitado Nacional",grado:"dr", codigo:"64", dni:"74",correo:"gggg", telefono:"9"}]
function limpiarInputsModal() {
  $("#nombre-docente").val(null).trigger("change");
  $("#id-curso-docente").val("");
  $("#doc-docente").val("");
  $("#email-docente").val("");
  $("#codigo-docente").val("");
  $("#telefono-docente").val("");
}

function abrir_docente_modal(index) {
  let curso = listacursos.find((cursoI) => cursoI.index === index);
  txtTituloModalDocente.textContent = "ASIGNANDO DOCENTES PARA LOS GRUPOS DEL CURSO: " + curso.curso;
  let docente = listacursos.find((item) => item.index == index).grupos[0]
    .docentes[0];
  //let grupos = listacursos.find((item) => item.index == index).grupos;
  $("#myModal-docente").fadeIn();
  if (docente != null && docente !== undefined) {
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
  $("#nombre-docente").select2({
    dropdownCssClass: "limitar-opciones",
    dropdownParent: $("#myModal-docente"),
    placeholder: "Selecciona un docente ...",
  });
  $("#nombre-docente").on("change", function () {
    seleccionar_datos_docente();
  });
  toastr["info"](
    'Para ver y/o agregar los datos del docente suplente, active la opcion que dice: "Agregar docente suplente" ',
    "Asignar docente"
  );
  actualizarCboGrupoDoc(index);
  actualizarDatosDocenteGrupo();
}

/* Cargar datos al entrar como "Editar" */

async function setDatosUnidadSem(data) {
  $("#cboSemestre").val(data[0].sem_id).trigger("change");
  $("#cboUnidad").val(data[0].sec_id).trigger("change");
  await get_cbo_programasPromesa();
  $("#cboPrograma").val(data[0].prg_id).trigger("change");
  $("#cboCiclo").val(data[0].ciclo).trigger("change");
  await buscar_cursosPromesa();
  cgh_id = data[0].cgh_id;
  llenarListaCursos(data);
  camposUnidad(true);
  camposCursos(false);
  btnGuardar.disabled = false;
}

function llenarListaCursos(data) {
  let conversorCursos = Object.values(data[0].cursos);
  conversorCursos.forEach(element => {
    let arrayG = []
    let conversorGrupos = Object.values(element.grupos);
    //Convertir los grupos para los cursos
    conversorGrupos.forEach(elementG => {
      let arrayF = []
      let conversorFechas = Object.values(elementG.fechas);
      let arrayD = []
      let conversorDocentes = Object.values(elementG.docentes);
      // Convertir las fechas para los grupos
      conversorFechas.forEach(elementF => {
        fecha = {
          index: parseInt(elementF.cgf_id),
          cgf_id: parseInt(elementF.cgf_id),
          ccg_id: parseInt(elementF.ccg_id),
          fecha: convertirFecha(elementF.fecha)
        };
        arrayF.push(fecha);
      });
      // Convertir los docentes para los grupos
      conversorDocentes.forEach(elementD => {
        docente = {
          ccg_id: parseInt(elementD.ccg_id),
          codigo: elementD.doc_codigo,
          condicion: elementD.doc_condicion,
          correo: elementD.doc_email,
          dni: elementD.doc_documento,
          doc_id: elementD.doc_id,
          docente: elementD.doc_nombres,
          telefono: elementD.doc_celular,
          titular: elementD.titular
        }
        arrayD.push(docente);
      });
      nombreG = elementG.grupo == 1 ? 'Grupo A' : 'Grupo B';
      itemGNuevo = {
        ccg_id: parseInt(elementG.ccg_id),
        docentes: arrayD,
        fechas: arrayF,
        id: elementG.grupo,
        nombre: nombreG
      };
      arrayG.push(itemGNuevo);
    }
    );
    itemNuevo = {
      chc_id: parseInt(element.chc_id),
      cur_calidad: element.cur_calidad,
      cur_ciclo: element.cur_ciclo,
      cur_codigo: element.cur_codigo,
      cur_creditos: element.cur_creditos,
      cur_tipo: element.cur_calidad,
      curso: element.curso,
      grupos: arrayG,
      horas: parseInt(element.chc_horas),
      index: parseInt(element.cur_id)
    };
    listacursos.push(itemNuevo);
  });
  llenarTabla();
}

// Funcionalidades
function convertirFecha(fechaString) {
  // Dividir la cadena de fecha en partes
  const partes = fechaString.split("-");

  // Obtener el día, mes y año
  const año = partes[0];
  const mes = partes[1];
  const día = partes[2];

  // Crear la nueva cadena de fecha en el formato deseado
  const nuevaFecha = `${día}/${mes}/${año}`;
  return nuevaFecha;
}

/* Habilitar o deshabilitar los campos de la unidad */
function camposUnidad(bol) {
  cboSemestre.disabled = bol;
  cboUnidad.disabled = bol;
  cboPrograma.disabled = bol;
  cboCiclo.disabled = bol;
}

/* Habilitar o deshabilitar los campos de los cursos */
function camposCursos(bol) {
  cboCurso.disabled = bol;
  btnAgregarCurso.disabled = bol;
}
/* Botón de confirmar carga horaria */
function editarCarga() {
  let sem = cboSemestre.value;
  let unidad = cboUnidad.value;
  let programa = cboPrograma.value;
  let ciclo = cboCiclo.value;
  console.log(sem + " _ " + unidad + " _ " + programa + " _ " + ciclo);
  if (sem != "" && unidad != "" && programa != "" && ciclo != "") {
    btnGuardar.disabled = false;
    camposCursos(false, 2);
    camposUnidad(true);
    $("#btnCancelar").show();
    $("#btneditarCargaHoraria").hide();
  } else {
    toastr["error"]("No pueden haber campos vacíos", "Confirmar Editar Carga");
  }
}
/*  */
function cancelarEditarCarga() {
  listacursos = [];
  camposCursos(true, 1);
  camposUnidad(false);
  llenarTabla();
  $("#btnCancelar").hide();
  $("#btneditarCargaHoraria").show();
}

/* GUARDAR CARGA HORARIA */
function saveCargaHoraria() {
  let valido = validarCursos();
  if (valido) {
    let opcion = "saveCargaHoraria";
    let p_cgh_id = cgh_id;
    let p_cgh_codigo = cgh_codigo;
    let sem_option = $("#cboSemestre option:selected");
    let p_sem_id = cboSemestre.value;
    let p_sem_codigo = sem_option.data("codigo");
    let p_sem_descripcion = sem_option.text();
    let p_chu_id = chu_id;
    let sec_option = $("#cboUnidad option:selected");
    let p_sec_id = cboUnidad.value;
    let p_sec_descripcion = sec_option.text();
    let p_chp_id = chp_id;
    let prg_option = $("#cboPrograma option:selected");
    let p_prg_id = cboPrograma.value;
    let p_prg_mencion = prg_option.text();
    let p_cgh_ciclo = cboCiclo.value;
    let p_cgh_estado = "0001";

    /* CURSOS */
    let p_cursos = JSON.stringify(listacursos);

    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data:
        "opcion=" +
        opcion +
        "&p_cgh_id=" +
        p_cgh_id +
        "&p_cgh_codigo=" +
        p_cgh_codigo +
        "&p_sem_id=" +
        p_sem_id +
        "&p_sem_codigo=" +
        p_sem_codigo +
        "&p_sem_descripcion=" +
        p_sem_descripcion +
        "&p_chu_id=" +
        p_chu_id +
        "&p_sec_id=" +
        p_sec_id +
        "&p_sec_descripcion=" +
        p_sec_descripcion +
        "&p_chp_id=" +
        p_chp_id +
        "&p_prg_id=" +
        p_prg_id +
        "&p_prg_mencion=" +
        p_prg_mencion +
        "&p_cgh_ciclo=" +
        p_cgh_ciclo +
        "&p_cgh_estado=" +
        p_cgh_estado +
        "&p_cursos=" +
        p_cursos,
      beforeSend: function () {
        btnGuardar.disabled = true;
      },
      success: function (data) {
        objeto = JSON.parse(data);
        if (objeto.respuesta == 1) {
          toastr["success"](objeto.mensaje, "Registro exitoso");
          setTimeout(() => {
            btnGuardar.disabled = false;
            location.href = "verCargaHoraria.php";
          }, 1000);
        } else {
          toastr["error"](objeto.mensaje, "Algo ocurrió");
        }
      },
      error: function (data) {
        btnBuscar.disabled = false;
        toastr["error"](data, "Algo ocurrió");
      },
    });
  }
}

function validarCursos() {
  if (listacursos.length == 0) {
    toastr["error"](
      "Debe agregar un curso por lo menos para guardar",
      "Guardar carga horaria"
    );
    return false;
  }

  let verificar = true;
  listacursos.forEach((element) => {
    element.grupos.forEach((item) => {
      if (item.docentes.length == 0) {
        toastr["error"](
          "Debe asignar al menos un docente para el grupo: " +
          item.nombre +
          ", del curso: " +
          element.curso,
          "Guardar carga horaria"
        );
        verificar = false;
        return;
      }

      if (item.fechas.length == 0) {
        toastr["error"](
          "Debe registrar las fechas del grupo: " +
          item.nombre +
          ", del curso: " +
          element.curso,
          "Guardar carga horaria"
        );
        verificar = false;
        return;
      }
    });
    if (!verificar) {
      return verificar;
    }
  });
  if (!verificar) {
    return verificar;
  }
  return true;
}

/* FUNCION AL CARGAR EL DOCUMENTO */
async function load_document() {
  await get_cbo_semestres();
  await get_cbo_unidades();
  change_cbo_ciclo();
  get_docentes();
  if (txtCgh_Id.value !== null && txtCgh_Id.value !== '' && txtCgc_Id.value !== null && txtCgc_Id.value !== '') {
    stdEditarCarga = 1;
    get_carga_horaria_by_id();
  }
  if (txtSem_id.value !== null && txtSem_id.value !== '' && txtSec_id.value !== null && txtSec_id.value !== '') {
    $("#cboSemestre").val(txtSem_id.value).trigger("change");
    $("#cboUnidad").val(txtSec_id.value).trigger("change");
    cboSemestre.disabled = true;
    cboUnidad.disabled = true;
    get_cbo_programas();
  }


  camposCursos(true, 1);
  btnGuardar.disabled = true;
  //cboCiclo.disabled = true;
  /* CAMPOS GENERALES */
  $("#btnCancelar").hide();
  cboSemestre.addEventListener("change", get_cbo_unidades);
  cboSemestre.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", change_cbo_ciclo);
  cboCiclo.addEventListener("change", buscar_cursos);
  btnGuardar.addEventListener("click", saveCargaHoraria);
  cboDocGrupo.addEventListener("change", actualizarDatosDocenteGrupo);
  tglDocSuplente.addEventListener("change", alternarDatosDoc);
  cboGrupoCurso.addEventListener("change", alternarDatosGrupo);
  btnAtras.addEventListener("click", back);
  $('[data-bs-toggle="tooltip"]').tooltip();
}

// EVENTOS
window.addEventListener("load", load_document);

// MODAL JS

window.onclick = function (event) {
  if (event.target === document.getElementById("myModal-docente")) {
    $("#myModal-docente").fadeOut();
    limpiarInputsModal();
  }
  if (event.target === document.getElementById("myModal-curso")) {
    $("#myModal-curso").fadeOut();
  }
  if (event.target === document.getElementById("myModal-grupo")) {
    $("#myModal-grupo").fadeOut();
  }
};
