<?php

    require_once('config.php');

    class connection
    {
        private $con_mysql;
        private $con_sqlsrv;

        public function __construct()
        {
            try {
                $options = [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ];
                $this->con_mysql = new PDO("mysql:host=" . HOST_MYSQL . ";dbname=" . DB_NAME_MYSQL . "", "" . USER_NAME_MYSQL . "", "" . PASS_MYSQL . "", $options);
            } catch (PDOException $ex) {
                die("Error: ".$ex->getMessage());
            }
        }

        public function simple_query($sql)
        {
            $this->con_mysql->prepare("SET CHARACTER SET UTF8")->execute();
            $statement = $this->con_mysql->prepare($sql);
            $statement->execute();
        }

        public function return_query($sql)
        {
            $this->con_mysql->prepare("SET CHARACTER SET UTF8")->execute();
            $statement = $this->con_mysql->prepare($sql);
            $statement->execute();
            $datos = $statement->fetchAll();
            return $datos;
        }

        function __destruct()
        {
            $this->con_mysql = null; // Cerrar la conexión
        }

        public function commit()
        {
            $this->con_mysql->commit();
        }

        public function rollback()
        {
            $this->con_mysql->rollback();
        }

        /* function con_sql_server()
        {
            try {
                $connection_string = new PDO("sqlsrv:server=".HOST_SQL_SERVER."; DATABASE=".DB_NAME_SQL_SERVER."", "".USER_NAME_SQL_SERVER."", "".PASS_SQL_SERVER."");
                return $connection_string;
            } catch (Exception $ex) {
                die("Error: ". $ex->getMessage());
            }
        }

        function con_mysql()
        {
            try {
                $connection_string = new PDO("mysql:host=".HOST_MYSQL.";dbname=".DB_NAME_MYSQL."", "".USER_NAME_MYSQL."", "".PASS_MYSQL."");
                return $connection_string;
            } catch (Exception $ex) {
                
            }
        } */
    }
?>