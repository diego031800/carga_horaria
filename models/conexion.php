<?php

    require_once('config.php');

    class connection
    {
        private $con_mysql;
        private $con_sqlsrv;

        public function __construct()
        {
            try {
              $this->con_mysql = new mysqli("".HOST_MYSQL."","".USER_NAME_MYSQL."","".PASS_MYSQL."","".DB_NAME_MYSQL."");
            } catch (Exception $ex) {
                die("Error: ".$ex->getMessage());
            }
        }

        public function simple_query($sql)
        {
            $this->con_mysql->query("SET CHARACTER SET UTF8");
            $this->con_mysql->query($sql);
        }

        public function return_query($sql)
        {
            $this->con_mysql->query("SET CHARACTER SET UTF8");
            $datos = $this->con_mysql->query($sql);
            return $datos;
        }

        public function close_connection()
        {
          mysqli_close($this->con_mysql);
        }

        public function commit()
        {
            $this->con_mysql->commit();
        }

        public function rollback()
        {
            $this->con_mysql->rollback();
        }
    }
?>