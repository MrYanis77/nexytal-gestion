<?php
/**
 * Envoi d'emails via SMTP Ionos (ssl://host:465).
 * Variables .env : SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SMTP_ENCRYPTION,
 * MAIL_FROM, MAIL_FROM_NAME
 */

class Mail
{
    public static function isConfigured(): bool
    {
        return self::smtpHost() !== '' && self::smtpUser() !== '' && self::smtpPassword() !== '';
    }

    public static function fromAddress(): string
    {
        return (string) env('MAIL_FROM', env('SMTP_USER', 'contact@nexytal.com'));
    }

    public static function fromName(): string
    {
        return (string) env('MAIL_FROM_NAME', 'Nexytal');
    }

    /**
     * @param array{from_name?: string, reply_to?: string} $options
     */
    public static function send(string $to, string $subject, string $bodyText, array $options = []): bool
    {
        $to = trim($to);
        if ($to === '' || !filter_var($to, FILTER_VALIDATE_EMAIL)) {
            error_log('[Mail] Destinataire invalide: ' . $to);
            return false;
        }

        if (!self::isConfigured()) {
            error_log("[Mail] SMTP non configuré — email non envoyé à {$to} : {$subject}");
            return false;
        }

        try {
            return self::smtpSend($to, $subject, $bodyText, $options);
        } catch (\Throwable $e) {
            error_log('[Mail] Erreur SMTP: ' . $e->getMessage());
            return false;
        }
    }

    private static function smtpHost(): string
    {
        return trim((string) env('SMTP_HOST', ''));
    }

    private static function smtpPort(): int
    {
        return (int) env('SMTP_PORT', '465');
    }

    private static function smtpUser(): string
    {
        return trim((string) env('SMTP_USER', ''));
    }

    private static function smtpPassword(): string
    {
        return (string) env('SMTP_PASSWORD', '');
    }

    private static function smtpEncryption(): string
    {
        return strtolower(trim((string) env('SMTP_ENCRYPTION', 'ssl')));
    }

    /**
     * @param array{from_name?: string, reply_to?: string} $options
     */
    private static function smtpSend(string $to, string $subject, string $bodyText, array $options): bool
    {
        $host = self::smtpHost();
        $port = self::smtpPort();
        $enc = self::smtpEncryption();
        $remote = ($enc === 'ssl' ? 'ssl://' : '') . $host . ':' . $port;

        $socket = @stream_socket_client(
            $remote,
            $errno,
            $errstr,
            20,
            STREAM_CLIENT_CONNECT,
            stream_context_create(['ssl' => ['verify_peer' => true, 'verify_peer_name' => true]])
        );

        if (!$socket) {
            throw new \RuntimeException("Connexion SMTP impossible ({$errno}): {$errstr}");
        }

        stream_set_timeout($socket, 20);

        self::smtpExpect($socket, [220]);

        $ehloHost = (string) env('MAIL_EHLO_DOMAIN', 'nexytal.com');
        self::smtpWrite($socket, "EHLO {$ehloHost}\r\n");
        self::smtpExpect($socket, [250]);

        self::smtpWrite($socket, "AUTH LOGIN\r\n");
        self::smtpExpect($socket, [334]);
        self::smtpWrite($socket, base64_encode(self::smtpUser()) . "\r\n");
        self::smtpExpect($socket, [334]);
        self::smtpWrite($socket, base64_encode(self::smtpPassword()) . "\r\n");
        self::smtpExpect($socket, [235]);

        $from = self::fromAddress();
        $fromName = $options['from_name'] ?? self::fromName();
        $encodedSubject = self::encodeHeader($subject);
        $encodedFromName = self::encodeHeader($fromName);

        self::smtpWrite($socket, "MAIL FROM:<{$from}>\r\n");
        self::smtpExpect($socket, [250]);
        self::smtpWrite($socket, "RCPT TO:<{$to}>\r\n");
        self::smtpExpect($socket, [250, 251]);
        self::smtpWrite($socket, "DATA\r\n");
        self::smtpExpect($socket, [354]);

        $headers = [
            "From: {$encodedFromName} <{$from}>",
            "To: {$to}",
            "Subject: {$encodedSubject}",
            'MIME-Version: 1.0',
            'Content-Type: text/plain; charset=UTF-8',
            'Content-Transfer-Encoding: 8bit',
            'Date: ' . date('r'),
        ];

        if (!empty($options['reply_to']) && filter_var($options['reply_to'], FILTER_VALIDATE_EMAIL)) {
            $headers[] = 'Reply-To: ' . $options['reply_to'];
        }

        $bodyText = str_replace(["\r\n", "\r"], "\n", $bodyText);
        $bodyText = preg_replace('/^\./m', '..', $bodyText) ?? $bodyText;

        $message = implode("\r\n", $headers) . "\r\n\r\n" . $bodyText . "\r\n.\r\n";
        self::smtpWrite($socket, $message);
        self::smtpExpect($socket, [250]);

        self::smtpWrite($socket, "QUIT\r\n");
        fclose($socket);

        return true;
    }

    private static function smtpWrite($socket, string $data): void
    {
        $written = fwrite($socket, $data);
        if ($written === false) {
            throw new \RuntimeException('Échec écriture SMTP');
        }
    }

    /** @param int[] $expectedCodes */
    private static function smtpExpect($socket, array $expectedCodes): void
    {
        $response = '';
        while (($line = fgets($socket, 515)) !== false) {
            $response .= $line;
            if (isset($line[3]) && $line[3] === ' ') {
                break;
            }
        }

        if ($response === '') {
            throw new \RuntimeException('Réponse SMTP vide');
        }

        $code = (int) substr($response, 0, 3);
        if (!in_array($code, $expectedCodes, true)) {
            throw new \RuntimeException('Réponse SMTP inattendue: ' . trim($response));
        }
    }

    private static function encodeHeader(string $value): string
    {
        if (preg_match('/[^\x20-\x7E]/', $value)) {
            return '=?UTF-8?B?' . base64_encode($value) . '?=';
        }

        return $value;
    }
}
