let txt_id_usu_modal = document.getElementById("id_usuario");
let titulo_modal = document.getElementById("titulo_modal");
let usuarios = [];
let paginas = [];
let permisos = [];

let flag_cambio_array_permisos = false;

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
  flag_cambio_array_permisos = false;
  let indx_usu = usuarios.findIndex((item) => id_usuario == item.usu_id);
  titulo_modal.textContent = "GESTIONAR PERMISOS DE: " + usuarios[indx_usu].nombres;
  $("#myModal-permisos").fadeIn();
  txt_id_usu_modal.value = id_usuario;
  llenar_Tabla_1();
  get_permisos_usuario(id_usuario);
}

function get_permisos_usuario(id_usuario) {
  let opcion = "get_permisos_usuarios";
  $.ajax({
    type: "POST",
    url: "../../controllers/security/seguridadController.php",
    data: {
      opcion: opcion,
      id_usu: id_usuario,
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        permisos = datos.permisos;
        marcar_permisos_usuario();
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

function marcar_permisos_usuario() {
  permisos.forEach((element) => {
    id_input = "check_pag_" + element.chpp_id_pag;
    check_pag = document.getElementById(id_input);
    check_pag.checked = true;
    cambio_label_permiso(element.chpp_id_pag);
  });
}

function llenar_Tabla_1() {
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
      } else {
        toastr["error"](data.mensaje, "Obtener datos");
      }
    },
    error: function (data) {
      toastr["error"](data.mensaje, "Obtener datos");
    },
  });
}

function agregar_eliminar_permiso(id) {
  let usu_id = txt_id_usu_modal.value;
  let id_input = "check_pag_" + id;
  let id_label = "label_pag_" + id;
  let check_pag = document.getElementById(id_input);
  let label_pag = document.getElementById(id_label);
  index_permiso = permisos.findIndex((item) => item.chpp_id_pag == id);
  if (check_pag.checked) {
    label_pag.textContent = "SI";
    if(index_permiso == -1){
      permisos.push({
        permiso_id : 0,
        chpp_id_usu : usu_id,
        chpp_id_pag : id,
        chpp_estado : "1"
      });
    }else{
      permisos[index_permiso].chpp_estado = 1;
    }
  } else {
    label_pag.textContent = "NO";
    if(permisos[index_permiso].permiso_id == 0){
      permisos.splice(index_permiso,1);
    }else{
      permisos[index_permiso].chpp_estado = 0;
    }
  }
  flag_cambio_array_permisos = true;
}

function cambio_label_permiso(id) {
  let id_input = "check_pag_" + id;
  let id_label = "label_pag_" + id;
  let check_pag = document.getElementById(id_input);
  let label_pag = document.getElementById(id_label);
  if (check_pag.checked) {
    label_pag.textContent = "SI";
  } else {
    label_pag.textContent = "NO";
  }
}

function guardar_permisos(){
  let usu_id = txt_id_usu_modal.value;
  let opcion="save_permisos_usuario";
  $.ajax({
    type: "POST",
    url: "../../controllers/security/seguridadController.php",
    data: {
      opcion: opcion,
      id_usu: usu_id,
      permisos_usu: JSON.stringify(permisos)
    },
    success: function (data) {
      let datos = JSON.parse(data);
      if (datos.respuesta == 1) {
        toastr["success"](datos.mensaje, "Guardar permisos");
      } else if(datos.respuesta == 2){
        toastr["success"](datos.mensaje, "Guardar permisos");
        setTimeout(() => {
          location.reload();
        }, 350);
      } 
      else {
        toastr["error"](datos.mensaje, "Guardar permisos");
      }
    },
    error: function (data) {
      toastr["error"](data.mensaje, "Guardar permisos");
    },
  })
}

// EVENTOS
window.addEventListener("load", load_document);

window.onclick = function (event) {
  if (event.target === document.getElementById("myModal-permisos")) {
    $("#myModal-permisos").fadeOut();
  }
};
