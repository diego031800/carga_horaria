/* ============ ELEMENTOS y VARIABLES ============ */

let btnBuscar = document.getElementById("btnBuscar");
let cboSemestre = document.getElementById("cboSemestre");
let cboUnidad = document.getElementById("cboUnidad");
let cboPrograma = document.getElementById("cboPrograma");
let cboCiclo = document.getElementById("cboCiclo");
let cboCreditos = document.getElementById("cboCreditos");
let cboCurso = document.getElementById("cboCurso");
let cboGrupo = document.getElementById("cboGrupo");
let cboHoras = document.getElementById("cboHoras");
let cboDocentes = document.getElementById("cboDocentes");
let cboFechas = document.getElementById("cboFechas");

let arrayGruposDisponibles = [
  { id: 1, nombre: "Grupo A" },
  { id: 2, nombre: "Grupo B" },
  { id: 3, nombre: "Grupo C" },
];

/* Funcionalidades */

function start_filtros() {
  let sem_id = cboSemestre.value;
  if (sem_id != '') {
    get_cbo_creditos(sem_id);
    get_cbo_grupos();
    get_cbo_horas(sem_id);
    get_cbo_cantidad_docentes(sem_id);
    get_cbo_cantidad_fechas(sem_id);
    get_cbo_cursos();
    habilitar(true);
  }
}

function habilitar(valor){
  cboUnidad.disabled = !valor;
  cboPrograma.disabled = !valor;
  cboCiclo.disabled = !valor;
  cboCreditos.disabled = !valor;
  cboCurso.disabled = !valor;
  cboGrupo.disabled = !valor;
  cboHoras.disabled = !valor;
  cboDocentes.disabled = !valor;
  cboFechas.disabled = !valor;
}

function mostrar(valor) {
  if (valor) {
    $('#tbl_resultado').show();
  } else {
    $('#tbl_resultado').hide();
  }
}

/* ============================== */

/* Realizar la búsqueda */

function buscar() {
  let opcion = "get_data";
  let sem_id = cboSemestre.value;
  if (sem_id != "") {
    let p_uni_id = cboUnidad.value != ''? cboUnidad.value :0;
    let p_pro_id = cboPrograma.value != ''? cboPrograma.value :0;
    let p_cic_id = cboCiclo.value != ''? cboCiclo.value :0;
    let p_cre_id = cboCreditos.value != ''? cboCreditos.value :0;
    let p_cur_id = cboCurso.value != ''? cboCurso.value :0;
    let p_gpo_id = cboGrupo.value != ''? cboGrupo.value :0;
    let p_hrs = cboHoras.value != ''? cboHoras.value :0;
    let p_doc = cboDocentes.value != ''? cboDocentes.value :0;
    let p_fec = cboFechas.value != ''? cboFechas.value :0;
    $.ajax({
      type: "GET",
      url: "../../controllers/report/detallecursosReportController.php",
      data: {
        opcion: opcion,
        sem_id: sem_id,
        p_uni_id: p_uni_id,
        p_pro_id: p_pro_id,
        p_cic_id: p_cic_id,
        p_cre_id: p_cre_id,
        p_cur_id: p_cur_id,
        p_gpo_id: p_gpo_id,
        p_hrs: p_hrs,
        p_doc: p_doc,
        p_fec: p_fec,
      },
      success: function (data) {
        let datos = JSON.parse(data);
        if (datos.respuesta == 1) {
          start_table_cursos(datos.data);
          mostrar(true);
        } else {
          toastr["error"](datos.mensaje, "Obtener datos");
        }
        console.log(datos);
      },
      error: function (data) {
        alert("Error al mostrar: " + data);
      },
    });
  } else{
    toastr["warning"]("Debe seleccionar un semestre", "Busqueda de datos");
  }
}


function start_table_cursos(data) {
  $("#tbl_resultado").DataTable().destroy();
  $("#tbl_resultado").DataTable({
    data: data,
    columns: [
      { data: "nro", className: "dt-center align-middle" },
      { data: "Semestre", className: "dt-center align-middle" },
      { data: "Unidad" , className: "dt-center align-middle" },
      { data: "Programa", className: "dt-center align-middle" },
      { data: "Ciclo" , className: "dt-center align-middle" },
      { data: "Nombre", className: "dt-center align-middle" },
      { data: "Creditos", className: "dt-center align-middle" },
      { data: "Grupo" , className: "dt-center align-middle" },
      { data: "FechaInicio", className: "dt-center align-middle" },
      { data: "FechaFin", className: "dt-center align-middle" },
      { data: "Horas" , className: "dt-center align-middle" },
      { data: "Acciones" , className: "dt-center align-middle" },
    ],
    responsive: true,
    select: true,
    lengthMenu: [10, 15, 20, 25],
    columnDefs: [
      {
        targets: -1,
        className: "dt-center",
      },
    ],
    language: {
      search: "Buscar",
      zeroRecords: "Sin Resultados Coincidentes",
      paginate: {
        first: "Primera",
        last: "Ultima",
        next: "Siguiente",
        previous: "Anterior",
      },
      info: "Mostrando _START_ de _END_ de un total de _TOTAL_ Registros",
    },
    dom: '<"row"<"col-md-6"l><"col-md-6"f>>tp',
    createdCell: function (cell, cellData, rowData, rowIndex, colIndex) {
      if (colIndex === 4) {
        $(cell).css("background-color", "#ffcc00");
      }
    },
  });
}
/* ============================== */

