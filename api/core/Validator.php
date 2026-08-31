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
        $text = trim($text);
        if (function_exists('transliterator_transliterate')) {
            $converted = transliterator_transliterate('Any-Latin; Latin-ASCII; Lower()', $text);
            if ($converted !== false) {
                $text = $converted;
            }
        } else {
            $text = strtolower($text);
            $text = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $text) ?: $text;
        }
        $text = strtolower($text);
        $text = preg_replace('/[^a-z0-9]+/', '-', $text);
        $text = trim($text, '-');
        $text = preg_replace('/-+/', '-', $text);
        return $text !== '' ? $text : 'item-' . time();
    }

    /**
     * Nettoie une chaîne (trim + suppression tags HTML)
     */
    public static function sanitizeString(string $value): string
    {
        return trim(strip_tags($value));
    }

    /**
     * Nettoie un contenu HTML (autorise certaines balises).
     * Les attributs sont reconstruits explicitement pour eviter XSS stocke.
     */
    public static function sanitizeHtml(string $value): string
    {
        $value = trim($value);
        if ($value === '') {
            return '';
        }

        if (!class_exists('DOMDocument')) {
            return self::sanitizeHtmlFallback($value);
        }

        $allowedTags = [
            'p', 'br', 'strong', 'em', 'ul', 'ol', 'li', 'h2', 'h3', 'h4',
            'a', 'img', 'blockquote', 'code', 'pre',
        ];
        $allowedAttrs = [
            'a' => ['href', 'title', 'target', 'rel'],
            'img' => ['src', 'alt', 'title', 'width', 'height', 'loading'],
        ];

        $doc = new DOMDocument('1.0', 'UTF-8');
        $previous = libxml_use_internal_errors(true);
        $html = '<!DOCTYPE html><html><body><div id="__nexytal_root">' . $value . '</div></body></html>';
        $loaded = $doc->loadHTML($html, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);
        libxml_clear_errors();
        libxml_use_internal_errors($previous);

        if (!$loaded) {
            return self::sanitizeHtmlFallback($value);
        }

        $root = null;
        foreach ($doc->getElementsByTagName('div') as $div) {
            if ($div->getAttribute('id') === '__nexytal_root') {
                $root = $div;
                break;
            }
        }
        if (!$root) {
            return self::sanitizeHtmlFallback($value);
        }

        self::sanitizeDomChildren($root, $allowedTags, $allowedAttrs);

        $clean = '';
        foreach ($root->childNodes as $child) {
            $clean .= $doc->saveHTML($child) ?: '';
        }

        return trim($clean);
    }

    private static function sanitizeDomChildren($node, array $allowedTags, array $allowedAttrs): void
    {
        $children = [];
        foreach ($node->childNodes as $child) {
            $children[] = $child;
        }

        foreach ($children as $child) {
            if (!$child->parentNode) {
                continue;
            }

            if ($child->nodeType !== XML_ELEMENT_NODE) {
                continue;
            }

            $tag = strtolower($child->nodeName);
            if (!in_array($tag, $allowedTags, true)) {
                self::unwrapDomElement($child);
                continue;
            }

            self::sanitizeDomChildren($child, $allowedTags, $allowedAttrs);
            self::sanitizeDomAttributes($child, $allowedAttrs[$tag] ?? [], $tag);
        }
    }

    private static function sanitizeDomAttributes($element, array $allowedAttrs, string $tag): void
    {
        $attributeNames = [];
        foreach ($element->attributes as $attribute) {
            $attributeNames[] = $attribute->name;
        }

        foreach ($attributeNames as $name) {
            $lower = strtolower($name);
            $value = (string) $element->getAttribute($name);

            if (!in_array($lower, $allowedAttrs, true) || str_starts_with($lower, 'on')) {
                $element->removeAttribute($name);
                continue;
            }

            if (in_array($lower, ['href', 'src'], true)) {
                $isImage = $tag === 'img' && $lower === 'src';
                if (!self::isSafeHtmlUrl($value, $isImage)) {
                    $element->removeAttribute($name);
                }
                continue;
            }

            if ($lower === 'target' && !in_array($value, ['_blank', '_self'], true)) {
                $element->removeAttribute($name);
                continue;
            }

            if (in_array($lower, ['width', 'height'], true) && !preg_match('/^[1-9][0-9]{0,3}$/', $value)) {
                $element->removeAttribute($name);
                continue;
            }

            if ($lower === 'loading' && !in_array($value, ['lazy', 'eager'], true)) {
                $element->removeAttribute($name);
            }
        }

        if ($tag === 'a' && $element->getAttribute('target') === '_blank') {
            $element->setAttribute('rel', 'noopener noreferrer');
        }
    }

    private static function unwrapDomElement($element): void
    {
        $parent = $element->parentNode;
        if (!$parent) {
            return;
        }

        while ($element->firstChild) {
            $parent->insertBefore($element->firstChild, $element);
        }
        $parent->removeChild($element);
    }

    private static function isSafeHtmlUrl(string $url, bool $imageOnly = false): bool
    {
        $url = trim(html_entity_decode($url, ENT_QUOTES | ENT_HTML5, 'UTF-8'));
        $url = preg_replace('/[\x00-\x1F\x7F\s]+/', '', $url) ?? '';
        if ($url === '' || str_starts_with($url, '//')) {
            return false;
        }

        if (str_starts_with($url, '#') || str_starts_with($url, '/') || str_starts_with($url, './') || str_starts_with($url, '../')) {
            return true;
        }

        $scheme = strtolower((string) parse_url($url, PHP_URL_SCHEME));
        if ($scheme === '') {
            return !preg_match('/^[a-z][a-z0-9+.-]*:/i', $url);
        }

        $allowed = $imageOnly ? ['http', 'https'] : ['http', 'https', 'mailto', 'tel'];
        return in_array($scheme, $allowed, true);
    }

    private static function sanitizeHtmlFallback(string $value): string
    {
        $value = trim(strip_tags($value, '<p><br><strong><em><ul><ol><li><h2><h3><h4><a><img><blockquote><code><pre>'));
        $value = preg_replace('/\s+on[a-z]+\s*=\s*("[^"]*"|\'[^\']*\'|[^\s>]+)/i', '', $value) ?? $value;
        $value = preg_replace('/\s+(href|src|action)\s*=\s*("|\')?\s*(javascript|data|vbscript):[^\s>]*/i', '', $value) ?? $value;
        return preg_replace('/<\s*\/?\s*(script|style|iframe|object|embed)\b[^>]*>/i', '', $value) ?? $value;
    }

    /**
     * Vérifie qu'une valeur appartient à un ENUM de la BDD
     */
    public function inEnum(string $field, array $allowedValues, string $label = ''): self
    {
        $label = $label ?: $field;
        if (isset($this->data[$field]) && $this->data[$field] !== '' && $this->data[$field] !== null) {
            if (!in_array((string) $this->data[$field], $allowedValues, true)) {
                $this->errors[$field] = "$label must be one of: " . implode(', ', $allowedValues);
            }
        }
        return $this;
    }

    /** Codes site valides (ENUM core_sites.site_code + recruteur_sites.site) */
    public const VALID_SITE_CODES = ['formation', 'recrutement', 'medical', 'carriere', 'trainers', 'coaching'];

    /** Statuts recruteur valides */
    public const RECRUTEUR_STATUSES = ['pending', 'actif', 'suspendu'];

    /** Statuts candidature valides */
    public const CANDIDATURE_STATUSES = ['recue', 'vue', 'shortlist', 'entretien', 'offre', 'refusee', 'retiree'];

    /** Types de contrat valides */
    public const CONTRACT_TYPES = ['cdi', 'cdd', 'interim', 'alternance', 'freelance', 'stage'];
}
