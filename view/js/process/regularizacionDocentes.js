let cboDocNombre = document.getElementById("nombre-docente");
let txtDocCodigo = document.getElementById("codigo-docente");
let txtDocDocumento = document.getElementById("doc-docente");
let txtDocEmail = document.getElementById("email-docente");
let doc_id;

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

function comprobarDocenteGuardado(){
    
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
        if (nombre == "sem_codigo") {
            toastr["error"]("Seleccione un semestre", "Envío");
        } else {
            toastr["error"]("El campo " + nombre + " no debe estar vacio", "Envío");
        }
        return false;
    }
}

window.addEventListener("load", load_document);