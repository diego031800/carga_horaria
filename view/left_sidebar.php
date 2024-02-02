 <?php

    include_once '../../models/config.php';
    include_once '../../models/main/Menu.php';

    $menuItems1 = $_SESSION['menu'];
    $parents = $_SESSION['parents'];
    $currentUrl = $_SERVER['REQUEST_URI'];

    ?>

 <!-- sidebar menu area start -->
 <div class="sidebar-menu">
     <div class="sidebar-header">
         <div class="logo" style="height: 100px; width:auto;">
             <a href="../../view/process/misCargasHorarias.php" style="max-width: 316px;"><img
                     src='../../assets/images/documentos/img_upg_RGB_blanco.png'
                     style="height: auto; width: 280px;"></a>
         </div>
     </div>
     <div class="main-menu">
         <div class="menu-inner">
             <nav>
                 <ul class="metismenu" id="menu">
                     <?php foreach ($parents as $itemp) {
                        ?>
                     <li <?php if (isParentActive($menuItems1, $currentUrl, $itemp['id'])) echo 'class="active"'; ?>>
                         <a href="javascript:void(0)" aria-expanded="true"><i
                                 class="<?php echo $itemp['icon']; ?>"></i><span>
                                 <?php echo $itemp['name']; ?></span></a>
                         <ul class="collapse">
                             <?php foreach ($menuItems1 as $item) {
                                    if ($item['parent_id'] == $itemp['id']) { ?>
                             <li <?php if ($currentUrl === $item['url']) echo 'class="active"'; ?>>
                                 <a href="<?php echo $item['url']; ?>"
                                     <?php if (!Permiso($item['id'])) echo 'style="display: none;"' ?>><?php echo $item['name']; ?></a>
                             </li>
                             <?php
                                    }
                                } ?>

                         </ul>
                     </li>
                     <?php
                        }
                        ?>
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

    function Permiso($id_pag)
    {
        if (in_array($id_pag, $_SESSION['permisos'])) {
            return true;
        } else {
            return false;
        }
    }
    ?>