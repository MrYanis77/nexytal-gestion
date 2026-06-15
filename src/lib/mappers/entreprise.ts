import { Entreprise } from '@/contexts/AppContext';
export function entrepriseFromApi(row: Record<string, unknown>): Entreprise {
  return {
    id: String(row.id),
    nom: String(row.nom ?? ''),
    slug: String(row.slug ?? ''),
    siret: row.siret ? String(row.siret) : undefined,
    description: String(row.description ?? ''),
    logo_url: String(row.logo_url ?? ''),
    site_web: String(row.site_web ?? ''),
    ville: String(row.ville ?? ''),
    code_postal: String(row.code_postal ?? ''),
    secteur_id: row.secteur_id != null ? String(row.secteur_id) : undefined,
    validee: !!row.validee,
  };
}

export function entrepriseDetailFromApi(row: Record<string, unknown>) {
  return {
    ...entrepriseFromApi(row),
    taille: String(row.taille ?? ''),
    adresse: String(row.adresse ?? ''),
  };
}

export function entrepriseToApi(raw: Record<string, unknown>, siteId?: number) {
  const payload: Record<string, unknown> = {
    nom: raw.nom,
    slug: raw.slug || undefined,
    siret: raw.siret || null,
    description: raw.description || null,
    taille: raw.taille || null,
    secteur_id: raw.secteur_id ? Number(raw.secteur_id) : null,
    adresse: raw.adresse || null,
    code_postal: raw.code_postal || null,
    ville: raw.ville || null,
    validee: raw.validee ? 1 : 0,
  };
  if (siteId != null) payload.site_id = siteId;
  return payload;
}

export function recruteurToApi(raw: Record<string, unknown>) {
  return {
    prenom: raw.prenom,
    nom: raw.nom,
    entreprise_id: Number(raw.entreprise_id),
    fonction: raw.fonction || null,
    telephone: raw.telephone || null,
    principal: raw.principal ? 1 : 0,
  };
}

export function buildEntrepriseFields(
  sectorOptions: { value: string; label: string }[] = [],
  nomLabel = 'Nom de l\'entreprise',
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'nom', label: nomLabel, type: 'text', required: true, span: true, section: 'Informations' },
    { key: 'siret', label: 'SIRET (optionnel)', type: 'text' },
    {
      key: 'taille', label: 'Taille', type: 'select',
      options: [
        { value: '1-10', label: '1-10' },
        { value: '11-50', label: '11-50' },
        { value: '51-200', label: '51-200' },
        { value: '201-500', label: '201-500' },
        { value: '500+', label: '500+' },
      ],
    },
    { key: 'adresse', label: 'Adresse', type: 'text', span: true, section: 'Adresse' },
    { key: 'ville', label: 'Ville', type: 'text' },
    { key: 'code_postal', label: 'Code postal', type: 'text' },
    ...(sectorOptions.length
      ? [{ key: 'secteur_id', label: 'Secteur', type: 'select' as const, options: sectorOptions }]
      : []),
    { key: 'description', label: 'Description', type: 'textarea', span: true, section: 'Description' },
    { key: 'validee', label: 'Entreprise validée', type: 'switch', section: 'Statut' },
  ];
}

export function buildRecruteurFields(
  entrepriseOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'prenom', label: 'Prénom', type: 'text', required: true, section: 'Identité' },
    { key: 'nom', label: 'Nom', type: 'text', required: true },
    {
      key: 'entreprise_id',
      label: 'Entreprise',
      type: 'select',
      required: true,
      options: entrepriseOptions,
      span: true,
      hint: entrepriseOptions.length ? undefined : 'Créez d\'abord une entreprise dans l\'onglet Annuaire.',
    },
    { key: 'fonction', label: 'Fonction (optionnel)', type: 'text', section: 'Contact' },
    { key: 'telephone', label: 'Téléphone (optionnel)', type: 'text' },
    { key: 'principal', label: 'Contact principal', type: 'switch', section: 'Options' },
  ];
}
