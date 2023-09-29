let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');
let btnAtras = document.getElementById('btnAtras');
let lblTitulo = document.getElementById('lblTitulo');
let btnVerPdf = document.getElementById('btnVerPdf');

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

/* FUNCION ENVIAR CREDENCIALES */
function enviarCredenciales() {
  let url = 'verCargaHoraria.php?sem_id=' + cboSemestre.value + '&sec_id=' + cboUnidad.value;
  location.href = url;
}

/* FUNCION PARA IR ATRAS */
function back() {
  window.history.back();
}

/* FUNCION DE BUSCAR */
function buscar() {
  let opcion = "get_asignaciones_docentes";
  let p_sem_id = cboSemestre.value?cboSemestre.value : 0;
  let p_sec_id = cboUnidad.value?cboUnidad.value : 0;
  let p_prg_id = cboPrograma.value?cboPrograma.value:0;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/AsignacionDocentesController.php",
    data: "opcion=" + opcion +
      "&p_sem_id=" + p_sem_id +
      "&p_sec_id=" + p_sec_id +
      "&p_prg_id=" + p_prg_id,
    beforeSend: function () {
      btnBuscar.disabled = true;
      let spinner = '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>'
      $('#cuerpo_asignacion').html('');
      $('#tbl_spinner').html(spinner);
    },
    success: function (data) {
      let datos = JSON.parse(data);
      btnBuscar.disabled = false;
      $('#cuerpo_asignacion').html('');
      $('#tbl_spinner').html('');
      $('#table_ch').DataTable().destroy();
      $('#table_ch').DataTable({
        data: datos,
        columns: [
          { data: 'nro', className: 'dt-center' },
          { data: 'acciones', className: 'dt-center' },
          { data: 'ciclo', className: 'dt-center' },
          { data: 'curso', className: 'dt-center' },
          { data: 'grupo', className: 'dt-center' },
          { data: 'docente', className: 'dt-center' },
          { data: 'correo', className: 'dt-center' },
          { data: 'fecha_inicio', className: 'dt-center' },
          { data: 'fecha_fin', className: 'dt-center' }
        ],
        responsive: false,
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
        createdCell: function (cell, cellData, rowData, rowIndex, colIndex) {
            if (colIndex === 4) {
                $(cell).css('background-color', '#ffcc00');
            }
        }
      });
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
    get_cbo_unidades();
    get_cbo_semestres();
    get_cbo_programas();
    buscar();
    cboUnidad.addEventListener("change", get_cbo_programas);
    btnBuscar.addEventListener("click", buscar);
}

// EVENTOS
window.addEventListener("load", load_document);