import { OffreEmploi, Metier } from '@/contexts/AppContext';
import {
  formatDate,
  CONTRACT_TYPE_OPTIONS,
  APPLICATION_STATUS_OPTIONS,
} from './status';
import { competencesLinkFromApi, parseCompetencesLink } from './nested-json';
import { PHOTO_URL_HINT, PHOTO_URL_PLACEHOLDER } from '@/lib/constants';

export { CONTRACT_TYPE_OPTIONS, APPLICATION_STATUS_OPTIONS };

const TELETRAVAIL_OPTIONS = [
  { value: 'non', label: 'Non' },
  { value: 'partiel', label: 'Partiel' },
  { value: 'total', label: 'Total' },
];

const TEMPS_TRAVAIL_OPTIONS = [
  { value: 'temps_plein', label: 'Temps plein' },
  { value: 'temps_partiel', label: 'Temps partiel' },
  { value: 'variable', label: 'Variable' },
];

const OFFER_STATUS_OPTIONS = [
  { value: 'publie', label: 'Publiée' },
  { value: 'brouillon', label: 'Brouillon / en attente' },
  { value: 'pourvue', label: 'Pourvue' },
  { value: 'expiree', label: 'Expirée' },
  { value: 'archivee', label: 'Archivée / refusée' },
];

function offerStatusToApiExtended(statut: unknown): string {
  const map: Record<string, string> = {
    publie: 'publiee',
    brouillon: 'brouillon',
    pourvue: 'pourvue',
    expiree: 'expiree',
    archivee: 'archivee',
    en_attente: 'brouillon',
    refusee: 'archivee',
  };
  const mapped = typeof statut === 'string' && statut in map ? map[statut] : 'brouillon';
  return mapped;
}

function offerStatusFromApiExtended(statut: unknown): string {
  const map: Record<string, string> = {
    publiee: 'publie',
    brouillon: 'brouillon',
    pourvue: 'pourvue',
    expiree: 'expiree',
    archivee: 'archivee',
    en_attente: 'brouillon',
    refusee: 'archivee',
  };
  return typeof statut === 'string' && statut in map ? map[statut] : 'brouillon';
}

export function offerToApi(raw: Record<string, unknown>) {
  const salaireMin = raw.salaire_min ? Number(raw.salaire_min) : null;
  const salaireMax = raw.salaire_max ? Number(raw.salaire_max) : null;
  const statut = offerStatusToApiExtended(raw.statut);

  const payload: Record<string, unknown> = {
    titre: raw.titre,
    reference: raw.reference || null,
    entreprise_id: raw.entreprise_id ? Number(raw.entreprise_id) : null,
    metier_id: raw.metier_id ? Number(raw.metier_id) : null,
    recruteur_id: raw.recruteur_id ? Number(raw.recruteur_id) : null,
    type_contrat: raw.type_contrat || 'cdi',
    description: raw.description || '—',
    profil_recherche: raw.profil_recherche || null,
    avantages: raw.avantages || null,
    experience_min: raw.experience_min || null,
    salaire_min: salaireMin,
    salaire_max: salaireMax,
    salaire_afficher: raw.salaire_afficher ? 1 : 0,
    teletravail: raw.teletravail || 'non',
    temps_travail: raw.temps_travail || 'temps_plein',
    is_urgent: raw.urgent ? 1 : 0,
    is_featured: raw.is_featured ? 1 : 0,
    statut,
    date_publication: raw.date && statut === 'publiee' ? `${raw.date} 00:00:00` : (raw.date ? `${raw.date} 00:00:00` : undefined),
    date_expiration: raw.expires_at ? `${raw.expires_at} 23:59:59` : null,
  };
  if (raw.slug) payload.slug = raw.slug;
  if ('competences_json' in raw) payload.competences = parseCompetencesLink(raw.competences_json);
  if (raw.competences_text) payload.competences_text = raw.competences_text;
  return payload;
}

