import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT } from '@/lib/constants';

export function buildNewsletterListFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la liste', type: 'text', required: true, span: true },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'is_active', label: 'Liste active', type: 'switch' },
  ];
}

export function buildNewsletterSubscriberFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'email', label: 'Adresse email', type: 'email', required: true, span: true },
    { key: 'first_name', label: 'Prénom', type: 'text' },
    { key: 'last_name', label: 'Nom', type: 'text' },
    {
      key: 'status', label: 'Statut', type: 'select',
      options: [
        { value: 'pending', label: 'En attente' },
        { value: 'active', label: 'Abonné actif' },
        { value: 'unsubscribed', label: 'Désabonné' },
        { value: 'bounced', label: 'Adresse invalide' },
      ],
    },
  ];
}

export function subscriberToApi(raw: Record<string, unknown>) {
  return {
    email: raw.email,
    first_name: raw.first_name || null,
    last_name: raw.last_name || null,
    status: raw.status || 'active',
  };
}

export function buildNewsletterCampaignFields(
  listOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'subject', label: 'Objet de l\'email', type: 'text', required: true, span: true },
    ...(listOptions.length
      ? [{ key: 'list_id', label: 'Liste de diffusion', type: 'select' as const, options: listOptions }]
      : []),
    { key: 'preview_text', label: 'Aperçu (texte court)', type: 'text', span: true, hint: 'Résumé visible dans la boîte mail' },
    { key: 'content_html', label: 'Message', type: 'textarea', required: true, span: true, hint: 'Texte de l\'email envoyé aux abonnés' },
    {
      key: 'status', label: 'Statut', type: 'select',
      options: [
        { value: 'draft', label: 'Brouillon' },
        { value: 'scheduled', label: 'Planifiée' },
        { value: 'sending', label: 'En cours d\'envoi' },
        { value: 'sent', label: 'Envoyée' },
        { value: 'cancelled', label: 'Annulée' },
      ],
    },
    { key: 'scheduled_at', label: 'Date d\'envoi planifiée', type: 'date' },
  ];
}

export function buildNewsletterSubscriptionFields(
  subscriberOptions: { value: string; label: string }[],
  listOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'subscriber_id', label: 'Abonné', type: 'select', required: true, options: subscriberOptions, span: true },
    { key: 'list_id', label: 'Liste', type: 'select', required: true, options: listOptions, span: true },
  ];
}

export function buildSeoFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'meta_title', label: 'Titre pour Google', type: 'text', span: true, section: 'Référencement' },
    { key: 'meta_description', label: 'Description pour Google', type: 'textarea', span: true },
    {
      key: 'og_image', label: 'Image de partage', type: 'file', fileKind: 'image', uploadContext: 'global',
      span: true, section: 'Réseaux sociaux', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
  ];
}

export function buildEmailLogFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'recipient_email', label: 'Destinataire', type: 'email', required: true, span: true },
    { key: 'subject', label: 'Objet', type: 'text', required: true, span: true },
    {
      key: 'status', label: 'Statut', type: 'select',
      options: [
        { value: 'sent', label: 'Envoyé' },
        { value: 'failed', label: 'Échoué' },
        { value: 'bounced', label: 'Adresse invalide' },
      ],
    },
  ];
}
