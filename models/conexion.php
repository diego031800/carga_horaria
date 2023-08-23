<?php

    require_once('config.php');

    class connection
    {
        private $con_mysql;
        private $con_sqlsrv;

        public function __construct()
        {
            try {
                // MYSQL
                $this->con_mysql = new mysqli("".HOST_MYSQL."","".USER_NAME_MYSQL."","".PASS_MYSQL."","".DB_NAME_MYSQL."");
                // SQL SERVER
                $this->con_sqlsrv = new PDO("sqlsrv:Server=" . HOST_SQL_SERVER . ";Database=" . DB_NAME_SQL_SERVER . "", "" . USER_NAME_SQL_SERVER . "", "" . PASS_SQL_SERVER . "");
            } catch (Exception $ex) {
                die("Error: ".$ex->getMessage());
            }
        }

        // MYSQL
        public function simple_query_mysql($sql)
        {
            $this->con_mysql->query("SET CHARACTER SET UTF8");
            $this->con_mysql->query($sql);
        }

        public function return_query_mysql($sql)
        {
            $this->con_mysql->query("SET CHARACTER SET UTF8");
            $datos = $this->con_mysql->query($sql);
            return $datos;
        }

        public function error_mysql()
        {
            return mysqli_error($this->con_mysql);
        }

        public function close_connection_mysql()
        {
          mysqli_close($this->con_mysql);
        }

        public function close_open_connection_mysql()
        {
            mysqli_close($this->con_mysql);
            $this->con_mysql = new mysqli("".HOST_MYSQL."","".USER_NAME_MYSQL."","".PASS_MYSQL."","".DB_NAME_MYSQL."");
        }

        public function commit_mysql()
        {
            $this->con_mysql->commit();
        }

        public function rollback_mysql()
        {
            $this->con_mysql->rollback();
        }

        // SQL SERVER
        public function simple_query_sqlsrv($sql)
        {
            $this->con_sqlsrv->query($sql);
        }

        public function return_query_sqlsrv($sql)
        {
            $datos = $this->con_sqlsrv->query($sql);
            return $datos;
        }

        public function close_connection_sqlsrv()
        {
          $this->con_sqlsrv = null;
        }

        public function commit_sqlsrv()
        {
            $this->con_sqlsrv->commit();
        }

        public function rollback_sqlsrv()
        {
            $this->con_sqlsrv->rollback();
        }
    }
?>