export function offerFromApi(row: Record<string, unknown>): OffreEmploi {
  return offerDetailFromApi(row) as OffreEmploi;
}

export function offerDetailFromApi(row: Record<string, unknown>): Record<string, unknown> {
  const salaireMin = row.salaire_min != null ? String(row.salaire_min) : '';
  const salaireMax = row.salaire_max != null ? String(row.salaire_max) : '';
  const salaire = salaireMin && salaireMax ? `${salaireMin} - ${salaireMax}` : salaireMin || salaireMax || undefined;

  return {
    id: String(row.id),
    titre: String(row.titre ?? ''),
    slug: String(row.slug ?? ''),
    reference: String(row.reference ?? ''),
    entreprise_id: row.entreprise_id != null ? String(row.entreprise_id) : '',
    entreprise: String(row.entreprise_nom ?? ''),
    metier_id: row.metier_id != null ? String(row.metier_id) : '',
    recruteur_id: row.recruteur_id != null ? String(row.recruteur_id) : '',
    lieu: String(row.ville ?? ''),
    ville: String(row.ville ?? ''),
    postal_code: String(row.code_postal ?? ''),
    code_postal: String(row.code_postal ?? ''),
    departement: String(row.departement ?? ''),
    region: String(row.region ?? ''),
    type_contrat: String(row.type_contrat ?? 'cdi'),
    contrat: String(row.type_contrat ?? '').toUpperCase(),
    secteur: String(row.metier_libelle ?? ''),
    salaire,
    salaire_min: salaireMin || undefined,
    salaire_max: salaireMax || undefined,
    salaire_afficher: !!row.salaire_afficher,
    teletravail: String(row.teletravail ?? 'non'),
    temps_travail: String(row.temps_travail ?? 'temps_plein'),
    description: String(row.description ?? ''),
    profil_recherche: String(row.profil_recherche ?? ''),
    avantages: String(row.avantages ?? ''),
    experience_min: String(row.experience_min ?? ''),
    urgent: !!row.is_urgent,
    is_featured: !!row.is_featured,
    date: formatDate(row.date_publication ?? row.created_at),
    expires_at: row.date_expiration ? formatDate(row.date_expiration) : undefined,
    statut: offerStatusFromApiExtended(row.statut),
    recruteur_email: String(row.recruteur_email ?? row.soumis_par_email ?? ''),
    site_name: String(row.site_name ?? ''),
    site_id: row.site_id != null ? String(row.site_id) : '',
    competences_json: competencesLinkFromApi(row.competences),
    competences_text: Array.isArray(row.competences)
      ? (row.competences as Array<{ label?: string }>).map(c => c.label ?? '').filter(Boolean).join('\n')
      : '',
    site: 'recrutement',
  };
}

export function metierFromApi(row: Record<string, unknown>): Metier {
  return metierDetailFromApi(row) as Metier;
}

export function metierDetailFromApi(row: Record<string, unknown>): Record<string, unknown> {
  return {
    id: String(row.id),
    nom: String(row.libelle ?? row.nom ?? ''),
    titre: String(row.titre ?? ''),
    slug: String(row.slug ?? ''),
    secteur: String(row.secteur_label ?? row.secteur ?? ''),
    secteur_id: row.secteur_id != null ? String(row.secteur_id) : '',
    site_id: row.site_id != null ? String(row.site_id) : '',
    code_rome: String(row.code_rome ?? ''),
    famille_metier: String(row.famille_metier ?? ''),
    niveau_etudes: String(row.niveau_etudes ?? ''),
    perspectives: String(row.perspectives ?? ''),
    description: String(row.description ?? ''),
    description_courte: String(row.description_courte ?? ''),
    presentation: String(row.presentation ?? ''),
    journee_type: String(row.journee_type ?? ''),
    image_url: String(row.image_url ?? ''),
    photo: String(row.image_url ?? ''),
    salaire_fourchette: String(row.salaire_fourchette ?? ''),
    salaire_debutant: String(row.salaire_debutant ?? ''),
    salaire_confirme: String(row.salaire_confirme ?? ''),
    salaire_liberal: String(row.salaire_liberal ?? ''),
    salaire_details: String(row.salaire_details ?? ''),
    statut: row.actif ? 'publie' : 'brouillon',
    competences_json: competencesLinkFromApi(row.competences),
  };
}

