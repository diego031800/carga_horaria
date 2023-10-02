let cboSemestre = document.getElementById('sem_id');
let cboUnidad = document.getElementById('sec_id');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');
let btnAtras = document.getElementById('btnAtras');
let lblTitulo = document.getElementById('lblTitulo');
let btnVerPdf = document.getElementById('btnVerPdf');

// FUNCIONES
// INICIO OBTENER COMBOS
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
  let url = 'registrarCargaHoraria.php?sem_id=' + cboSemestre.value + '&sec_id=' + cboUnidad.value;
  location.href = url;
}

/* FUNCION PARA EDITAR */
function editar(cgh_id, cgc_id) {
  let url = 'registrarCargaHoraria.php?cgh_id=' + cgh_id + '&cgc_id=' + cgc_id;
  location.href = url;
}

/* FUNCION PARA VER PDF */
function verPdf() {
  let url = 'verCargaHoraria.php?sem_id=' + cboSemestre.value + '&sec_id=' + cboUnidad.value;
  location.href = url;
}

/* FUNCION PARA IR ATRAS */
function back() {
  window.history.back();
}

/* FUNCION PARA ELIMINAR */
function eliminar() {
  
}

/* FUNCION DE BUSCAR */
function buscar() {
  let opcion = "get_cargas_horarias";
  let p_sem_id = cboSemestre.value ? cboSemestre.value : 0;
  let p_sec_id = cboUnidad.value ? cboUnidad.value : 0;
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
          { data: 'programa', className: 'dt-center' },
          { data: 'ciclo', className: 'dt-center' },
          { data: 'creado', className: 'dt-center' },
          { data: 'editado', className: 'dt-center' },
          { data: 'usuario', className: 'dt-center' },
        ],
        responsive: false,
        select: true,
        lengthMenu: [5, 10, 15, 20, 25],
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

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
  get_cbo_programas();
  change_cbo_ciclo();
  buscar();
  // btnBuscar.addEventListener("click", buscar);
  btnNuevaCarga.addEventListener("click", nuevaCarga);
  btnBuscar.addEventListener("click", buscar);
  btnAtras.addEventListener("click", back);
  btnVerPdf.addEventListener("click", verPdf);
}

// EVENTOS
window.addEventListener("load", load_document);