<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Gestione Preflight: se la richiesta è OPTIONS, rispondi OK e interrompi
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

header("Content-Type: application/json");
require 'db.php';

use Firebase\JWT\JWT;

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->email) && !empty($data->password)) {
    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->execute([$data->email]);
    $user = $stmt->fetch();

    if ($user && password_verify($data->password, $user['password_hash'])) {
        $payload = [
            "iss" => "FunkoPieceApp",
            "iat" => time(),
            "exp" => time() + (3600 * 24 * 30), // Valido per 30 giorni
            "data" => [
                "id" => $user['id'],
                "pirate_name" => $user['pirate_name']
            ]
        ];

        $jwt = JWT::encode($payload, $SECRET_KEY, 'HS256');

        echo json_encode([
            "status" => "success",
            "token" => $jwt,
            "pirate_name" => $user['pirate_name']
        ]);
    } else {
        http_response_code(401);
        echo json_encode(["status" => "error", "message" => "Credenziali errate. Sei una spia della Marina?"]);
    }
}
?>