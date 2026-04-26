<?php
// Header CORS globali
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

header("Content-Type: application/json");
require 'db.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->email)) {
    $stmt = $pdo->prepare("SELECT id, pirate_name FROM users WHERE email = ?");
    $stmt->execute([$data->email]);
    $user = $stmt->fetch();

    if ($user) {
        $tempPassword = substr(str_shuffle("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"), 0, 10);
        $hashedPassword = password_hash($tempPassword, PASSWORD_BCRYPT);

        $updateStmt = $pdo->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
        $updateStmt->execute([$hashedPassword, $user['id']]);

        // --- CONFIGURAZIONE EMAIL ANTI-SPAM ---
        $to = $data->email;
        $subject = "Recupero Password - FunkoPieceApp";
        
        $message = "Ahoy " . $user['pirate_name'] . ",\n\n";
        $message .= "Abbiamo ricevuto una richiesta di recupero password per il tuo account.\n";
        $message .= "La tua nuova password temporanea e': " . $tempPassword . "\n\n";
        $message .= "Accedi all'app e cambiala subito nelle impostazioni.\n\n";
        $message .= "Il Team di FunkoPiece";

        // Headers migliorati per evitare lo spam
        $headers = array(
            "From" => "FunkoPiece App <noreply@alienbash.com>",
            "Reply-To" => "noreply@alienbash.com",
            "X-Mailer" => "PHP/" . phpversion(),
            "MIME-Version" => "1.0",
            "Content-Type" => "text/plain; charset=UTF-8",
            "Message-ID" => "<" . time() . "-" . md5($to) . "@alienbash.com>"
        );

        // Invio con headers formattati correttamente
        mail($to, $subject, $message, $headers);

        echo json_encode(["status" => "success", "message" => "Messaggio in bottiglia inviato! Controlla anche la cartella Spam."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Email non trovata nel registro della ciurma."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Inserisci un'email valida."]);
}
?>