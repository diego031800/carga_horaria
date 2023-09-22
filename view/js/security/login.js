// VARIABLES
let btnAcceso = document.getElementById('btnAcceso');
let txtUsuario = document.getElementById('txtUsuario');
let txtPassword = document.getElementById('txtPassword');
let txtUserIp = document.getElementById('txtUserIp');

// FUNCIONES
function login()
{
  let opcion = 'login';
  let usuario = txtUsuario.value;
  let password = txtPassword.value;
  let ip = txtUserIp.value;

  $.ajax({
    type: "POST",
    data: "opcion="+opcion+
          "&usuario="+usuario+
          "&password="+password+
          "&ip="+ip,
    url: "controllers/security/LoginController.php",
    beforeSend: function () {
      btnAcceso.disabled = true;
    },
    success: function (data) {
      btnAcceso.disabled = false;
      let objeto = JSON.parse(data);
      if (objeto.respuesta=='Acceso permitido') {
        location.href = "view/process/misCargasHorarias.php";
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
  txtUsuario.addEventListener("keydown", (event) => {
    if (event.key === 'Enter')
      btnAcceso.click();
  })
  txtPassword.addEventListener("keydown", (event) => {
    if (event.key === 'Enter')
      btnAcceso.click();
  })
}

// EVENTOS
window.addEventListener("load", load_document);