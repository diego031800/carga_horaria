// VARIABLES
let btnAcceso = document.getElementById('btnAcceso');
let txtUsuario = document.getElementById('txtUsuario');
let txtPassword = document.getElementById('txtPassword');

// FUNCIONES
function login()
{
  let opcion = 'login';
  let usuario = txtUsuario.value;
  let password = txtPassword.value;

  $.ajax({
    type: "POST",
    data: "opcion="+opcion+
          "&usuario="+usuario+
          "&password="+password,
    url: "controllers/security/LoginController.php",
    beforesend: function () {
      btnAcceso.disabled = true;
    },
    success: function (data) {
      btnAcceso.disabled = false;
      let objeto = JSON.parse(data);
      if (objeto.respuesta=='Acceso permitido') {
        location.href = "view/process/registrarCargaHoraria.php";
      } else {
        alert(objeto.respuesta);
      }
    },
    error: function(data) {
      alert("Error: "+data);
    }
  });
}

function load_document()
{
  btnAcceso.addEventListener("click", login);
}

// EVENTOS
window.addEventListener("load", load_document);