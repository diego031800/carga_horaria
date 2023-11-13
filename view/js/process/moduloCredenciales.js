let cboDocNombre = document.getElementById("nombre-docente");
let txtDocCodigo = document.getElementById("codigo-docente");
let txtDocDocumento = document.getElementById("doc-docente");
let txtDocEmail = document.getElementById("email-docente");

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

function seleccionar_datos_docente() {
    let doc_opcion = $("#nombre-docente option:selected");
    let doc_documento = doc_opcion.data("documento");
    let doc_email = doc_opcion.data("email");
    let doc_codigo = doc_opcion.data("codigo");
    $("#doc-docente").val(doc_documento);
    $("#email-docente").val(doc_email);
    $("#codigo-docente").val(doc_codigo);
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

function enviarCred() {
    let email_doc = txtDocEmail.value;
    let codigo_doc = txtDocCodigo.value;
    let doc_opcion = $("#nombre-docente option:selected");
    let nombre_doc = doc_opcion.text();
    let dni_doc = txtDocDocumento.value;
    let sem_option = $("#cboSemestre option:selected");
    let sem_codigo = sem_option.data("codigo");
    if (comprobarCampo(email_doc, "correo") && comprobarCampo(codigo_doc, "codigo") && comprobarCampo(nombre_doc, "nombre") && comprobarCampo(dni_doc, "DNI") && comprobarCampo(sem_codigo, "sem_codigo")) {
        $.ajax({
            type: 'post',
            url: '../../controllers/main/miniModulo.php',
            data: {
                correo: email_doc,
                codigo_docente: codigo_doc,
                nombre: nombre_doc,
                dni: dni_doc,
                semestre: sem_codigo
            },
            beforeSend: function () {
                $("#btnEnviar").prop("disabled", true);
                $('#btnEnviando').show();
                $('#btnEnviar').hide();
            },
            success: function (data) {
                if(data == "SI"){
                    toastr["success"]("Envío de correo", "Envío exitoso");
                }else{
                    toastr["error"]("Envío de correo","Error en el envio");
                }
                $('#btnEnviar').show();
                $('#btnEnviando').hide();
                btnEnviar.disabled = false;
            },
            error: function (data) {
                btnEnviar.disabled = false; // Habilitar el botón nuevamente
                toastr["error"]("Envío de correo", "Hubo un error en el envío");
            }
        })
    }
}
function comprobarCampo(campo, nombre) {
    if (campo != undefined && campo != null && campo != "") {
        return true;
    } else {
        if (nombre == "sem_codigo") {
            toastr["error"]("Seleccione un semestre", "Envío");
        } else {
            toastr["error"]("El campo " + nombre + " no debe estar vacio", "Envío");
        }
        return false;
    }
}
window.addEventListener("load", load_document);