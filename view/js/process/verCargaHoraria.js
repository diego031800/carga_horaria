// VARIABLES


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
    let opcion = "get_cbo_programas";
    let sec_id = cboUnidad.value;
    $.ajax({
      type: "POST",
      url: "../../controllers/main/CargaHorariaController.php",
      data: "opcion=" + opcion +
        "&sec_id=" + sec_id,
      success: function (data) {
        objeto = JSON.parse(data);
        let opciones = objeto.programas;
        cboPrograma.disabled = false;
        if (objeto.has_data == 0) {
          cboPrograma.disabled = true;
        }
        $('#cboPrograma').html(opciones);
      },
      error: function (data) {
        alert("Error al mostrar");
      },
    });
  }
  
  function change_cbo_ciclo() {
    let unidad = $("#cboUnidad option[value='" + cboUnidad.value + "']").text();
    if (unidad == 'DOCTORADO') {
      $('#cboCiclo').html('<option value="">Ciclo ...</option>' +
                          '<option value="1">1</option>' +
                          '<option value="2">2</option>' +
                          '<option value="3">3</option>' +
                          '<option value="4">4</option>' +
                          '<option value="5">5</option>' +
                          '<option value="6">6</option>');
    } else {
      $('#cboCiclo').html('<option value="">Ciclo ...</option>' +
                          '<option value="1">1</option>' +
                          '<option value="2">2</option>' +
                          '<option value="3">3</option>' +
                          '<option value="4">4</option>');
    }
  }

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
    get_cbo_unidades();
    get_cbo_semestres();
    change_cbo_ciclo();
    cboSemestre.addEventListener("change", get_cbo_unidades);
    cboSemestre.addEventListener("change", get_cbo_programas);
    cboUnidad.addEventListener("change", get_cbo_programas);
    cboUnidad.addEventListener("change", change_cbo_ciclo);
}

// EVENTOS
window.addEventListener("load", load_document);