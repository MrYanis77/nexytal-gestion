import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { api } from '@/lib/api';

// ─── Types ────────────────────────────────────────────────────────────────────

export type Role = 'superadmin' | 'admin' | 'editor' | 'moderator' | 'recruiter' | 'user';
export type SiteId = 'formation' | 'medical' | 'recrutement' | 'carriere' | 'coaching' | 'trainer';

const SLUG_TO_SITE: Record<string, SiteId> = {
  'alt-formation': 'formation',
  'nexytal-recrutement': 'recrutement',
  'nexytal-medical': 'medical',
  'nexytal-carriere': 'carriere',
  'nexytal-trainer': 'trainer',
  'nexytal-coaching': 'coaching',
};

function mapApiAdminToUser(
  admin: { id: number | string; email: string; role: string; avatar_url?: string | null; first_name?: string; last_name?: string },
  sites?: Array<{ slug: string }>,
): User {
  return {
    id: String(admin.id),
    username: admin.email,
    email: admin.email,
    role: admin.role as Role,
    sites: (sites ?? [])
      .map(s => SLUG_TO_SITE[s.slug])
      .filter((s): s is SiteId => !!s),
    createdAt: '',
    active: true,
    avatar: admin.avatar_url ?? undefined,
  };
}

export interface User {
  id: string;
  username: string;
  email: string;
  first_name?: string;
  last_name?: string;
  role: Role;
  sites: SiteId[];
  createdAt: string;
  active: boolean;
  avatar?: string;
}

// ─── Site-specific data types ─────────────────────────────────────────────────

export interface Formation {
  id: string;
  titre: string;
  subtitle?: string;
  category_id?: string;
  categorie: string;
  description: string;
  programme: string;
  video_url?: string;
  duree: string;
  price?: string;
  certifiante: boolean;
  is_alternance?: boolean;
  rncp_repertoire?: string;
  rncp?: string;
  rncp_title?: string;
  rncp_level?: string;
  rncp_url?: string;
  presentation_title?: string;
  cta_title?: string;
  cta_subtitle?: string;
  meta_title?: string;
  meta_description?: string;
  statut: 'publie' | 'brouillon';
  createdAt: string;
}

export interface BlogArticle {
  id: string;
  titre: string;
  extrait: string;
  contenu?: string;
  category_id?: string;
  categorie: string;
  author_id?: string;
  auteur: string;
  cover_image_url?: string;
  read_time_mins?: string;
  is_featured?: boolean;
  date: string;
  meta_title?: string;
  meta_description?: string;
  statut: 'publie' | 'brouillon';
  site: SiteId;
}

export interface OffreEmploi {
  id: string;
  titre: string;
  entreprise: string;
  lieu: string;
  postal_code?: string;
  contract_type_id?: string;
  contrat: string;
  profession_id?: string;
  job_id?: string;
  salaire?: string;
  duration?: string;
  secteur: string;
  short_desc?: string;
  description: string;
  experience?: string;
  urgent: boolean;
  date: string;
  expires_at?: string;
  statut: 'publie' | 'brouillon';
  site: SiteId;
}

export interface Metier {
  id: string;
  nom: string;
  slug: string;
  secteur: string;
  description: string;
  statut: 'publie' | 'brouillon';
}

export interface Coach {
  id: string;
  nom: string;
  email: string;
  phone?: string;
  avatar_url?: string;
  titre: string;
  short_bio?: string;
  bio: string;
  experience_years?: string;
  languages?: string;
  city_id?: string;
  localisation: string;
  visible: boolean;
  statut: string;
  meta_title?: string;
  meta_description?: string;
  createdAt: string;
}

export interface Creneau {
  id: string;
  date: string;
  heure: string;
  coach?: string;
  coach_nom?: string;
  client_nom?: string;
  client_email?: string;
  statut: string;
  notes?: string;
}

