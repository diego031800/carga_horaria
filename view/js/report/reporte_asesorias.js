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

function buscar() {
    let opcion = "get_asesorias_unidad";
    let p_sem_id = cboSemestre.value ? cboSemestre.value : 0;
    let p_sec_id = cboUnidad.value ? cboUnidad.value : 0;
    if (p_sem_id != 0 && p_sec_id != 0) {
        $.ajax({
            type: "GET",
            url: "../../controllers/report/cursosReportController.php",
            data: {
                opcion: opcion,
                sem_id: p_sem_id,
                sec_id: p_sec_id
            },
            success: function (data) {
                let datos = JSON.parse(data);
                if (datos.respuesta == 1) {
                    console.log(datos.data);
                    mostrar_tabla(datos.data);
                } else {
                    toastr["error"](datos.mensaje, "Obtener datos");
                }
            }
        });
    } else {
        toastr["error"]("Debes escoger un semestre y unidad", "Datos incompletos");
    }
}

function mostrar_tabla(data) {
    $("#table_asesorias").DataTable().destroy();
    $("#table_asesorias").DataTable({
        data: data,
        columns: [
          { data: "Nro", className: "dt-center align-middle" },
          { data: "Programa", className: "dt-center align-middle" },
          { data: "Mencion" , className: "dt-center align-middle" },
          { data: "Alumno", className: "dt-center align-middle" },
          { data: "Curso" , className: "dt-center align-middle" },
          { data: "Ciclo", className: "dt-center align-middle" },
          { data: "CodAses", className: "dt-center align-middle" },
          { data: "DocAses" , className: "dt-center align-middle" },
          { data: "Asesor", className: "dt-center align-middle" },
          { data: "Nota", className: "dt-center align-middle" },
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

/* FUNCION AL CARGAR EL DOCUMENTO */
function load_document() {
    get_cbo_unidades();
    get_cbo_semestres();
    //buscar();
    btnBuscar.addEventListener("click", buscar);
}

// EVENTOS
window.addEventListener("load", load_document);