/* Obtener los datos */

/* Obtener datos para los filtros */

/* Filtros academicos */

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

function get_cbo_cursos() {
  let opcion = "get_cursos";
  //let ciclo = cboCiclo.value;
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      objeto = JSON.parse(data);
      let opciones = objeto.cursos;
      $("#cboCurso").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_grupos(){
  let fila = '<option value="">Selecciona un grupo ...</option>\n';
  arrayGruposDisponibles.forEach(element => {
    fila = fila + '<option value="'+element.id+'">'+element.nombre+'</option>\n';
  });
  $("#cboGrupo").html(fila);
}

function get_cbo_creditos(sem_id) {
  let opcion = "get_cbo_creditos";
  $.ajax({
    type: "GET",
    url: "../../controllers/report/detallecursosReportController.php",
    data: {
      opcion: opcion,
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let opciones = datos.data;
        $("#cboCreditos").html(opciones);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_horas(sem_id) {
  let opcion = "get_cbo_horas";
  $.ajax({
    type: "GET",
    url: "../../controllers/report/detallecursosReportController.php",
    data: {
      opcion: opcion,
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let opciones = datos.data;
        $("#cboHoras").html(opciones);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_cantidad_docentes(sem_id) {
  let opcion = "get_cbo_cantidad_docentes";
  $.ajax({
    type: "GET",
    url: "../../controllers/report/detallecursosReportController.php",
    data: {
      opcion: opcion,
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let opciones = datos.data;
        $("#cboDocentes").html(opciones);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

function get_cbo_cantidad_fechas(sem_id) {
  let opcion = "get_cbo_cantidad_fechas";
  $.ajax({
    type: "GET",
    url: "../../controllers/report/detallecursosReportController.php",
    data: {
      opcion: opcion,
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let opciones = datos.data;
        $("#cboFechas").html(opciones);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

/* ============================== */

function datos_docente(p_cgd_id) {
  let opcion = "get_datos_docente";
  $.ajax({
    type: "GET",
    url: "../../controllers/report/detallecursosReportController.php",
    data: {
      opcion: opcion,
      p_cgd_id: p_cgd_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let docentes = datos.data;
        $("#table_resultado_docentes tbody").empty();
        docentes.forEach(element => {
          fila= '<tr><td scope="row" class="text-center">'+element.nro+'</td>'+
                '<td class="text-center">'+element.Tipo+'</td>'+
                '<td class="text-center">'+element.Id +'</td>'+
                '<td class="text-center">'+element.Nombres+'</td>'+
                '<td class="text-center">'+element.Condicion+'</td>'+
                '<td class="text-center">'+element.Grado+'</td>'+
                '<td class="text-center">'+element.Codigo+'</td>'+
                '<td class="text-center">'+element.Documento+'</td>'+
                '<td class="text-center">'+element.Email+'</td></tr>';
          $("#table_resultado_docentes tbody").append(fila);
        });
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
  $("#myModal-docentes").fadeIn();
}

/* ========================================================================================== */

/* GENERAR PDF */

function generar_pdf(){
  let sem_id = cboSemestre.value;
  let sem_txt = cboSemestre.options[cboSemestre.selectedIndex].text;
  if (sem_id != "") {
    let p_uni_id = cboUnidad.value != ''? cboUnidad.value :0;
    let p_pro_id = cboPrograma.value != ''? cboPrograma.value :0;
    let p_cic_id = cboCiclo.value != ''? cboCiclo.value :0;
    let p_cre_id = cboCreditos.value != ''? cboCreditos.value :0;
    let p_cur_id = cboCurso.value != ''? cboCurso.value :0;
    let p_gpo_id = cboGrupo.value != ''? cboGrupo.value :0;
    let p_hrs = cboHoras.value != ''? cboHoras.value :0;
    let p_doc = cboDocentes.value != ''? cboDocentes.value :0;
    let p_fec = cboFechas.value != ''? cboFechas.value :0;
    let url = 'pdfDetalleReporte.php?'+
    'sem='+sem_txt+
    '&sem_id='+sem_id+
    '&p_uni_id='+p_uni_id+
    '&p_pro_id='+p_pro_id+
    '&p_cic_id='+p_cic_id+
    '&p_cre_id='+p_cre_id+
    '&p_cur_id='+p_cur_id+
    '&p_gpo_id='+p_gpo_id +
    '&p_hrs='+p_hrs +
    '&p_doc='+p_doc +
    '&p_fec='+p_fec ;
   window.open(url,'_blank');
  } else{
    toastr["warning"]("Debe seleccionar un semestre", "Busqueda de datos");
  }
}

/* ============================== */



/* EVENTOS */



/* ============================== */



function load_document() {
  get_cbo_unidades();
  get_cbo_semestres();
  get_cbo_programas();
  cboSemestre.addEventListener("change", start_filtros);
  cboUnidad.addEventListener("change", get_cbo_programas);
  cboUnidad.addEventListener("change", change_cbo_ciclo);
  btnBuscar.addEventListener("click", buscar);
  habilitar(false);
  mostrar(false);
}

// EVENTOS
window.addEventListener("load", load_document);

window.onclick = function (event) {
  if (event.target === document.getElementById("myModal-docentes")) {
    $("#myModal-docentes").fadeOut();
  }
};