export function metierToApi(raw: Record<string, unknown>, siteId?: number) {
  const payload: Record<string, unknown> = {
    libelle: raw.nom ?? raw.libelle,
    titre: raw.titre || null,
    description_courte: raw.description_courte || null,
    description: raw.description || null,
    presentation: raw.presentation || null,
    journee_type: raw.journee_type || null,
    secteur_id: raw.secteur_id ? Number(raw.secteur_id) : null,
    site_id: raw.site_id ? Number(raw.site_id) : siteId,
    code_rome: raw.code_rome || null,
    famille_metier: raw.famille_metier || null,
    niveau_etudes: raw.niveau_etudes || null,
    perspectives: raw.perspectives || null,
    image_url: raw.image_url || raw.photo || null,
    salaire_fourchette: raw.salaire_fourchette || null,
    salaire_debutant: raw.salaire_debutant || null,
    salaire_confirme: raw.salaire_confirme || null,
    salaire_liberal: raw.salaire_liberal || null,
    salaire_details: raw.salaire_details || null,
    actif: raw.statut === 'publie' ? 1 : 0,
  };
  if (raw.slug) payload.slug = raw.slug;
  if ('competences_json' in raw) payload.competences = parseCompetencesLink(raw.competences_json);
  return payload;
}

export function sectorToApi(raw: Record<string, unknown>, siteId?: number) {
  const payload: Record<string, unknown> = {
    label: raw.label ?? raw.name,
    slug: raw.slug || undefined,
  };
  if (siteId != null) payload.site_id = siteId;
  return payload;
}

export function buildOfferFields(
  entrepriseOptions: { value: string; label: string }[],
  metierOptions: { value: string; label: string }[],
  recruteurOptions: { value: string; label: string }[] = [],
  options?: { includeMetier?: boolean },
): import('@/components/FormModal').FieldDef[] {
  const includeMetier = options?.includeMetier ?? metierOptions.length > 0;
  return [
    { key: 'titre', label: 'Intitulé du poste', type: 'text', required: true, span: true, section: 'Informations' },
    {
      key: 'entreprise_id', label: 'Entreprise', type: 'select', required: true, options: entrepriseOptions,
      hint: entrepriseOptions.length ? undefined : 'Créez d\'abord une entreprise (ou un établissement) dans l\'onglet Annuaire.',
    },
    ...(includeMetier && metierOptions.length
      ? [{ key: 'metier_id', label: 'Métier', type: 'select' as const, options: metierOptions }]
      : []),
    ...(recruteurOptions.length
      ? [{ key: 'recruteur_id', label: 'Recruteur', type: 'select' as const, options: recruteurOptions }]
      : []),
    { key: 'type_contrat', label: 'Type de contrat', type: 'select', required: true, options: CONTRACT_TYPE_OPTIONS, section: 'Conditions' },
    { key: 'experience_min', label: 'Expérience min', type: 'select', options: [
      { value: 'debutant', label: 'Débutant' },
      { value: '1-2', label: '1-2 ans' },
      { value: '3-5', label: '3-5 ans' },
      { value: '5-10', label: '5-10 ans' },
      { value: '10+', label: '10+ ans' },
    ]},
    { key: 'temps_travail', label: 'Temps de travail', type: 'select', options: TEMPS_TRAVAIL_OPTIONS },
    { key: 'teletravail', label: 'Télétravail', type: 'select', options: TELETRAVAIL_OPTIONS },
    { key: 'salaire_min', label: 'Salaire min (€)', type: 'number' },
    { key: 'salaire_max', label: 'Salaire max (€)', type: 'number' },
    { key: 'salaire_afficher', label: 'Afficher le salaire', type: 'switch' },
    { key: 'description', label: 'Description', type: 'textarea', required: true, span: true, section: 'Contenu' },
    { key: 'profil_recherche', label: 'Profil recherché', type: 'textarea', span: true },
    { key: 'avantages', label: 'Avantages', type: 'textarea', span: true },
    {
      key: 'competences_text', label: 'Compétences recherchées', type: 'textarea', span: true, section: 'Compétences',
      hint: 'Une compétence par ligne (ex. Excel, Relation patient, Permis B…)',
      placeholder: 'Soins infirmiers\nTravail en équipe\nGestion du stress',
    },
    { key: 'urgent', label: 'Offre urgente', type: 'switch', section: 'Publication' },
    { key: 'is_featured', label: 'Mettre en avant', type: 'switch' },
    { key: 'date', label: 'Date de publication', type: 'date' },
    { key: 'expires_at', label: 'Date de fin de publication', type: 'date' },
    { key: 'statut', label: 'Visibilité', type: 'select', options: OFFER_STATUS_OPTIONS },
  ];
}

