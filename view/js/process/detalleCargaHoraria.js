let cboSemestre = document.getElementById('sem_id');
let cboUnidad = document.getElementById('sec_id');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');
let btnAtras = document.getElementById('btnAtras');

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
  let opcion = "get_programas";
  let p_sec_id = cboUnidad.value;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/MisCargasHorariasController.php",
    data: "opcion=" + opcion + "&p_sec_id=" + p_sec_id,
    success: function (data) {
      let opciones = data;
      $("#cboPrograma").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function change_cbo_ciclo() {
  let unidad = $("#cboUnidad option[value='" + cboUnidad.value + "']").text();
  console.log('cambia');
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

/* FUNCION AGREGAR */
function nuevaCarga() {
  let url = 'registrarCargaHoraria.php';
  location.href = url;
}

/* FUNCION DE BUSCAR */
function buscar() {
  let opcion = "get_cargas_horarias";
  let p_sem_id = cboSemestre.value?cboSemestre.value:0;
  let p_sec_id = cboUnidad.value?cboUnidad.value:0;
  let p_prg_id = cboPrograma.value?cboPrograma.value:0;
  let p_ciclo = cboCiclo.value?cboCiclo.value:0;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/MisCargasHorariasController.php",
    data: "opcion=" + opcion +
      "&p_sem_id=" + p_sem_id +
      "&p_sec_id=" + p_sec_id +
      "&p_prg_id=" + p_prg_id +
      "&p_ciclo=" + p_ciclo,
    beforeSend: function () {
      btnBuscar.disabled = true;
      let spinner = '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>'
      $('#cuerpo_ch').html('');
      $('#cuerpo_ch').html(spinner);
    },
    success: function (data) {
      btnBuscar.disabled = false;
      tabla = data;
      $('#cuerpo_ch').html('');
      $('#cuerpo_ch').html(tabla);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

/* FUNCION PARA EDITAR */
function editar(cgh_id) {
  
}

/* FUNCION PARA IR ATRAS */
function back() {
  window.history.back();
}

/* FUNCION PARA ELIMINAR */
function eliminar() {
  
}

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  get_cbo_programas();
  change_cbo_ciclo();
  buscar();
  // btnBuscar.addEventListener("click", buscar);
  btnNuevaCarga.addEventListener("click", nuevaCarga);
  btnBuscar.addEventListener("click", buscar);
  btnAtras.addEventListener("click", back);
}

// EVENTOS
window.addEventListener("load", load_document);