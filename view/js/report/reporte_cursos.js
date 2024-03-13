let btnBuscar = document.getElementById("btnBuscar");
let cboSemestre = document.getElementById("cboSemestre");
const chartcursosXunidad = document.getElementById("cursosXunidad");
const chartcursosXgrupo = document.getElementById("cursosXgrupo");
const chartcursosXhoras = document.getElementById("cursosXhoras");

let total_cursos;
/* Funcionalidades */

function mostrar(valor) {
  if (valor) {
    $('#separador_1').show();
    $('#separador_2').show();
    $('#separador_3').show();
    $('#tbl_cursos_grupos_leyenda').show();
    $('#tbl_cursos_horas_leyenda').show();
    $('#tbl_cursos_t_nt_unidad').show();
    $('#title_tbl_cursos_t_nt_unidad').show();
    $('#nota_tbl_cursos_t_nt_unidad').show();
  } else {
    $('#separador_1').hide();
    $('#separador_2').hide();
    $('#separador_3').hide();
    $('#tbl_cursos_grupos_leyenda').hide();
    $('#tbl_cursos_horas_leyenda').hide();
    $('#tbl_cursos_t_nt_unidad').hide();
    $('#title_tbl_cursos_t_nt_unidad').hide();
    $('#nota_tbl_cursos_t_nt_unidad').hide();
  }
}

/* ============================== */


/* Realizar la búsqueda */

function buscar() {
  let sem_id = cboSemestre.value;
  if (sem_id != "") {
    get_cantidad_cursos_unidad(sem_id);
    get_cantidad_cursos_grupos(sem_id);
    get_cant_cursos_horas(sem_id);
    get_cant_cursos_terminados_sinterminar_unidad(sem_id);
    mostrar(true);
  }else{
    toastr["warning"]("Debe seleccionar un semestre", "Busqueda de datos");
  }
}

/* ============================== */

/* Obtener los datos */

/* Gráfico de cantidad de cursos por unidad  */

function get_cantidad_cursos_unidad(sem_id) {
  $.ajax({
    type: "GET",
    url: "../../controllers/report/cursosReportController.php",
    data: {
      opcion: "get_cant_cursos_unidad",
      sem_id: sem_id,
    },
    success: function (data) {
      total_cursos = 0;
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let dataset = datos.data;
        let labels = [];
        let cantidades = [];
        dataset.forEach((element) => {
          total_cursos = total_cursos + parseInt(element.Cantidad);
          labels.push(element.Unidad);
          cantidades.push(parseInt(element.Cantidad));
        });
        console.log(dataset);
        start_chart_cursos_unidad(cantidades, labels);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      let datos = JSON.parse(data);
      toastr["error"](datos.mensaje, "Obtener datos");
    },
  });
}
/* ============================== */

/* Gráfico de cantidad de cursos por grupo  */

function get_cantidad_cursos_grupos(sem_id) {
  $.ajax({
    type: "GET",
    url: "../../controllers/report/cursosReportController.php",
    data: {
      opcion: "get_cant_cursos_grupo",
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let dataset = datos.data;
        let labels = [];
        let cantidades = [];
        dataset.forEach((element) => {
          labels.push(element.Grupo);
          cantidades.push(parseInt(element.Cantidad));
        });
        start_chart_cursos_grupos(cantidades, labels);
        start_table_cursos_grupos(dataset);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      let datos = JSON.parse(data);
      toastr["error"](datos.mensaje, "Obtener datos");
    },
  });
}

/* ============================== */

/* Gráfico de cantidad de cursos por horas  */

function get_cant_cursos_horas(sem_id) {
  $.ajax({
    type: "GET",
    url: "../../controllers/report/cursosReportController.php",
    data: {
      opcion: "get_cant_cursos_horas",
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let dataset = datos.data;
        let labels = [];
        let cantidades = [];
        dataset.forEach((element) => {
          labels.push(element.Horas);
          cantidades.push(parseInt(element.Cantidad));
          resultado= element.Cantidad*100/total_cursos;
          element.Porcentaje = resultado.toFixed(2)+" %";
        });
        start_chart_cursos_horas(cantidades, labels);
        start_table_cursos_horas(dataset);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      let datos = JSON.parse(data);
      toastr["error"](datos.mensaje, "Obtener datos");
    },
  });
}

/* ============================== */

/* Gráfico de cantidad de cursos por horas  */

