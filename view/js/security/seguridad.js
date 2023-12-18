function buscar() {
    let opcion = "get_usuarios";
    $.ajax({
      type: "POST",
      url: "../../controllers/security/seguridadController.php",
      data: "opcion=" + opcion,
      beforeSend: function () {
        let spinner = '<div class="d-flex justify-content-center mt-5"><div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status"><span class="visually-hidden">Loading...</span></div></div>'
        $('#cuerpo_asignacion').html('');
        $('#tbl_spinner').html(spinner);
      },
      success: function (data) {
        let datos = JSON.parse(data);
        $('#cuerpo_asignacion').html('');
        $('#tbl_spinner').html('');
        $('#table_ch').DataTable().destroy();
        $('#table_ch').DataTable({
          data: datos,
          columns: [
            { data: 'nro', className: 'dt-center align-middle' },
            { data: 'acciones', className: 'dt-center align-middle' },
            { data: 'docente', className: 'dt-center align-middle' },
            { data: 'correo', className: 'dt-center align-middle' }
          ],
          responsive: true,
          select: true,
          lengthMenu: [5, 10, 15, 20, 25],
          columnDefs: [
            {
              targets: -1,
              className: 'dt-center'
            }
          ],
          language: {
            search: "Buscar",
            zeroRecords: "Sin Resultados Coincidentes",
            paginate: {
              first: "Primera",
              last: "Ultima",
              next: "Siguiente",
              previous: "Anterior"
            },
            info: "Mostrando _START_ de _END_ de un total de _TOTAL_ Registros",
          },
          dom: '<"row"<"col-md-6"l><"col-md-6"f>>tp',
          createdCell: function (cell, cellData, rowData, rowIndex, colIndex) {
            if (colIndex === 4) {
              $(cell).css('background-color', '#ffcc00');
            }
          }
        });
      },
      error: function (data) {
        alert("Error al mostrar");
      },
    });
  }