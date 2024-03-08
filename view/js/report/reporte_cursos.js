let btnBuscar = document.getElementById('btnBuscar');
let cboSemestre = document.getElementById('cboSemestre');
const ctx = document.getElementById('myChart');

/* Realizar la búsqueda */

function buscar() {
  let sem_id = cboSemestre.value;
  get_cantidad_cursos_unidad(sem_id);
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
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        let dataset = datos.data;
        let labels = [];
        let cantidades = [];
        dataset.forEach(element => {
          labels.push(element.Unidad);
          cantidades.push(parseInt(element.Cantidad));
        });
        console.log(dataset);
        console.log(labels);
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

/* ============================== */


function start_chart_cursos_unidad(data, labels) {
  let sem = cboSemestre.options[cboSemestre.selectedIndex].text;
  let titulo = "Cantidad de cursos en la unidad del semestre " + sem;
  const config = {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [{
        label: 'Cantidad de cursos',
        data: data,
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        borderColor: 'rgb(75, 192, 192)',
        borderWidth: 1
      }]
    },
    options: {
      plugins: {
        title: {
          display: true,
          text: titulo,
          padding: {
            top: 10,
            bottom: 30
        }
        }
      }
    }
  };
  new Chart(ctx, config);
}


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


function load_document() {
  get_cbo_semestres();
  btnBuscar.addEventListener("click", buscar);
}

// EVENTOS
window.addEventListener("load", load_document);