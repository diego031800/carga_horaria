let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');
let btnAtras = document.getElementById('btnAtras');
let lblTitulo = document.getElementById('lblTitulo');
let btnVerPdf = document.getElementById('btnVerPdf');
let btnEnviar = document.getElementById('enviarDatos');
let docentes_array = [];

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
  var filasSeleccionadas = [];
  var filas = document.querySelectorAll("#table_ch tbody tr");

  filas.forEach(function (fila, index) {
    var checkbox = fila.querySelector(".form-check-input");
    if (checkbox.checked) {
      // La fila está seleccionada
      var nombre = fila.cells[5].textContent;
      var correo = fila.cells[6].textContent;
      var idx = docentes_array.findIndex((item) => item.docente == nombre);
      var codigo = docentes_array[idx].doc_codigo;
      var documento = docentes_array[idx].doc_documento;
      var sem_codigo = docentes_array[idx].sem_codigo;
      // Agrega los datos al arreglo de filas seleccionadas
      filasSeleccionadas.push({ nombre: nombre, correo: correo, codigo: codigo, documento: documento, sem: sem_codigo });
    }
  });
  let docentes = JSON.stringify(filasSeleccionadas);
  console.log(docentes);
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CorreosController.php",
    data: "docentes=" +
      docentes,
    beforeSend: function () {
      btnEnviar.disabled = true;
    },
    success: function (data) {
      objeto = JSON.parse(data);
      console.log(objeto);
      toastr["success"]("Nose", "Registro exitoso");
      resolve();
    },
    error: function (data) {
      btnBuscar.disabled = false;
      toastr["error"]("Nose", "Algo ocurrió");
      reject("Error al mostrar");
    },
  })
}

function enviarCredenciales() {
  var filasSeleccionadas = [];
  var filas = document.querySelectorAll("#table_ch tbody tr");

  filas.forEach(function (fila, index) {
    var checkbox = fila.querySelector(".form-check-input");
    if (checkbox.checked) {
      // La fila está seleccionada
      var nombre = fila.cells[5].textContent;
      var correo = fila.cells[6].textContent;
      var idx = docentes_array.findIndex((item) => item.docente == nombre);
      var codigo = docentes_array[idx].doc_codigo;
      var documento = docentes_array[idx].doc_documento;
      var sem_codigo = docentes_array[idx].sem_codigo;
      // Agrega los datos al arreglo de filas seleccionadas
      filasSeleccionadas.push({
        nombre: nombre,
        correo: correo,
        codigo: codigo,
        documento: documento,
        sem: sem_codigo,
      });
    }
  });
  let docentes = JSON.stringify(filasSeleccionadas);
  // Retornamos una promesa
  return new Promise(function (resolve, reject) {
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CorreosController.php",
      data: "docentes=" + docentes,
      beforeSend: function () {
        btnEnviar.disabled = true;
      },
      success: function (data) { // Habilitar el botón nuevamente
        toastr["success"]("Nose", "Registro exitoso");
        btnEnviar.disabled = false;
        resolve(JSON.parse(data)); // Resolvemos la promesa
      },
      error: function (data) {
        btnEnviar.disabled = false; // Habilitar el botón nuevamente
        toastr["error"]("Nose", "Algo ocurrió");
        reject("Error al mostrar"); // Rechazamos la promesa en caso de error
      },
    });
  });
}

async function promesaEnviar() {
  // Uso de la función enviarCredenciales
  try {
    // Realiza la llamada asincrónica a enviarCredenciales()
    const response = await enviarCredenciales();

    // El código que deseas ejecutar después de recibir la respuesta exitosa
    console.log(response);
    // Puedes realizar otras acciones después del éxito aquí
  } catch (error) {
    // El código que deseas ejecutar en caso de error
    console.error("Error: " + error);
    // Puedes realizar otras acciones en caso de error aquí
  }
}

/* FUNCION PARA IR ATRAS */
function back() {
  window.history.back();
}

/* FUNCION DE BUSCAR */
function buscar() {
  let opcion = "get_asignaciones_docentes";
  let p_sem_id = cboSemestre.value ? cboSemestre.value : 0;
  let p_sec_id = cboUnidad.value ? cboUnidad.value : 0;
  let p_prg_id = cboPrograma.value ? cboPrograma.value : 0;
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
      docentes_array = datos;
      btnBuscar.disabled = false;
      $('#cuerpo_asignacion').html('');
      $('#tbl_spinner').html('');
      $('#table_ch').DataTable().destroy();
      $('#table_ch').DataTable({
        data: datos,
        columns: [
          { data: 'nro', className: 'dt-center align-middle' },
          { data: 'acciones', className: 'dt-center align-middle' },
          { data: 'ciclo', className: 'dt-center align-middle' },
          { data: 'curso', className: 'dt-center align-middle' },
          { data: 'grupo', className: 'dt-center align-middle' },
          { data: 'docente', className: 'dt-center align-middle' },
          { data: 'correo', className: 'dt-center align-middle' },
          { data: 'fecha_inicio', className: 'dt-center align-middle' },
          { data: 'fecha_fin', className: 'dt-center align-middle' }
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
          search: "Buscar",
          zeroRecords: "Sin Resultados Coincidentes",
          paginate: {
            first: "Primera",
            last: "Ultima",
            next: "Siguiente",
            previous: "Anterior"
          },
          info: "Mostrando _START_ de _END_ de un total de _TOTAL_ Registros",
        },
        dom: '<"row"<"col-md-6"l><"col-md-6"f>>tp',
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
  btnEnviar.addEventListener("click", promesaEnviar);
}

// EVENTOS
window.addEventListener("load", load_document);