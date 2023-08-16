<?php
// Configuración de la base de datos
$server = 'YURIFOX\MSSQLSERVER_2017'; // Puede ser una dirección IP o un nombre de servidor
$db_name = 'is_posgrado';
$username = 'sa';
$password = '1478963sws**';

// Intentar establecer la conexión a la base de datos
try {
    $connectionOptions = array(
        "Database" => $db_name,
        "Uid" => $username,
        "PWD" => $password
    );

    $db = sqlsrv_connect($server, $connectionOptions);

    if ($db === false) {
        die("Error de conexión: " . sqlsrv_errors());
    } else {
        echo "Conexión exitosa a la base de datos";
    }
} catch (Exception $e) {
    echo "Error de conexión: " . $e->getMessage();
}
?>