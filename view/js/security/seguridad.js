let usuarios = [];
let paginas = [];
let permisos= [];

function get_usuarios() {
  let opcion = "get_usuarios";
  $.ajax({
    type: "POST",
    url: "../../controllers/security/seguridadController.php",
    data: "opcion=" + opcion,
    beforeSend: function () {
      let spinner =
        '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>';
      $("#cuerpo_asignacion").html("");
      $("#tbl_spinner").html(spinner);
    },
    success: function (data) {
      let datos = JSON.parse(data);
      usuarios = datos.usuarios;
      if (datos.respuesta == 1) {
        $("#cuerpo_asignacion").html("");
        $("#tbl_spinner").html("");
        $("#table_ch").DataTable().destroy();
        $("#table_ch").DataTable({
          data: datos.usuarios,
          columns: [
            { data: "nro", className: "dt-center align-middle" },
            { data: "nombres", className: "dt-center align-middle" },
            { data: "acciones", className: "dt-center align-middle" },
          ],
          responsive: true,
          select: true,
          lengthMenu: [5, 10, 15, 20, 25],
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
    },
    error: function (data) {
      toastr["error"](data.mensaje, "Obtener datos");
    },
  });
}

function load_document() {
  get_usuarios();
  get_paginas();
}

function abrir_Modal_permisos(id_usuario) {
  $("#myModal-permisos").fadeIn();
  llenar_Tabla();
}

function get_permisos_usuario(id_usuario){

}

function llenar_Tabla() {
  $("#table_paginas_1").DataTable().destroy();
  $("#table_paginas_1").DataTable({
    data: paginas,
    columns: [
      { data: "nro", className: "dt-center align-middle" },
      { data: "pag_nombre", className: "dt-center align-middle" },
      { data: "parent_nombre", className: "dt-center align-middle" },
      { data: "acciones", className: "dt-center align-middle" },
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

function get_paginas() {
  let opcion = "get_paginas";
  $.ajax({
    type: "POST",
    url: "../../controllers/security/seguridadController.php",
    data: "opcion=" + opcion,
    beforeSend: function () {
      let spinner =
        '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>';
      $("#cuerpo_paginas").html("");
      $("#tbl_spinner_1").html(spinner);
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        $("#cuerpo_paginas").html("");
        $("#tbl_spinner_1").html("");
        paginas = datos.paginas;
      }
    },
    error: function (data) {
      toastr["error"](data.mensaje, "Obtener datos");
    },
  });
}

function agregar_eliminar_permiso(id) {
  let id_input = "check_pag_"+id; 
  let id_label = "label_pag_"+id; 
  let check_pag = document.getElementById(id_input);
  let label_pag = document.getElementById(id_label);
  if(check_pag.checked){
    label_pag.textContent = "SI";
  }else{
    label_pag.textContent = "NO";
  }
}

// EVENTOS
window.addEventListener("load", load_document);

window.onclick = function (event) {
  if (event.target === document.getElementById("myModal-docente")) {
    $("#myModal-permisos").fadeOut();
    limpiarInputsModal();
  }
};
