<?php
// Header CORS globali
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

header("Content-Type: application/json");

// Percorso corretto basato sulla tua struttura: backend/composer/vendor/...
require_once __DIR__ . '/../composer/vendor/autoload.php';

// Carichiamo le variabili dal file .env
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->load();

$host = $_ENV['DB_HOST'];
$db   = $_ENV['DB_NAME'];
$user = $_ENV['DB_USER'];
$pass = $_ENV['DB_PASS'];
$SECRET_KEY = $_ENV['JWT_SECRET'];

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
} catch (PDOException $e) {
    // Questo ci dirà SE il problema sono le credenziali o altro
    die(json_encode([
        "status" => "error", 
        "message" => "Errore DB: " . $e->getMessage(),
        "debug_info" => [
            "host" => $_ENV['DB_HOST'] ?? 'Variabile non caricata',
            "user" => $_ENV['DB_USER'] ?? 'Variabile non caricata'
        ]
    ]));
}
?>