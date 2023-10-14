<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- ICONO DE LA PAG WEB -->
    <link rel="icon" href="./assets/images/untr.ico">
    <link rel="stylesheet" href="./assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="./view/css/login.css">
    <title>Login</title>
</head>

<body>
    <div class="vh-100 bg-image"></div>
    <div class="container py-5 h-100 style-container">
        <div class="row d-flex justify-content-center align-items-center h-100">
            <div class="col-12 col-md-8 col-lg-6 col-xl-5">
                <div class="card shadow-2-strong style-card" style="border-radius: 1rem;">
                    <div class="card-body p-5 text-center">
                        <input type="hidden" id="txtUserIp" value="<?php echo $_SERVER['REMOTE_ADDR']; ?>">
                        <div class="row mb-5">
                            <div class="col-12">
                                <img class="img-fluid" src="./assets/images/documentos/img_upg_RGB_blanco.png" alt="">
                            </div>
                        </div>
                        <div class="input-group form-outline mb-4">
                            <span class="input-group-text"><img src="./assets/images/user_icon.svg" style="width: 22px;" alt="usuario"></span>
                            <div class="form-floating">
                                <input type="text" class="form-control" id="txtUsuario" placeholder="Usuario" style="color: black;">
                                <label for="txtUsuario">Usuario</label>
                            </div>
                        </div>
                        <div class="input-group form-outline mb-4">
                            <span class="input-group-text"><img src="./assets/images/key_icon.svg" style="width: 22px;" alt="password"></span>
                            <div class="form-floating">
                                <input type="password" class="form-control" id="txtPassword" placeholder="Password" style="color: black;">
                                <label for="txtPassword">Password</label>
                            </div>
                        </div>
                        <!-- <div class="form-check d-flex justify-content-start mb-4">
                                <input class="form-check-input" type="checkbox" value="" id="form1Example3" />
                                <label class="form-check-label" for="form1Example3"> Remember password </label>
                            </div> -->
                        <div class="col-12 d-flex justify-content-center align-items-center">
                            <button class="btn btn-primary btn-lg btn-block d-flex justify-content-center align-items-center" type="submit" id="btnAcceso">
                                <div class="spinner-border text-light" style="display: none;" role="status" id="spnLoading">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <div id="txtLoading" style="display: none;">&nbsp;&nbsp;&nbsp; Iniciando ...</div>
                                <div id="txtNoLoading">Iniciar Sesión</div>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<script src="./assets/js/jquery-3.7.0.min.js"></script>
<script src="./assets/js/bootstrap.min.js"></script>
<script src="./view/js/security/login.js"></script>

</html>