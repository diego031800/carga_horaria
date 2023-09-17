 <?php

    include_once '../../models/config.php';

    // Obtener la URL actual
    $currentUrl = $_SERVER['REQUEST_URI'];

    // Definir los enlaces y sus URLs correspondientes
    $menuItems = array(
        'Mis cargas horarias' => '/carga_horaria/view/process/misCargasHorarias.php',   // Ruta relativa
        // 'Nueva carga horaria' => '/carga_horaria/view/process/registrarCargaHoraria.php', // Ruta relativa
        // 'Ver carga horaria general' => '/carga_horaria/view/process/verCargaHoraria.php',   // Ruta relativa
        'Ver carga horaria' => '/carga_horaria/view/process/verCargaHoraria.php'   // Ruta relativa
    );

    ?>

 <!-- sidebar menu area start -->
 <div class="sidebar-menu">
     <div class="sidebar-header">
         <div class="logo" style="height: 100px; width:auto;">
             <a href="../../view/process/misCargasHorarias.php" style="max-width: 316px;"><img src='../../assets/images/documentos/img_upg_RGB_blanco.png' style="height: auto; width: 280px;"></a>
         </div>
     </div>
     <div class="main-menu">
         <div class="menu-inner">
             <nav>
                 <ul class="metismenu" id="menu">
                     <li <?php if (isParentActive($menuItems, $currentUrl)) echo 'class="active"'; ?>>
                         <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-table"></i><span>Carga horaria</span></a>
                         <ul class="collapse">
                             <?php foreach ($menuItems as $itemName => $itemUrl) { ?>
                                 <li <?php if ($currentUrl === $itemUrl) echo 'class="active"'; ?>>
                                     <a href="<?php echo $itemUrl; ?>"><?php echo $itemName; ?></a>
                                 </li>
                             <?php } ?>
                         </ul>
                     </li>
                 </ul>
             </nav>
         </div>
     </div>
 </div>
 <!-- sidebar menu area end -->

 <?php
    function isParentActive($menuItems, $currentUrl)
    {
        foreach ($menuItems as $itemUrl) {
            if ($currentUrl === $itemUrl) {
                return true;
            }
        }
        return false;
    }
    ?>