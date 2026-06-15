import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { parseCompetencesLink, competencesLinkFromApi, parseJsonArray } from './nested-json';

function slugifyName(prenom: string, nom: string): string {
  return `${prenom}-${nom}`
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '') || 'candidat';
}

/** Crée ou retrouve un compte `users` avant POST candidat (API prod exige user_id). */
export async function ensureCandidatUserId(raw: Record<string, unknown>): Promise<number> {
  const existing = raw.user_id ? Number(raw.user_id) : 0;
  if (existing > 0) return existing;

  let email = String(raw.email ?? '').trim().toLowerCase();
  if (!email) {
    const prenom = String(raw.prenom ?? '').trim();
    const nom = String(raw.nom ?? '').trim();
    email = `candidat.${slugifyName(prenom, nom)}.${Date.now()}@internal.nexytal.local`;
  }

  const findByEmail = async (): Promise<number | null> => {
    const res = await api.get<{ data: { id: number; email: string }[] }>('/recrutement/users', {
      params: { role: 'candidat' },
    });
    const match = (res.data?.data ?? []).find(u => String(u.email).toLowerCase() === email);
    return match ? Number(match.id) : null;
  };

  try {
    const found = await findByEmail();
    if (found) return found;
  } catch {
    /* liste indisponible — on tente la création */
  }

  try {
    const res = await api.post<{ data?: { id: number } }>('/recrutement/users', {
      email,
      role: 'candidat',
      email_verifie: 1,
      actif: 1,
    });
    const id = res.data?.data?.id;
    if (id) return Number(id);
  } catch (err) {
    const msg = getApiErrorMessage(err, '').toLowerCase();
    if (msg.includes('already exists') || msg.includes('existe')) {
      const found = await findByEmail();
      if (found) return found;
    }
    throw err;
  }

  throw new Error('Impossible de créer le compte utilisateur candidat');
}

export function candidatFromApi(row: Record<string, unknown>) {
  return candidatDetailFromApi(row);
}

export function candidatDetailFromApi(row: Record<string, unknown>) {
  return {
    id: String(row.id),
    user_id: row.user_id != null ? String(row.user_id) : '',
    prenom: String(row.prenom ?? ''),
    nom: String(row.nom ?? ''),
    email: String(row.email ?? ''),
    telephone: String(row.telephone ?? ''),
    date_naissance: String(row.date_naissance ?? '').slice(0, 10),
    situation_professionnelle: String(row.situation_professionnelle ?? ''),
    resume_court: String(row.resume_court ?? ''),
    ville: String(row.ville ?? ''),
    code_postal: String(row.code_postal ?? ''),
    region: String(row.region ?? ''),
    mobilite_km: row.mobilite_km != null ? String(row.mobilite_km) : '',
    teletravail_souhaite: String(row.teletravail_souhaite ?? 'indifferent'),
    disponibilite: String(row.disponibilite ?? '').slice(0, 10),
    recherche_active: !!row.recherche_active,
    salaire_souhaite_min: row.salaire_souhaite_min != null ? String(row.salaire_souhaite_min) : '',
    type_contrat_souhaite: String(row.type_contrat_souhaite ?? ''),
    profil_public: !!row.profil_public,
    competences_json: competencesLinkFromApi(row.competences),
    metiers_souhaites_json: JSON.stringify(
      (row.metiers_souhaites as unknown[] ?? []).map((m: Record<string, unknown>) => ({
        metier_id: m.metier_id, priorite: m.priorite ?? 1, source: m.source ?? 'manuel',
      })), null, 2,
    ),
    experiences_json: JSON.stringify(row.experiences ?? [], null, 2),
    formations_json: JSON.stringify(row.formations ?? [], null, 2),
  };
}

