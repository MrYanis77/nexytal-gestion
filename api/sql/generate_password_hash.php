<?php
/**
 * Script one-shot : génère un hash bcrypt pour un mot de passe.
 * Uploadez sur le serveur, ouvrez dans le navigateur, puis SUPPRIMEZ le fichier.
 *
 * Exemple : https://connexion.nexytal.com/api/sql/generate_password_hash.php?password=VotreMotDePasse
 */

header('Content-Type: text/plain; charset=utf-8');

$password = $_GET['password'] ?? 'Nexytal@2024!';

if (strlen($password) < 8) {
    http_response_code(400);
    echo "Mot de passe trop court (min 8 caractères).\n";
    exit;
}

$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);

echo "Mot de passe : {$password}\n";
echo "Hash bcrypt  : {$hash}\n\n";
echo "SQL UPDATE :\n";
echo "UPDATE core_admin_users SET password_hash = '{$hash}', updated_at = NOW() WHERE email = 'admin@nexytal.com';\n";
