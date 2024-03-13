<?php 
require_once('../../models/conecction.php');
require_once '../../vendor/autoload.php';

date_default_timezone_set('America/Lima');

session_start();

$sem_id = 0;
$p_uni_id = 0;
$p_pro_id = 0;
$p_cic_id = 0;
$p_cre_id = 0;
$p_cur_id = 0;
$p_gpo_id = 0;
$p_hrs = 0;
$p_doc = 0;
$p_fec = 0;

if (isset($_GET['sem_id']) && isset($_GET['p_uni_id']) && isset($_GET['p_pro_id']) && isset($_GET['p_cic_id']) && isset($_GET['p_cre_id']) 
    && isset($_GET['p_cur_id']) && isset($_GET['p_gpo_id']) && isset($_GET['p_hrs']) && isset($_GET['p_doc']) && isset($_GET['p_fec'])) {
    $sem_id = $_GET['sem_id'];
    $p_uni_id = $_GET['p_uni_id'];
    $p_pro_id = $_GET['p_pro_id'];
    $p_cic_id = $_GET['p_cic_id'];
    $p_cre_id = $_GET['p_cre_id'];
    $p_cur_id = $_GET['p_cur_id'];
    $p_gpo_id = $_GET['p_gpo_id'];
    $p_hrs = $_GET['p_hrs'];
    $p_doc = $_GET['p_doc'];
    $p_fec = $_GET['p_fec'];
}

?>