export function candidatToApi(raw: Record<string, unknown>) {
  const payload: Record<string, unknown> = {
    prenom: raw.prenom,
    nom: raw.nom,
    email: String(raw.email ?? '').trim() || undefined,
    user_id: raw.user_id ? Number(raw.user_id) : undefined,
    telephone: raw.telephone || null,
    date_naissance: raw.date_naissance || null,
    situation_professionnelle: raw.situation_professionnelle || null,
    resume_court: raw.resume_court || null,
    ville: raw.ville || null,
    code_postal: raw.code_postal || null,
    region: raw.region || null,
    mobilite_km: raw.mobilite_km ? Number(raw.mobilite_km) : null,
    teletravail_souhaite: raw.teletravail_souhaite || 'indifferent',
    disponibilite: raw.disponibilite || null,
    recherche_active: raw.recherche_active ? 1 : 0,
    salaire_souhaite_min: raw.salaire_souhaite_min ? Number(raw.salaire_souhaite_min) : null,
    type_contrat_souhaite: raw.type_contrat_souhaite || null,
    profil_public: raw.profil_public ? 1 : 0,
  };
  if ('competences_json' in raw) payload.competences = parseCompetencesLink(raw.competences_json);
  if ('metiers_souhaites_json' in raw) payload.metiers_souhaites = parseJsonArray(raw.metiers_souhaites_json);
  if ('experiences_json' in raw) payload.experiences = parseJsonArray(raw.experiences_json);
  if ('formations_json' in raw) payload.formations = parseJsonArray(raw.formations_json);
  return payload;
}

export function buildCandidatFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'prenom', label: 'Prénom', type: 'text', required: true, section: 'Informations' },
    { key: 'nom', label: 'Nom', type: 'text', required: true },
    {
      key: 'email', label: 'Email', type: 'text', span: true,
      hint: 'Optionnel : crée ou lie un compte candidat. Sinon un compte interne est généré automatiquement.',
    },
    { key: 'telephone', label: 'Téléphone', type: 'text' },
    { key: 'date_naissance', label: 'Date de naissance', type: 'date' },
    {
      key: 'situation_professionnelle', label: 'Situation professionnelle', type: 'select',
      options: [
        { value: 'salarie', label: 'Salarié' },
        { value: 'demandeur_emploi', label: 'Demandeur d\'emploi' },
        { value: 'independant', label: 'Indépendant' },
        { value: 'cadre_reconversion', label: 'Cadre en reconversion' },
        { value: 'parent_reprise', label: 'Parent reprise' },
        { value: 'autre', label: 'Autre' },
      ],
    },
    { key: 'resume_court', label: 'Résumé court', type: 'textarea', span: true, section: 'Profil' },
    { key: 'ville', label: 'Ville', type: 'text' },
    { key: 'code_postal', label: 'Code postal', type: 'text' },
    { key: 'region', label: 'Région', type: 'text' },
    { key: 'mobilite_km', label: 'Mobilité (km)', type: 'number' },
    {
      key: 'teletravail_souhaite', label: 'Télétravail souhaité', type: 'select',
      options: [
        { value: 'non', label: 'Non' },
        { value: 'partiel', label: 'Partiel' },
        { value: 'total', label: 'Total' },
        { value: 'indifferent', label: 'Indifférent' },
      ],
    },
    { key: 'disponibilite', label: 'Disponibilité', type: 'date' },
    { key: 'salaire_souhaite_min', label: 'Salaire souhaité min (€)', type: 'number' },
    { key: 'type_contrat_souhaite', label: 'Contrats souhaités', type: 'text', placeholder: 'cdi,cdd,freelance' },
    { key: 'recherche_active', label: 'Recherche active', type: 'switch' },
    { key: 'profil_public', label: 'Profil public', type: 'switch', section: 'Visibilité' },
  ];
}

export function competenceToApi(raw: Record<string, unknown>) {
  return {
    label: raw.label,
    slug: raw.slug || undefined,
    categorie: raw.categorie || 'technique',
  };
}

export function buildCompetenceFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'label', label: 'Nom de la compétence', type: 'text', required: true, span: true },
    {
      key: 'categorie', label: 'Type', type: 'select',
      options: [
        { value: 'technique', label: 'Compétence technique' },
        { value: 'soft_skill', label: 'Qualité personnelle' },
        { value: 'langue', label: 'Langue' },
        { value: 'outil', label: 'Outil / logiciel' },
        { value: 'certification', label: 'Certification' },
      ],
    },
  ];
}
