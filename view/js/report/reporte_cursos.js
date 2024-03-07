let cboSemestre = document.getElementById('cboSemestre');




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
  }
  
  // EVENTOS
  window.addEventListener("load", load_document);