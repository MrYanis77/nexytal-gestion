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
    departement: String(row.departement ?? ''),
    region: String(row.region ?? ''),
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
    departement: raw.departement || null,
    region: raw.region || null,
    validee: raw.validee ? 1 : 0,
  };
  if (siteId != null) payload.site_id = siteId;
  return payload;
}

export function recruteurToApi(raw: Record<string, unknown>) {
  return {
    email: raw.email,
    nom_entreprise: raw.nom_entreprise,
    prenom: raw.prenom,
    nom: raw.nom,
    entreprise_id: raw.entreprise_id ? Number(raw.entreprise_id) : null,
    fonction: raw.fonction || null,
    telephone: raw.telephone || null,
    status: raw.status || undefined,
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
    { key: 'departement', label: 'Département', type: 'text', placeholder: 'Ex. 77' },
    { key: 'region', label: 'Région', type: 'text', placeholder: 'Ex. Île-de-France' },
    ...(sectorOptions.length
      ? [{ key: 'secteur_id', label: 'Secteur', type: 'select' as const, options: sectorOptions }]
      : []),
    { key: 'description', label: 'Description', type: 'textarea', span: true, section: 'Description' },
    { key: 'validee', label: 'Entreprise validée', type: 'switch', section: 'Statut' },
  ];
}

export function buildRecruteurFields(
  entrepriseOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'email', label: 'Email', type: 'email', required: true, span: true, section: 'Identité' },
    { key: 'prenom', label: 'Prénom', type: 'text', required: true },
    { key: 'nom', label: 'Nom', type: 'text', required: true },
    { key: 'nom_entreprise', label: 'Nom de l\'entreprise', type: 'text', required: true, span: true, section: 'Entreprise' },
    ...(entrepriseOptions.length
      ? [{ key: 'entreprise_id', label: 'Entreprise (annuaire)', type: 'select' as const, options: entrepriseOptions, hint: 'Lier à une entreprise existante dans l\'annuaire (optionnel)' }]
      : []),
    { key: 'fonction', label: 'Fonction', type: 'text', section: 'Contact' },
    { key: 'telephone', label: 'Téléphone', type: 'text' },
    {
      key: 'status', label: 'Statut', type: 'select', section: 'Statut',
      options: [
        { value: 'pending', label: 'En attente' },
        { value: 'actif', label: 'Actif' },
        { value: 'suspendu', label: 'Suspendu' },
      ],
    },
  ];
}
