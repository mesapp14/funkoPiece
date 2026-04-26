<?php
// Abilitiamo la visualizzazione degli errori per il debug (toglilo quando funziona)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require 'db.php'; 

$data = json_decode(file_get_contents("php://input"));

// Controllo se i dati sono arrivati correttamente
if (!$data) {
    echo json_encode(["status" => "error", "message" => "Nessun dato ricevuto dal frontend"]);
    exit;
}

if (!empty($data->email) && !empty($data->password) && !empty($data->pirate_name)) {
    $hashedPassword = password_hash($data->password, PASSWORD_BCRYPT);
    
    // Prepariamo la query (Assicurati che i nomi delle colonne nel DB siano IDENTICI a questi)
    $sql = "INSERT INTO users (pirate_name, email, password_hash, city_name, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    
    try {
        $stmt->execute([
            $data->pirate_name, 
            $data->email, 
            $hashedPassword, 
            $data->city_name ?? null, 
            $data->latitude ?? null, 
            $data->longitude ?? null
        ]);
        echo json_encode(["status" => "success", "message" => "Arruolato con successo!"]);
    } catch (PDOException $e) {
        // Se il server dà errore, ora ti dirà il PERCHÉ (es. colonna mancante)
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Errore DB: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Campi obbligatori mancanti nel payload"]);
}
?>