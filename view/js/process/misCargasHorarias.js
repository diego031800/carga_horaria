let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');
let table = document.getElementById('table_ch');
let tbody = document.getElementById('cuerpo_ch');

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

/* FUNCION DE BUSCAR */
function buscar() {
  let opcion = "get_cargas_horarias_by_sem";
  let p_sem_id = cboSemestre.value ? cboSemestre.value : 0;
  let p_sec_id = cboUnidad.value ? cboUnidad.value : 0;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/MisCargasHorariasController.php",
    data: "opcion=" + opcion +
      "&p_sem_id=" + p_sem_id +
      "&p_sec_id=" + p_sec_id,
    beforeSend: function () {
      btnBuscar.disabled = true;
      let spinner = '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>'
      $('#cuerpo_ch').html('');
      $('#tbl_spinner').html(spinner);
    },
    success: function (data) {
      let datos = JSON.parse(data);
      btnBuscar.disabled = false;
      $('#cuerpo_ch').html('');
      $('#tbl_spinner').html('');
      $('#table_ch').DataTable().destroy();
      $('#table_ch').DataTable({
        data: datos,
        columns: [
          { data: 'nro', className: 'dt-center' },
          { data: 'acciones', className: 'dt-center' },
          { data: 'estado', className: 'dt-center' },
          { data: 'codigo', className: 'dt-center' },
          { data: 'semestre', className: 'dt-center' },
          { data: 'unidad', className: 'dt-center' },
          { data: 'usuario', className: 'dt-center' },
        ],
        responsive: true,
        select: true,
        columnDefs: [
          {
              targets: -1,
              className: 'dt-center'
          }
        ],
        language: {
          search:"Buscar", 
          zeroRecords:"Sin Resultados Coincidentes",
          paginate: {
            first: "Primera",
            last: "Ultima",
            next: "Siguiente",
            previous: "Anterior"
          },
          info: "Mostrando _START_ de _END_ de un total de _TOTAL_ Registros",
        },
      });
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

/* FUNCION AGREGAR */
function nuevaCarga() {
  let url = 'registrarCargaHoraria.php';
  location.href = url;
}

/* FUNCION EDITAR */
function editar(sem_id, sec_id) {
  location.href = 'detalleCargaHoraria?sem_id='+sem_id+'&sec_id='+sec_id;
}

/* FUNCION ENVIAR */
function editar(sem_id, sec_id) {
  location.href = 'detalleCargaHoraria?sem_id='+sem_id+'&sec_id='+sec_id;
}

/* FUNCION VER PDF */
function verPdf(sem_id, sec_id) {
  location.href = 'verCargaHoraria?sem_id='+sem_id+'&sec_id='+sec_id;
}

/* FUNCION ELIMINAR */

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  buscar();
  btnBuscar.addEventListener("click", buscar);
  btnNuevaCarga.addEventListener("click", nuevaCarga);
}

// EVENTOS
window.addEventListener("load", load_document);