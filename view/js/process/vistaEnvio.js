let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let btnBuscar = document.getElementById('btnBuscar');

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
  
  function enable_btnBuscar() {
    let semestre = cboSemestre.value;
    let unidad = cboUnidad.value;
  
    btnBuscar.disabled = false;
  
    if (semestre == null || semestre == '' || unidad == null || unidad == '') {
      btnBuscar.disabled = true;
    }
  }

  function load_document() {
    get_cbo_unidades();
    get_cbo_semestres();
    cboSemestre.addEventListener("change", enable_btnBuscar);
    cboUnidad.addEventListener("change", enable_btnBuscar);
}

window.addEventListener("load", load_document);