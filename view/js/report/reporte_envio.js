let cboSemestre = document.getElementById('cboSemestre');
let cboUnidad = document.getElementById('cboUnidad');
let cboTipoDocente = document.getElementById('cboTipoDocente');

let txt_fecha = document.getElementById("newTratFechaIni_Fecha");
let txt_mes = document.getElementById("newTratFechaIni_Mes");

let tglFecha_Mes = document.getElementById('tglFecha_Mes');
let tglActivar_busqueda_fecha = document.getElementById('tglActivar_busqueda_fecha');

let btnBuscar = document.getElementById('btnBuscar');
let btnImprimir = document.getElementById('btnImprimir');

let sem_id;
let sec_id;
let is_asesor;
let busqueda_fecha;
let busqueda_mes;
let month;
let year;
let estado_busqueda = 1;
let estado_resultado = 1;

let data_envio;
let data_respuesta = [];


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

function buscar() {
    if (comprobar_campo()) {
        is_asesor = cboTipoDocente.value;
        if (estado_busqueda == 3) {
            var partes = busqueda_mes.split("/");
            month = partes[0];
            year = partes[1];
        }
        $.ajax({
            type: 'GET',
            url: "../../controllers/report/enviocredencialesReportController.php",
            data: {
                opcion_busqueda: estado_busqueda,
                sem_id: sem_id,
                sec_id: sec_id,
                is_asesor: is_asesor,
                fecha: busqueda_fecha,
                month: month,
                year: year
            },
            success: function (data) {
                let datos = JSON.parse(data);
                if (datos.respuesta == 1) {
                    console.log(datos.data);
                    if (datos.data.length != 0) {
                        data_respuesta = datos.data;
                        btnImprimir.disabled = false;
                        estado_resultado = estado_busqueda;
                    } else {
                        btnImprimir.disabled = true;
                    }
                    mostrar_tabla(datos.data);
                } else {
                    toastr["error"](datos.mensaje, "Obtener datos");
                }
            }
        })
    }
}

function mostrar_tabla(data) {
    $("#table_asesorias").DataTable().destroy();
    $("#table_asesorias").DataTable({
        data: data,
        columns: [
            { data: "nro", className: "dt-center align-middle" },
            { data: "idDocente", className: "dt-center align-middle" },
            { data: "nombre", className: "dt-center align-middle" },
            { data: "correo", className: "dt-center align-middle" },
            { data: "envio", className: "dt-center align-middle" },
            { data: "fechahora", className: "dt-center align-middle" },
            { data: "error", className: "dt-center align-middle" },
        ],
        responsive: true,
        select: true,
        lengthMenu: [10, 15, 20, 25],
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

/* =============================== COMPROBAR QUE NO HAYA CAMPOS VACÍOS ================================================ */

function comprobar_campo() {
    sem_id = cboSemestre.value;
    sec_id = cboUnidad.value;
    estado = false;
    if (sem_id != 0 && sec_id != 0) {
        if (estado_busqueda == 1) {
            estado = true;
        } else if (estado_busqueda == 2) {
            busqueda_fecha = txt_fecha.value != '' ? txt_fecha.value : 0;
            if (busqueda_fecha != 0) {
                estado = true;
            } else {
                toastr["error"]("Debe ingresar la fecha", "Datos incompletos");
                estado = false;
            }
        } else if (estado_busqueda == 3) {
            busqueda_mes = txt_mes.value != '' ? txt_mes.value : 0;
            if (busqueda_mes != 0) {
                estado = true;
            } else {
                toastr["error"]("Debe ingresar el mes y año", "Datos incompletos");
                estado = false;
            }
        }
    } else {
        toastr["error"]("Debes escoger un semestre y unidad", "Datos incompletos");
        estado = false;
    }
    return estado;
}

/* =============================================================================== */

function imprimir_reporte() {
    sem_txt = cboSemestre.options[cboSemestre.selectedIndex].text;
    sec_txt = cboUnidad.options[cboUnidad.selectedIndex].text;
    is_asesor = cboTipoDocente.value;
    $.ajax({
        type: "POST",
        url: "pdfEnvio.php", // Reemplaza esto con la URL de tu servidor
        data: {
            semTxt: sem_txt,
            secTxt: sec_txt,
            is_asesor : is_asesor,
            estado_resultado: estado_resultado,
            docs: JSON.stringify(data_respuesta),
            fecha: busqueda_fecha,
            month: month,
            year: year
        }, xhrFields: {
            responseType: 'blob'
        },
        success: function (response, status, xhr) {
            try {
                //Obtenemos la respuesta para convertirla a blob
                var blob = new Blob([response], { type: 'application/pdf' });
                var URL = window.URL || window.webkitURL;
                //Creamos objeto URL
                var downloadUrl = URL.createObjectURL(blob);
                //Abrir en una nueva pestaña
                window.open(downloadUrl);
            } catch (ex) {
                console.log(ex);
            }
        },
        error: function (error) {
            console.error("Error en la solicitud AJAX:", error);
        }
    });
}

// FUNCIONALIDADES 
function cambio_tgl_buscar_fecha_mes() {
    if (tglFecha_Mes.checked) {
        $('#newTratFechaInii_Mes').show();
        $('#bot_label_mes').show();
        $('#newTratFechaInii_Fecha').hide();
        $('#bot_label_fecha').hide();
        $(".datepicker3").datepicker("clearDates");
        estado_busqueda = 3;
    } else {
        $('#newTratFechaInii_Mes').hide();
        $('#bot_label_mes').hide();
        $('#newTratFechaInii_Fecha').show();
        $('#bot_label_fecha').show();
        $(".datepicker4").datepicker("clearDates");
        estado_busqueda = 2;
    }
}

function activar_filtro_fecha() {
    if (tglActivar_busqueda_fecha.checked) {
        $('#filtros_fechas').show();
        cambio_tgl_buscar_fecha_mes();
    } else {
        $('#filtros_fechas').hide();
        estado_busqueda = 1;
        $(".datepicker3").datepicker("clearDates");
        $(".datepicker4").datepicker("clearDates");
    }
}

function load_document() {
    get_cbo_unidades();
    get_cbo_semestres();
    activar_filtro_fecha();
    btnBuscar.addEventListener("click", buscar);
    btnImprimir.addEventListener("click", imprimir_reporte);
    tglFecha_Mes.addEventListener("change", cambio_tgl_buscar_fecha_mes);
    tglActivar_busqueda_fecha.addEventListener("change", activar_filtro_fecha);
}

// EVENTOS
window.addEventListener("load", load_document);