export function buildMetierFields(
  sectorOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'nom', label: 'Nom du métier', type: 'text', required: true, span: true, section: 'Informations' },
    { key: 'code_rome', label: 'Code ROME (optionnel)', type: 'text' },
    { key: 'famille_metier', label: 'Famille métier', type: 'text' },
    ...(sectorOptions.length
      ? [{ key: 'secteur_id', label: 'Secteur', type: 'select' as const, options: sectorOptions }]
      : []),
    { key: 'niveau_etudes', label: 'Niveau d\'études', type: 'text', section: 'Description' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'perspectives', label: 'Perspectives', type: 'textarea', span: true },
    {
      key: 'statut', label: 'Visible sur le site', type: 'select',
      options: [{ value: 'publie', label: 'Oui' }, { value: 'brouillon', label: 'Non' }],
    },
  ];
}

export function buildMedicalMetierFields(
  sectorOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'nom', label: 'Nom du métier', type: 'text', required: true, span: true, section: 'Identité' },
    { key: 'titre', label: 'Titre affiché', type: 'text', span: true, hint: 'Titre public (si différent du nom)' },
    { key: 'description_courte', label: 'Description courte', type: 'textarea', span: true, hint: 'Résumé pour les listes (max. 500 car.)' },
    {
      key: 'photo', label: 'Image', type: 'file', fileKind: 'image', uploadContext: 'medical',
      span: true, placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
    {
      key: 'secteur_id', label: 'Secteur', type: 'select', section: 'Publication',
      options: sectorOptions,
      hint: sectorOptions.length ? undefined : 'Créez un secteur dans l\'onglet Secteurs.',
    },
    { key: 'presentation', label: 'Présentation', type: 'textarea', span: true, section: 'Contenu' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'journee_type', label: 'Une journée type', type: 'textarea', span: true },
    { key: 'niveau_etudes', label: 'Niveau d\'études', type: 'text', span: true },
    { key: 'perspectives', label: 'Perspectives / évolution', type: 'textarea', span: true },
    { key: 'salaire_fourchette', label: 'Fourchette salariale', type: 'text', section: 'Rémunération', placeholder: 'Ex. 2 200 € – 3 500 € / mois' },
    { key: 'salaire_debutant', label: 'Salaire débutant', type: 'text' },
    { key: 'salaire_confirme', label: 'Salaire confirmé', type: 'text' },
    { key: 'salaire_liberal', label: 'Salaire libéral', type: 'text' },
    { key: 'salaire_details', label: 'Détails rémunération', type: 'textarea', span: true },
    {
      key: 'statut', label: 'Visible sur le site', type: 'select', section: 'Publication',
      options: [{ value: 'publie', label: 'Oui' }, { value: 'brouillon', label: 'Non' }],
    },
  ];
}

export function buildSectorFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'label', label: 'Nom du secteur', type: 'text', required: true, span: true },
  ];
}