export interface Formateur {
  id: string;
  nom: string;
  email: string;
  region: string;
  expertise: string[];
  tjm?: string;
  disponibilite: boolean;
  modalite: string[];
  bio: string;
  certifications: string[];
  statut: 'actif' | 'inactif';
  createdAt: string;
}

// L'interface AppData est conservée mais vide par défaut car les pages vont fetch les données
export interface AppData {
  formations: Formation[];
  offresEmploi: OffreEmploi[];
  metiers: Metier[];
  offresIT: OffreEmploi[];
  articles: BlogArticle[];
  coachs: Coach[];
  creneaux: Creneau[];
  formateurs: Formateur[];
}

export const defaultData: AppData = {
  formations: [],
  offresEmploi: [],
  metiers: [],
  offresIT: [],
  articles: [],
  coachs: [],
  creneaux: [],
  formateurs: []
};

// ─── Context ──────────────────────────────────────────────────────────────────

interface AppContextType {
  currentUser: User | null;
  users: User[]; // Peut-être rempli via API si besoin
  data: AppData; // Données par défaut vides, à utiliser comme fallback
  login: (username: string, password: string) => Promise<{ ok: boolean; error?: string }>;
  logout: () => Promise<void>;
  setUsers: React.Dispatch<React.SetStateAction<User[]>>;
  setData: React.Dispatch<React.SetStateAction<AppData>>;
  canAccessSite: (site: SiteId) => boolean;
  isLoadingAuth: boolean;
}

const AppContext = createContext<AppContextType | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [users, setUsers] = useState<User[]>([]);
  const [data, setData] = useState<AppData>(defaultData);
  const [isLoadingAuth, setIsLoadingAuth] = useState(true);

  // Vérifier la session au chargement
  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('nexytal_token');
      if (!token) {
        setIsLoadingAuth(false);
        return;
      }
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      try {
        const response = await api.get('/admin/me');
        if (response.data?.data) {
          const d = response.data.data;
          setCurrentUser(mapApiAdminToUser(d, d.sites));
        }
      } catch {
        setCurrentUser(null);
        localStorage.removeItem('nexytal_token');
        delete api.defaults.headers.common['Authorization'];
      } finally {
        setIsLoadingAuth(false);
      }
    };
    checkAuth();
  }, []);

  const login = useCallback(async (username: string, password: string): Promise<{ ok: boolean; error?: string }> => {
    try {
      const response = await api.post('/admin/login', { email: username, password });

      if (response.data?.data?.admin) {
        const { admin, sites, token } = response.data.data;
        setCurrentUser(mapApiAdminToUser(admin, sites));
        if (token) {
          localStorage.setItem('nexytal_token', token);
          api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        }
        return { ok: true };
      }
      return { ok: false, error: 'Réponse serveur invalide.' };
    } catch (err: unknown) {
      const axiosErr = err as { response?: { status?: number; data?: { error?: string } } };
      const status = axiosErr.response?.status;
      const msg = axiosErr.response?.data?.error;
      if (status === 401) return { ok: false, error: msg || 'Email ou mot de passe incorrect.' };
      if (status === 429) return { ok: false, error: msg || 'Trop de tentatives. Réessayez plus tard.' };
      if (status === 500) return { ok: false, error: 'Erreur serveur. Contactez l\'administrateur.' };
      return { ok: false, error: msg || 'Impossible de se connecter au serveur.' };
    }
  }, []);

  const logout = useCallback(async () => {
    try {
      await api.post('/admin/logout');
    } catch (err) {
      console.error("Erreur déconnexion API", err);
    }
    setCurrentUser(null);
    localStorage.removeItem('nexytal_token');
    delete api.defaults.headers.common['Authorization'];
  }, []);

  const canAccessSite = useCallback((site: SiteId): boolean => {
    if (!currentUser) return false;
    if (currentUser.role === 'superadmin') return true;
    return currentUser.sites?.includes(site) || false;
  }, [currentUser]);

  return (
    <AppContext.Provider value={{ currentUser, users, data, login, logout, setUsers, setData, canAccessSite, isLoadingAuth }}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}
