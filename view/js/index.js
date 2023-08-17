// VARIABLES
let array_unidades = [];

// FUNCIONES
function get_unidades()
{
  let opcion = 'get_unidades';
  $.ajax({
    type: "POST",
    url: '../../../carga_horaria/controllers/main/CargaHorariaController.php',
    data: 'opcion='+opcion,
    success: function (data) {
      array_unidades = JSON.parse(data);
      console.log(array_unidades);
    },
    error:function (data) 
    { 
      alert('Error al mostrar');
    }
  });
}

function load_document()
{
  get_unidades();
}

// EVENTOS
window.addEventListener("load", load_document);