export function buildApplicationFields(
  offreOptions: { value: string; label: string }[] = [],
  candidatOptions: { value: string; label: string }[] = [],
  isCreate = false,
): import('@/components/FormModal').FieldDef[] {
  return [
    ...(isCreate && offreOptions.length
      ? [{ key: 'offre_id', label: 'Offre', type: 'select' as const, required: true, options: offreOptions, span: true }]
      : isCreate ? [{ key: 'offre_id', label: 'ID Offre', type: 'number' as const, required: true }] : []),
    ...(isCreate && candidatOptions.length
      ? [{ key: 'candidat_id', label: 'Candidat', type: 'select' as const, required: true, options: candidatOptions, span: true }]
      : isCreate ? [{ key: 'candidat_id', label: 'ID Candidat', type: 'number' as const, required: true }] : []),
    {
      key: 'statut', label: 'Statut', type: 'select',
      options: APPLICATION_STATUS_OPTIONS,
    },
    { key: 'notes_recruteur', label: 'Notes recruteur', type: 'textarea', span: true },
    { key: 'message_motivation', label: 'Message motivation', type: 'textarea', span: true },
    ...(isCreate ? [{
      key: 'source', label: 'Source', type: 'select' as const,
      options: [
        { value: 'site', label: 'Site' },
        { value: 'bilan', label: 'Bilan' },
        { value: 'alerte', label: 'Alerte' },
        { value: 'recommandation', label: 'Recommandation' },
      ],
    }] : []),
  ];
}

export function buildExterneFields(
  offreOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  const experienceOptions = [
    { value: 'debutant', label: 'Débutant' },
    { value: '1-2', label: '1-2 ans' },
    { value: '3-5', label: '3-5 ans' },
    { value: '5-10', label: '5-10 ans' },
    { value: '10+', label: '10+ ans' },
  ];
  return [
    ...(offreOptions.length
      ? [{ key: 'offre_id', label: 'Offre', type: 'select' as const, required: true, options: offreOptions, span: true, section: 'Offre visée' }]
      : [{ key: 'offre_id', label: 'ID Offre', type: 'number' as const, required: true, section: 'Offre visée' }]),
    { key: 'prenom', label: 'Prénom', type: 'text', required: true, section: 'Candidat' },
    { key: 'nom', label: 'Nom', type: 'text', required: true },
    { key: 'email', label: 'Email', type: 'email', required: true, span: true },
    { key: 'telephone', label: 'Téléphone', type: 'text' },
    { key: 'linkedin_url', label: 'LinkedIn', type: 'text', span: true },
    { key: 'experience_candidat', label: 'Expérience déclarée', type: 'select', options: experienceOptions, section: 'Profil pour l\'offre' },
    { key: 'disponibilite', label: 'Disponibilité', type: 'date' },
    {
      key: 'cv_filename', label: 'CV', type: 'file', fileKind: 'document', uploadContext: 'cv', span: true,
      hint: 'PDF — chemin enregistré pour téléchargement par le recruteur',
    },
    { key: 'lettre_motivation', label: 'Lettre de motivation', type: 'textarea', span: true },
    {
      key: 'competences_reponses', label: 'Réponses aux compétences de l\'offre', type: 'textarea', span: true,
      hint: 'JSON ou une compétence par ligne (ex. Soins infirmiers : 5 ans)',
      placeholder: '[{"competence":"Excel","niveau":"confirme"}]',
    },
    {
      key: 'statut', label: 'Statut pipeline', type: 'select',
      options: APPLICATION_STATUS_OPTIONS.filter(o => o.value !== 'retiree'),
      section: 'Pipeline',
    },
    { key: 'verifie_nexytal', label: 'Vérifié par Nexytal', type: 'switch', section: 'Qualification Nexytal' },
    { key: 'score_nexytal', label: 'Score Nexytal (0-100)', type: 'number' },
    { key: 'note_nexytal', label: 'Synthèse Nexytal', type: 'textarea', span: true },
  ];
}