function get_cant_cursos_terminados_sinterminar_unidad(sem_id) {
  $.ajax({
    type: "GET",
    url: "../../controllers/report/cursosReportController.php",
    data: {
      opcion: "get_cant_cursos_terminados_sinterminar_unidad",
      sem_id: sem_id,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let dataset = datos.data;
        start_table_cursos_nt_t_unidad(dataset);
      } else {
        toastr["error"](datos.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      let datos = JSON.parse(data);
      toastr["error"](datos.mensaje, "Obtener datos");
    },
  });
}

/* ============================== */

/* ======================================================================================================================== */

/* Generar los gráficos */

/* Gráfico de cantidad de cursos por unidad  */
function start_chart_cursos_unidad(data, labels) {
  let sem = cboSemestre.options[cboSemestre.selectedIndex].text;
  let titulo = "Cantidad de cursos en la unidad del semestre " + sem;
  var config = {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        {
          label: "Cantidad de cursos",
          data: data,
          backgroundColor: "rgba(75, 192, 192, 0.2)",
          borderColor: "rgb(75, 192, 192)",
          borderWidth: 1,
        },
      ],
    },
    options: {
      plugins: {
        title: {
          display: true,
          text: titulo,
          padding: {
            top: 10,
            bottom: 30,
          },
        },
      },
    },
  };
  new Chart(chartcursosXunidad, config);
}

/* ============================== */

/* Gráfico de cantidad de cursos por grupos  */

function start_chart_cursos_grupos(data, labels) {
  let sem = cboSemestre.options[cboSemestre.selectedIndex].text;
  let titulo = "Cantidad de cursos según la cantidad de grupos que tienen, en el semestre" + sem;
  const config = {
    type: "pie",
    data: {
      labels: labels,
      datasets: [
        {
          label: "Cantidad de cursos",
          data: data,
          backgroundColor: [
            "rgb(255, 99, 132)",
            "rgb(54, 162, 235)",
            "rgb(255, 205, 86)",
          ],
          hoverOffset: 4,
        },
      ],
    },
    options: {
      plugins: {
        title: {
          display: true,
          text: titulo,
          padding: {
            top: 10,
            bottom: 30,
          },
        },
      },
    },
    height: 500
  };
  var chart1 = new Chart(chartcursosXgrupo, config);
  chart1.resize(500, 500);
}

/* ============================== */

/* Gráfico de cantidad de cursos por grupos  */

function start_table_cursos_grupos(data) {
  $("#tbl_cursos_grupos_leyenda tbody").empty();
  data.forEach(element => {
    resultado= parseInt(element.Cantidad)*100/total_cursos;
    Porcentaje = resultado.toFixed(2)+" %";
    fila= '<tr><td scope="row">'+element.Grupo+'</td>'+
          '<td>'+element.Cantidad+'</td>'+
          '<td>'+Porcentaje+'</td></tr>';
    $("#tbl_cursos_grupos_leyenda tbody").append(fila);
  });
}

/* ============================== */

/* Gráfico de cantidad de cursos por horas  */

function start_chart_cursos_horas(data, labels) {
  let sem = cboSemestre.options[cboSemestre.selectedIndex].text;
  let titulo = "Cantidad de cursos según la cantidad de horas en el semestre " + sem;
  const config = {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        {
          label: "Cantidad de cursos",
          data: data,
          backgroundColor: "rgba(255, 99, 132, 0.2)",
          borderColor: "rgb(255, 99, 132)",
          borderWidth: 2,
        },
      ],
    },
    options: {
      plugins: {
        title: {
          display: true,
          text: titulo,
          padding: {
            top: 10,
            bottom: 30,
          },
        },
      },
    },
    height: 500
  };
  new Chart(chartcursosXhoras, config);
  /*let chart2 = 
  chart2.resize(800, 600);*/
}

/* ============================== */

/* Tabla de cantidad de cursos por horas  */

function start_table_cursos_horas(data) {
  $("#tbl_cursos_horas_leyenda").DataTable().destroy();
  $("#tbl_cursos_horas_leyenda").DataTable({
    data: data,
    columns: [
      { data: "Horas", className: "dt-center align-middle" },
      { data: "Cantidad", className: "dt-center align-middle" },
      { data: "Porcentaje" , className: "dt-center align-middle" },
    ],
    responsive: true,
    select: true,
    paging: false,
    scrollY: 400,
    lengthMenu: [8, 16, 20, 25],
    columnDefs: [
      {
        targets: -1,
        className: "dt-center",
      },
    ],
    language: {
      search: "Buscar",
      zeroRecords: "Sin Resultados Coincidentes",
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

/* Tabla de cantidad de cursos terminados y no terminados por unidad  */

function start_table_cursos_nt_t_unidad(data) {
  $("#tbl_cursos_t_nt_unidad").DataTable().destroy();
  $("#tbl_cursos_t_nt_unidad").DataTable({
    data: data,
    columns: [
      { data: "Nro", className: "dt-center align-middle" },
      { data: "Unidad", className: "dt-center align-middle" },
      { data: "NoTerminados", className: "dt-center align-middle" },
      { data: "Terminados", className: "dt-center align-middle" },
    ],
    responsive: true,
    select: true,
    lengthMenu: [8, 16, 20, 25],
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

/* ========================================================================================== */

function get_cbo_semestres() {
  let opcion = "get_cbo_semestres";
  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      let opciones = data;
      $("#cboSemestre").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar: " + data);
    },
  });
}


function load_document() {
  get_cbo_semestres();
  btnBuscar.addEventListener("click", buscar);
  mostrar(false);
}

// EVENTOS
window.addEventListener("load", load_document);
