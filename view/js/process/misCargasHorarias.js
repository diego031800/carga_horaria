let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let txtFechaInicio = document.getElementById('txtFechaInicio');
let txtFechaFin = document.getElementById('txtFechaFin');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');

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

// INICIALIZAR FECHAS
function inicializar_fechas() {
  const fechaActual = new Date();
  txtFechaFin.valueAsDate = fechaActual;
  
  const fechaAntes = new Date();
  fechaAntes.setMonth(fechaAntes.getMonth() - 6);
  txtFechaInicio.valueAsDate = fechaAntes;
}

/* FUNCION DE BUSCAR */
function buscar() {
  let opcion = "get_cargas_horarias_by_sem";
  let p_sem_id = cboSemestre.value ? cboSemestre.value : 0;
  let p_sec_id = cboUnidad.value ? cboUnidad.value : 0;
  let p_fecha_inicio = txtFechaInicio.value ? txtFechaInicio.value : '';
  let p_fecha_fin = txtFechaFin.value ? txtFechaFin.value : '';
  $.ajax({
    type: "POST",
    url: "../../controllers/main/MisCargasHorariasController.php",
    data: "opcion=" + opcion +
      "&p_sem_id=" + p_sem_id +
      "&p_sec_id=" + p_sec_id +
      "&p_fecha_inicio=" + p_fecha_inicio +
      "&p_fecha_fin=" + p_fecha_fin,
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

/* FUNCION EDITAR */
function editar(sem_id, sec_id) {
  location.href = 'detalleCargaHoraria?sem_id='+sem_id+'&sec_id='+sec_id;
}

/* FUNCION ENVIAR */
/* FUNCION ELIMINAR */

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  inicializar_fechas();
  get_cbo_unidades();
  get_cbo_semestres();
  buscar();
  btnBuscar.addEventListener("click", buscar);
}

// EVENTOS
window.addEventListener("load", load_document);