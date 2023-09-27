 <?php

    include_once '../../models/config.php';

    // Obtener la URL actual
    $currentUrl = $_SERVER['REQUEST_URI'];

    // Definir los enlaces y sus URLs correspondientes
    $menuItems = array(
        [
            'name' => 'Mis cargas horarias',
            'url' => '/carga_horaria/view/process/misCargasHorarias.php', 
            'parent_id' => '1'
        ],
        [ 
            'name' => 'Enviar credenciales',
            'url' => '/carga_horaria/view/process/envioCredenciales.php', 
            'parent_id' => '2'
        ],
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
                     <li <?php if (isParentActive($menuItems, $currentUrl, 1)) echo 'class="active"'; ?>>
                         <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-table"></i><span>Carga horaria</span></a>
                         <ul class="collapse">
                             <?php foreach ($menuItems as $item) { 
                                if ($item['parent_id'] == 1) { ?>
                                 <li <?php if ($currentUrl === $item['url']) echo 'class="active"'; ?>>
                                     <a href="<?php echo $item['url']; ?>"><?php echo $item['name']; ?></a>
                                 </li>
                             <?php 
                                  }
                                } ?>
                         </ul>
                     </li>
                     <li <?php if (isParentActive($menuItems, $currentUrl, 2)) echo 'class="active"'; ?>>
                         <a href="javascript:void(0)" aria-expanded="true"><i class="fa fa-user"></i><span> Acciones docentes</span></a>
                         <ul class="collapse">
                             <?php foreach ($menuItems as $item) { 
                                if ($item['parent_id'] == 2) { ?>
                                 <li <?php if ($currentUrl === $item['url']) echo 'class="active"'; ?>>
                                     <a href="<?php echo $item['url']; ?>"><?php echo $item['name']; ?></a>
                                 </li>
                             <?php 
                                  }
                                } ?>
                         </ul>
                     </li>
                 </ul>
             </nav>
         </div>
     </div>
 </div>
 <!-- sidebar menu area end -->

 <?php
    function isParentActive($menuItems, $currentUrl, $parent_id)
    {
        foreach ($menuItems as $item) {
            if ($parent_id == $item['parent_id']) {
                if ($currentUrl === $item['url']) {
                    return true;
                }
            }
        }
        return false;
    }
    ?>