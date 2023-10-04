let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboPrograma = document.getElementById('cboPrograma');
let btnBuscar = document.getElementById('btnBuscar');
let btnNuevaCarga = document.getElementById('btnNuevaCarga');
let btnAtras = document.getElementById('btnAtras');
let lblTitulo = document.getElementById('lblTitulo');
let btnVerPdf = document.getElementById('btnVerPdf');
let btnReporte = document.getElementById('btnReporte');
let btnEnviar = document.getElementById('btnEnviar');
let btnEnviando = document.getElementById('btnEnviando');
let docentes_array = [];

// Datos del semestre, unidad y programa;
let sem_txt = '';
let sec_txt = '';
let prg_txt = '';

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
  sem_txt = cboSemestre.options[cboSemestre.selectedIndex].text;
  sem_idCbo = cboSemestre.value;
  sec_txt = cboUnidad.options[cboUnidad.selectedIndex].text;
  sec_idCbo = cboUnidad.value;
  prg_txt = cboPrograma.options[cboPrograma.selectedIndex].text;
  prg_idCbo = cboPrograma.value;
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
        sem_id: sem_idCbo,
        sec_id: sec_idCbo,
        prg_id: prg_idCbo,
      });
    }
  });
  let docentes = JSON.stringify(filasSeleccionadas);
  console.log(docentes);
  // Retornamos una promesa
  return new Promise(function (resolve, reject) {
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CorreosController.php",
      data: "docentes=" + docentes,
      beforeSend: function () {
        btnEnviar.disabled = true;
        $('#btnEnviando').show();
        $('#btnEnviar').hide();
      },
      success: function (data) { // Habilitar el botón nuevamente
        toastr["success"]("Envío de correo", "Envío exitoso");
        $('#btnEnviar').show();
        $('#btnEnviando').hide();
        btnEnviar.disabled = false;
        resolve(JSON.parse(data)); // Resolvemos la promesa
      },
      error: function (data) {
        btnEnviar.disabled = false; // Habilitar el botón nuevamente
        toastr["error"]("Envío de correo", "Hubo un error en el envío");
        reject("Error al mostrar"); // Rechazamos la promesa en caso de error
      },
    });
  });
}
/*
function prueba(){
  let url = 'pdfEnvio.php?semTxt='+sem_txt+'&secTxt='+ sec_txt+'&prgTxt='+ prg_txt;
  window.open(url, '_blank');
}*/

async function promesaEnviar() {
  try {
    const response = await enviarCredenciales();
    reportEnvioPDF(response);
  } catch (error) {
    console.error("Error: " + error);
  }
}

function reportEnvioPDF(response){
  let responseJson = JSON.stringify(response);
  $.ajax({
    type: "POST",
    url: "pdfEnvio.php", // Reemplaza esto con la URL de tu servidor
    data: {
      semTxt: sem_txt,
      secTxt: sec_txt,
      prgTxt: prg_txt,
      reporte: 0,
      docs: responseJson
    },xhrFields: {
        responseType: 'blob'
    },
    success: function (response, status, xhr) {
      try {
        //Obtenemos la respuesta para convertirla a blob
        var blob = new Blob([response], { type: 'application/pdf' });
        var URL = window.URL || window.webkitURL;
        //Creamos objeto URL
        var downloadUrl = URL.createObjectURL(blob);
        //Abrir en una nueva pestaña
        window.open(downloadUrl);
    } catch (ex) {
        console.log(ex);
    }
    },
    error: function (error) {
      console.error("Error en la solicitud AJAX:", error);
    }
  });
}

function reportGeneralPdf(){
  sem_txt = cboSemestre.options[cboSemestre.selectedIndex].text;
  sem_idCbo = cboSemestre.value;
  sec_txt = cboUnidad.options[cboUnidad.selectedIndex].text;
  sec_idCbo = cboUnidad.value;
  prg_txt = cboPrograma.options[cboPrograma.selectedIndex].text;
  prg_idCbo = cboPrograma.value;
  $.ajax({
    type: "POST",
    url: "pdfEnvio.php", // Reemplaza esto con la URL de tu servidor
    data: {
      semTxt: sem_txt,
      secTxt: sec_txt,
      prgTxt: prg_txt,
      reporte: 1,
      sem_id: sem_idCbo,
      sec_id: sec_idCbo,
      prg_id: prg_idCbo,
    },xhrFields: {
        responseType: 'blob'
    },
    success: function (response, status, xhr) {
      try {
        //Obtenemos la respuesta para convertirla a blob
        var blob = new Blob([response], { type: 'application/pdf' });
        var URL = window.URL || window.webkitURL;
        //Creamos objeto URL
        var downloadUrl = URL.createObjectURL(blob);
        //Abrir en una nueva pestaña
        window.open(downloadUrl);
    } catch (ex) {
        console.log(ex);
    }
    },
    error: function (error) {
      console.error("Error en la solicitud AJAX:", error);
    }
  });
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
      if (datos.length > 0) {
        btnEnviar.disabled = false;
        btnReporte.disabled = false;
      }
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
        responsive: true,
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
  btnReporte.addEventListener("click", reportGeneralPdf);
}

// EVENTOS
window.addEventListener("load", load_document);