// VARIABLES
let cboSemestre = document.getElementById('cboSemestre');
let txtSemestre = document.getElementById('txtSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let txtUnidad = document.getElementById('txtUnidad');
let btnDescargarPdf = document.getElementById('btnDescargarPdf');
//let btnDescargarExc = document.getElementById('btnDescargarExc');
let btnBuscar = document.getElementById('btnBuscar');
let load_table = document.getElementById('load_table');

// FUNCIONES
// INICIO OBTENER COMBOS
function get_cbo_semestres() {
  return new Promise((resolve, reject) => {
    let opcion = "get_cbo_semestres";
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion,
      success: function (data) {
        let opciones = data;
        $('#cboSemestre').html(opciones);
        resolve(); // Resolvemos la promesa cuando los datos se han obtenido con éxito
      },
      error: function (data) {
        reject("Error al mostrar: " + data); // Rechazamos la promesa en caso de error
      },
    });
  });
}

function get_cbo_unidades() {
  return new Promise((resolve, reject) => {
    let opcion = "get_cbo_unidades";
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion,
      success: function (data) {
        let opciones = data;
        $('#cboUnidad').html(opciones);
        resolve(); // Resolvemos la promesa cuando los datos se han obtenido con éxito
      },
      error: function (data) {
        reject("Error al mostrar"); // Rechazamos la promesa en caso de error
      },
    });
  });
}

function enable_btnBuscar() {
  let semestre = cboSemestre.value;
  let unidad = cboUnidad.value;

  btnBuscar.disabled = false;

  if (semestre == null || semestre == '' || unidad == null || unidad == '') {
    btnBuscar.disabled = true;
  }
}

/* FUNCION PARA OBTENER LA CARGA HORARIA */
function search_carga_horaria() {
  let opcion = "buscar_carga_horaria";
  let p_sem_id = cboSemestre.value;
  let p_sec_id = cboUnidad.value;
  /* let p_prg_id = cboPrograma.value;
  let p_cgh_ciclo = cboCiclo.value; */
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion +
      "&p_sem_id=" + p_sem_id +
      "&p_sec_id=" + p_sec_id,
    beforeSend: function () {
      btnBuscar.disabled = true;
      let spinner = '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>'
      $('#tabla_carga_horaria').html('');
      $('#tabla_carga_horaria').html(spinner);
    },
    success: function (data) {
      btnBuscar.disabled = false;
      tabla = data;
      $('#tabla_carga_horaria').html(tabla);
      btnDescargarPdf.disabled = false;
      //btnDescargarExc.disabled = false;
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

/* FUNCION PARA DESCARGAR PDF */
function mostrarPdf() {
  let semestre = cboSemestre.value;
  let unidad = cboUnidad.value;
  let url = 'pdfCargaHoraria.php?sem_id='+semestre+'&sec_id='+unidad;
  window.open(url, '_blank');
}

/* FUNCION PARA IR ATRAS */
function back() {
  window.history.back();
}

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  function asignar_func() {
    if (txtSemestre.value !== null && txtSemestre.value !== '' && txtUnidad.value !== null && txtUnidad.value !== '') {
      cboSemestre.value = txtSemestre.value;
      cboUnidad.value = txtUnidad.value;
    }

    btnBuscar.addEventListener("click", search_carga_horaria);
    cboSemestre.addEventListener("change", enable_btnBuscar);
    cboUnidad.addEventListener("change", enable_btnBuscar);
    btnDescargarPdf.addEventListener("click", mostrarPdf);
    btnAtras.addEventListener("click", back);

    if (txtSemestre.value !== null && txtSemestre.value !== '' && txtUnidad.value !== null && txtUnidad.value !== '') {
      enable_btnBuscar();
      search_carga_horaria();
    }
  }

  Promise.all([get_cbo_unidades(), get_cbo_semestres()])
    .then(() => {
      asignar_func();
    })
    .catch(error => {
      console.error("Error en la obtención de datos:", error);
    });
}

// EVENTOS
window.addEventListener("load", load_document);