export function externeToApi(raw: Record<string, unknown>) {
  const payload: Record<string, unknown> = {
    offre_id: Number(raw.offre_id),
    prenom: raw.prenom,
    nom: raw.nom,
    email: raw.email,
    telephone: raw.telephone || null,
    linkedin_url: raw.linkedin_url || null,
    lettre_motivation: raw.lettre_motivation || null,
    experience_candidat: raw.experience_candidat || null,
    disponibilite: raw.disponibilite || null,
    cv_filename: raw.cv_filename || null,
    statut: raw.statut || 'recue',
    verifie_nexytal: raw.verifie_nexytal ? 1 : 0,
    score_nexytal: raw.score_nexytal !== '' && raw.score_nexytal != null ? Number(raw.score_nexytal) : null,
    note_nexytal: raw.note_nexytal || null,
  };
  if (raw.competences_reponses != null && raw.competences_reponses !== '') {
    const val = raw.competences_reponses;
    if (typeof val === 'string') {
      try {
        payload.competences_reponses = JSON.parse(val);
      } catch {
        payload.competences_reponses = val.split('\n').map(s => s.trim()).filter(Boolean);
      }
    } else {
      payload.competences_reponses = val;
    }
  }
  return payload;
}

export function externeDetailFromApi(row: Record<string, unknown>) {
  let competencesDisplay = '';
  const comp = row.competences_reponses;
  if (comp != null && comp !== '') {
    if (typeof comp === 'string') {
      competencesDisplay = comp;
    } else {
      competencesDisplay = JSON.stringify(comp, null, 2);
    }
  }
  return {
    id: String(row.id),
    offre_id: row.offre_id != null ? String(row.offre_id) : '',
    offre_titre: String(row.offre_titre ?? ''),
    prenom: String(row.prenom ?? ''),
    nom: String(row.nom ?? ''),
    email: String(row.email ?? ''),
    telephone: String(row.telephone ?? ''),
    linkedin_url: String(row.linkedin_url ?? ''),
    lettre_motivation: String(row.lettre_motivation ?? ''),
    cv_filename: String(row.cv_filename ?? ''),
    experience_candidat: String(row.experience_candidat ?? ''),
    disponibilite: String(row.disponibilite ?? '').slice(0, 10),
    competences_reponses: competencesDisplay,
    statut: String(row.statut ?? 'recue'),
    verifie_nexytal: !!row.verifie_nexytal,
    score_nexytal: row.score_nexytal != null ? Number(row.score_nexytal) : '',
    note_nexytal: String(row.note_nexytal ?? ''),
  };
}

export function buildAlerteFields(
  candidatOptions: { value: string; label: string }[],
  metierOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'candidat_id', label: 'Candidat', type: 'select', required: true, options: candidatOptions, span: true },
    ...(metierOptions.length
      ? [{ key: 'metier_id', label: 'Métier', type: 'select' as const, options: metierOptions }]
      : []),
    { key: 'mots_cles', label: 'Mots-clés', type: 'text', span: true },
    { key: 'ville', label: 'Ville', type: 'text' },
    { key: 'rayon_km', label: 'Rayon (km)', type: 'number' },
    { key: 'type_contrat', label: 'Type contrat', type: 'text', placeholder: 'cdi, cdd…' },
    {
      key: 'frequence', label: 'Fréquence', type: 'select',
      options: [
        { value: 'quotidienne', label: 'Quotidienne' },
        { value: 'hebdomadaire', label: 'Hebdomadaire' },
      ],
    },
    { key: 'active', label: 'Active', type: 'switch' },
  ];
}

export function buildFavoriteFields(
  candidatOptions: { value: string; label: string }[],
  offreOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'candidat_id', label: 'Candidat', type: 'select', required: true, options: candidatOptions, span: true },
    { key: 'offre_id', label: 'Offre', type: 'select', required: true, options: offreOptions, span: true },
  ];
}
