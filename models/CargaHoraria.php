<?php

    require_once('./conecction.php');

    class CargaHoraria extends connection
    {
        public function get_unidades()
        {
            try {
                $query = "SELECT 
                            SEC.sec_id as id,
                            SEC.sec_descripcion as nombre
                        FROM PROGRAMACION.SEMESTRE_SECCION SSE
                        INNER JOIN ADMISION.SECCION SEC ON SEC.sec_id = SSE.sec_id
                        WHERE SSE.sem_id = 69"; // Tu consulta SQL aquí

                // Preparar la consulta
                $statement = $this->con_sql_server()->prepare($query);

                // Ejecutar la consulta
                $statement->execute();

                // Obtener los resultados
                $results = $statement->fetchAll(PDO::FETCH_ASSOC);

                // Liberar recursos
                $statement->closeCursor();

                return $results; // Devuelve los resultados
            } catch (Exception $ex) {
                die("Error: " . $ex->getMessage());
            }
        }
    } 

    // Crear una instancia de la clase y obtener los datos
    $cargaHoraria = new CargaHoraria();
    $resultados = $cargaHoraria->get_unidades();

    // Procesar los resultados
    foreach ($resultados as $row) {
        // Acceder a los campos de cada fila
        $id = $row['id'];
        $nombre = $row['nombre'];
        // ... y así sucesivamente
    }
?>