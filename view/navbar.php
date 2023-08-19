<?php
include_once '../models/config.php';
?>

<nav class="navbar navbar-default navbar-fixed-top">
  <div class="brand">
    <a href=""><img src="assets/img/logo-dark.png" alt="Klorofil Logo" class="img-responsive logo"></a>
  </div>
  <div class="container-fluid">
    <div class="navbar-btn">
      <button type="button" class="btn-toggle-fullwidth"><i class="lnr lnr-arrow-left-circle"></i></button>
    </div>
    <div id="navbar-menu">
      <ul class="nav navbar-nav navbar-right">
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown"><img src="assets/img/user.png" class="img-circle" alt="Avatar"> <span>Samuel</span> <i class="icon-submenu lnr lnr-chevron-down"></i></a>
          <ul class="dropdown-menu">
            <li><a href="../../carga_horaria/controllers/security/LogoutController.php"><i class="lnr lnr-exit"></i> <span>Logout</span></a></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>