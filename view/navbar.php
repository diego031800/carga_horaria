<?php

include_once '../../models/config.php';

?>

<!-- header area start -->
<div class="header-area">
    <div class="row align-items-center">
        <!-- nav and search button -->
        <div class="col-md-6 col-sm-8 clearfix">
            <div class="nav-btn pull-left">
                <span></span>
                <span></span>
                <span></span>
            </div>
            <!-- <div class="search-box pull-left">
                <form action="#">
                    <input type="text" name="search" placeholder="Search..." required>
                    <i class="ti-search"></i>
                </form>
            </div> -->
        </div>
        <!-- profile info & task notification -->
        <div class="col-md-6 col-sm-4 clearfix">
            <ul class="notification-area pull-right">
                <li id="full-view"><i class="ti-fullscreen"></i></li>
                <li id="full-view-exit"><i class="ti-zoom-out"></i></li>
            </ul>
        </div>
    </div>
</div>
<!-- header area end -->
<!-- page title area start -->
<div class="page-title-area">
    <div class="row align-items-center">
        <div class="col-sm-8">
            <div class="breadcrumbs-area clearfix">
                <h4 class="page-title pull-left">Carga Horaria</h4>
                <ul class="breadcrumbs pull-left">
                    <li><a href="./misCargasHorarias.php">Home</a></li>
                    <li><span>Registro</span></li>
                </ul>
            </div>
        </div>
        <div class="col-sm-4 clearfix">
            <div class="user-profile pull-right">
                <img class="avatar user-thumb" src="../../assets/images/author/avatar.png" alt="avatar">
                <h5 class="user-name dropdown-toggle" data-toggle="dropdown"><?php echo $_SESSION['nombres'] ?><i class="fa fa-angle-down"></i></h5>
                <div class="dropdown-menu">
                    <a class="dropdown-item" href="../../controllers/security/LogoutController.php">
                        <svg xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 512 512"><!--! Font Awesome Free 6.4.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license (Commercial License) Copyright 2023 Fonticons, Inc. -->
                            <path fill='#007BFF' d="M288 32c0-17.7-14.3-32-32-32s-32 14.3-32 32V256c0 17.7 14.3 32 32 32s32-14.3 32-32V32zM143.5 120.6c13.6-11.3 15.4-31.5 4.1-45.1s-31.5-15.4-45.1-4.1C49.7 115.4 16 181.8 16 256c0 132.5 107.5 240 240 240s240-107.5 240-240c0-74.2-33.8-140.6-86.6-184.6c-13.6-11.3-33.8-9.4-45.1 4.1s-9.4 33.8 4.1 45.1c38.9 32.3 63.5 81 63.5 135.4c0 97.2-78.8 176-176 176s-176-78.8-176-176c0-54.4 24.7-103.1 63.5-135.4z" />
                        </svg>
                        &nbsp; Log Out
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- page title area end -->