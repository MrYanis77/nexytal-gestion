<?php
/**
 * core/Validator.php — Validation des inputs pour l'API Nexytal
 * 
 * Méthodes statiques de validation. Retourne un tableau d'erreurs par champ.
 * Utilisé dans tous les modules avant insert/update.
 */

class Validator
{
    /** @var array Erreurs accumulées */
    private array $errors = [];

    /** @var array Données à valider */
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    /**
     * Crée une instance de Validator
     */
    public static function make(array $data): self
    {
        return new self($data);
    }

    /**
     * Champ requis (non vide)
     */
    public function required(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (!isset($this->data[$field]) || (is_string($this->data[$field]) && trim($this->data[$field]) === '')) {
            $this->errors[$field] = "$label is required";
        }
        return $this;
    }

    /**
     * Email valide
     */
    public function email(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && !empty($this->data[$field])) {
            if (!filter_var($this->data[$field], FILTER_VALIDATE_EMAIL)) {
                $this->errors[$field] = "$label must be a valid email address";
            }
        }
        return $this;
    }

    /**
     * Slug valide (lowercase alphanumeric + hyphens)
     */
    public function slug(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && !empty($this->data[$field])) {
            if (!preg_match('/^[a-z0-9]+(?:-[a-z0-9]+)*$/', $this->data[$field])) {
                $this->errors[$field] = "$label must be a valid slug (lowercase letters, numbers, hyphens)";
            }
        }
        return $this;
    }

    /**
     * Longueur minimale
     */
    public function minLength(string $field, int $min, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && is_string($this->data[$field])) {
            if (mb_strlen($this->data[$field]) < $min) {
                $this->errors[$field] = "$label must be at least $min characters";
            }
        }
        return $this;
    }

    /**
     * Longueur maximale
     */
    public function maxLength(string $field, int $max, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && is_string($this->data[$field])) {
            if (mb_strlen($this->data[$field]) > $max) {
                $this->errors[$field] = "$label must be at most $max characters";
            }
        }
        return $this;
    }

    /**
     * Valeur dans une liste autorisée
     */
    public function in(string $field, array $allowed, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && !empty($this->data[$field])) {
            if (!in_array($this->data[$field], $allowed, true)) {
                $this->errors[$field] = "$label must be one of: " . implode(', ', $allowed);
            }
        }
        return $this;
    }

    /**
     * Entier valide
     */
    public function integer(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && $this->data[$field] !== '') {
            if (!is_numeric($this->data[$field]) || (int) $this->data[$field] != $this->data[$field]) {
                $this->errors[$field] = "$label must be an integer";
            }
        }
        return $this;
    }

    /**
     * Nombre valide (int ou float)
     */
    public function numeric(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && $this->data[$field] !== '') {
            if (!is_numeric($this->data[$field])) {
                $this->errors[$field] = "$label must be a number";
            }
        }
        return $this;
    }

    /**
     * URL valide
     */
    public function url(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && !empty($this->data[$field])) {
            if (!filter_var($this->data[$field], FILTER_VALIDATE_URL)) {
                $this->errors[$field] = "$label must be a valid URL";
            }
        }
        return $this;
    }

    /**
     * Date valide (format Y-m-d ou Y-m-d H:i:s)
     */
    public function date(string $field, string $format = 'Y-m-d', string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && !empty($this->data[$field])) {
            $d = \DateTime::createFromFormat($format, $this->data[$field]);
            if (!$d || $d->format($format) !== $this->data[$field]) {
                $this->errors[$field] = "$label must be a valid date (format: $format)";
            }
        }
        return $this;
    }

    /**
     * Booléen valide
     */
    public function boolean(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field])) {
            if (!in_array($this->data[$field], [true, false, 0, 1, '0', '1', 'true', 'false'], true)) {
                $this->errors[$field] = "$label must be a boolean value";
            }
        }
        return $this;
    }

    /**
     * Valeur entre min et max
     */
    public function between(string $field, int|float $min, int|float $max, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && is_numeric($this->data[$field])) {
            $val = (float) $this->data[$field];
            if ($val < $min || $val > $max) {
                $this->errors[$field] = "$label must be between $min and $max";
            }
        }
        return $this;
    }

    /**
     * Tableau (array) requis
     */
    public function isArray(string $field, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && !is_array($this->data[$field])) {
            $this->errors[$field] = "$label must be an array";
        }
        return $this;
    }

    /**
     * Vérifie s'il y a des erreurs
     */
    public function hasErrors(): bool
    {
        return !empty($this->errors);
    }

    /**
     * Retourne les erreurs
     */
    public function getErrors(): array
    {
        return $this->errors;
    }

    /**
     * Si des erreurs existent, envoie une réponse 422 et arrête l'exécution
     */
    public function validate(): void
    {
        if ($this->hasErrors()) {
            Response::validationError($this->errors);
            exit;
        }
    }

    /**
     * Génère un slug à partir d'un texte
     */
    public static function slugify(string $text): string
    {
        // Translittération des accents
        $text = transliterator_transliterate('Any-Latin; Latin-ASCII; Lower()', $text);
        // Remplacer les caractères non-alphanumériques par des tirets
        $text = preg_replace('/[^a-z0-9]+/', '-', $text);
        // Supprimer les tirets en début/fin
        $text = trim($text, '-');
        // Supprimer les tirets multiples
        $text = preg_replace('/-+/', '-', $text);
        return $text;
    }

    /**
     * Nettoie une chaîne (trim + suppression tags HTML)
     */
    public static function sanitizeString(string $value): string
    {
        return trim(strip_tags($value));
    }

    /**
     * Nettoie un contenu HTML (autorise certaines balises)
     */
    public static function sanitizeHtml(string $value): string
    {
        return trim(strip_tags($value, '<p><br><strong><em><ul><ol><li><h2><h3><h4><a><img><blockquote><code><pre>'));
    }
}
