let cboSemestre = document.getElementById("cboSemestre");
let cboDocNombre = document.getElementById("nombre-docente");
let txtDocCodigo = document.getElementById("codigo-docente");
let txtDocDocumento = document.getElementById("doc-docente");
let txtDocEmail = document.getElementById("email-docente");
let btnActualizar = document.getElementById("btnActualizar");
let sem_id;
let doc_id;

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

function get_docentes() {
  let opcion = "get_docentes";

  $.ajax({
    type: "POST",
    url: "../../controllers/main/CargaHorariaController.php",
    data: "opcion=" + opcion,
    success: function (data) {
      let opciones = data;
      $("#nombre-docente").html(opciones);
    },
    error: function (data) {
      alert("Error al mostrar");
    },
  });
}

async function actualizar_datos_docente() {
  sem_id = cboSemestre.value;
  doc_id = cboDocNombre.value;
  let email_doc = txtDocEmail.value;
  let codigo_doc = txtDocCodigo.value;
  let doc_opcion = $("#nombre-docente option:selected");
  let nombre_doc = doc_opcion.text();
  let dni_doc = txtDocDocumento.value;
  let docente= {
    codigo: codigo_doc,
    documento:dni_doc,
    nombres:nombre_doc,
    email:email_doc
  }
  if ((comprobarCampo(sem_id, "sem_id"), comprobarCampo(doc_id, "doc_id"))) {
    let existe = await comprobar_docente(sem_id, doc_id);
    if (existe.respuesta == 1) {
      if (comprobarCampo(email_doc, "correo") &&comprobarCampo(dni_doc, "DNI") && comprobarCampo(codigo_doc, "codigo")) {
        $.ajax({
          type: "POST",
          url: "../../controllers/main/AsignacionDocentesController.php",
          data: {
            opcion: "actualizar_datos_docentes",
            p_sem_id: sem_id,
            p_doc_id: doc_id,
            p_docente: JSON.stringify(docente)
          },
          beforeSend: function () {
            btnActualizar.disabled = true;
            $('#btnEnviando').show();
            $('#btnActualizar').hide();
          },
          success: function(data){
            let rpta = JSON.parse(data);
            if(rpta.respuesta == 1){
                toastr["success"](rpta.mensaje, "Regularizar datos");
            }else{
                toastr["warning"](rpta.mensaje, "Regularizar datos");
            }
            btnActualizar.disabled = false;
            $('#btnEnviando').hide();
            $('#btnActualizar').show();
          },
          error: function(data){
            toastr["error"]("Ocurrió un error", "Regularizar datos");
          },
        });
      }
    } else {
      toastr["warning"](existe.mensaje, "Regularizar datos");
    }
  }
}

function comprobar_docente(sem_id, doc_id) {
  return new Promise((resolve, reject) => {
    $.ajax({
      type: "POST",
      url: "../../controllers/main/AsignacionDocentesController.php",
      data: {
        opcion: "comprobar_docente",
        p_sem_id: sem_id,
        p_doc_id: doc_id,
      },
      success: function (data) {
        let rpta = JSON.parse(data);
        resolve(rpta);
      },
      error: function (data) {
        reject("Error al mostrar");
      },
    });
  });
}

function seleccionar_datos_docente() {
  doc_id = cboDocNombre.value;
  let doc_opcion = $("#nombre-docente option:selected");
  let doc_documento = doc_opcion.data("documento");
  let doc_email = doc_opcion.data("email");
  let doc_codigo = doc_opcion.data("codigo");
  $("#doc-docente").val(doc_documento);
  $("#email-docente").val(doc_email);
  $("#codigo-docente").val(doc_codigo);
}

function load_document() {
  get_cbo_semestres();
  get_docentes();
  $("#nombre-docente").select2({
    dropdownCssClass: "limitar-opciones",
    placeholder: "Selecciona un docente ...",
  });
  $("#nombre-docente").on("change", function () {
    seleccionar_datos_docente();
  });
}

function comprobarCampo(campo, nombre) {
  if (campo != undefined && campo != null && campo != "") {
    return true;
  } else {
    if (nombre == "sem_id") {
      toastr["error"]("Seleccione un semestre", "Regularizar datos");
    } else if (nombre == "doc_id") {
      toastr["error"]("Seleccione el docente", "Regularizar datos");
    } else {
      toastr["error"](
        "El campo " + nombre + " no debe estar vacio",
        "Regularizar datos"
      );
    }
    return false;
  }
}

window.addEventListener("load", load_document);
