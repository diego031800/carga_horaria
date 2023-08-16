<?php
    class connection
    {
        function con_sql_server()
        {
            try {
                require_once('config.php');
                $connection_string = new PDO("sqlsrv:server=".HOST_SQL_SERVER."; DATABASE=".DB_NAME_SQL_SERVER."", "".USER_NAME_SQL_SERVER."", "".PASS_SQL_SERVER."");
                return $connection_string;
            } catch (Exception $ex) {
                die("Error: ". $ex->getMessage());
            }
        }

        function con_mysql()
        {
            try {
                require_once('config.php');
                $connection_string = new PDO("mysql:host=".HOST_MYSQL.";dbname=".DB_NAME_MYSQL."", "".USER_NAME_MYSQL."", "".PASS_MYSQL."");
                return $connection_string;
            } catch (Exception $ex) {
                
            }
        }
    }
?>