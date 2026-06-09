import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

// ─── Types ────────────────────────────────────────────────────────────────────

export type Role = 'superadmin' | 'admin' | 'user';
export type SiteId = 'formation' | 'medical' | 'recrutement' | 'carriere' | 'coaching' | 'trainer';

export interface User {
  id: string;
  username: string;
  email: string;
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
  categorie: string;
  description: string;
  programme: string;
  duree: string;
  niveau: string;
  certifiante: boolean;
  rncp?: string;
  image?: string;
  statut: 'publie' | 'brouillon';
  createdAt: string;
}

export interface BlogArticle {
  id: string;
  titre: string;
  extrait: string;
  categorie: string;
  auteur: string;
  date: string;
  image?: string;
  lien?: string;
  statut: 'publie' | 'brouillon';
  site: SiteId;
}

export interface OffreEmploi {
  id: string;
  titre: string;
  entreprise: string;
  lieu: string;
  contrat: 'CDI' | 'CDD' | 'Intérim' | 'Freelance' | 'Stage';
  salaire?: string;
  secteur: string;
  description: string;
  experience?: string;
  urgent: boolean;
  date: string;
  statut: 'publie' | 'brouillon';
  site: SiteId;
  tags?: string[];
}

export interface Metier {
  id: string;
  nom: string;
  slug: string;
  secteur: string;
  description: string;
  salaire?: string;
  debouches?: string;
  image?: string;
  statut: 'publie' | 'brouillon';
}

export interface Coach {
  id: string;
  nom: string;
  titre: string;
  bio: string;
  specialites: string[];
  certifications: string[];
  langues: string[];
  localisation: string;
  photo?: string;
  visible: boolean;
  ordre: number;
  createdAt: string;
}

export interface Creneau {
  id: string;
  date: string;
  heure: string;
  coach?: string;
  capacite: number;
  statut: 'disponible' | 'reserve' | 'annule';
  reservation?: {
    prenom: string;
    nom: string;
    email: string;
    telephone: string;
    profil: string;
  };
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

export interface AppData {
  // Alt Formation
  formations: Formation[];
  // Nexytal Medical
  offresEmploi: OffreEmploi[];
  metiers: Metier[];
  // Nexytal Recrutement (IT)
  offresIT: OffreEmploi[];
  // Blog (partagé)
  articles: BlogArticle[];
  // Nexytal Coaching
  coachs: Coach[];
  creneaux: Creneau[];
  // Nexytal Trainer
  formateurs: Formateur[];
}

// ─── Default data ─────────────────────────────────────────────────────────────

const defaultData: AppData = {
  formations: [
    { id: 'f1', titre: 'Cybersécurité Fondamentaux', categorie: 'cybersécurité', description: 'Formation aux bases de la cybersécurité pour professionnels IT.', programme: 'Module 1 : Menaces, Module 2 : Réseaux, Module 3 : Cryptographie', duree: '5 jours', niveau: 'Débutant', certifiante: true, rncp: 'RNCP36399', statut: 'publie', createdAt: '2024-01-15' },
    { id: 'f2', titre: 'Intelligence Artificielle & Machine Learning', categorie: 'digital', description: 'Maîtrisez les fondamentaux de l\'IA et du ML appliqués en entreprise.', programme: 'Python, Scikit-learn, TensorFlow, cas pratiques', duree: '10 jours', niveau: 'Intermédiaire', certifiante: false, statut: 'publie', createdAt: '2024-02-01' },
    { id: 'f3', titre: 'Gestion RH & Droit Social', categorie: 'RH', description: 'Maîtrisez les obligations légales et la gestion des ressources humaines.', programme: 'Droit du travail, paie, recrutement, GPEC', duree: '3 jours', niveau: 'Intermédiaire', certifiante: true, rncp: 'RNCP35578', statut: 'publie', createdAt: '2024-02-10' },
    { id: 'f4', titre: 'Marketing Digital & Réseaux Sociaux', categorie: 'digital', description: 'Stratégies digitales et gestion des réseaux sociaux professionnels.', programme: 'SEO, SEA, Social Media, Analytics', duree: '4 jours', niveau: 'Débutant', certifiante: false, statut: 'brouillon', createdAt: '2024-03-01' },
  ],
  offresEmploi: [
    { id: 'm1', titre: 'Médecin Généraliste', entreprise: 'Clinique Saint-Louis', lieu: 'Paris 15e', contrat: 'CDI', salaire: '6 000 – 8 000 €/mois', secteur: 'medecin', description: 'Poste de médecin généraliste en clinique privée.', experience: '3 ans minimum', urgent: true, date: '2024-06-01', statut: 'publie', site: 'medical', tags: ['Médecine générale', 'Clinique'] },
    { id: 'm2', titre: 'Infirmier(e) DE', entreprise: 'Hôpital Lariboisière', lieu: 'Paris 10e', contrat: 'CDD', salaire: '2 200 – 2 800 €/mois', secteur: 'infirmier', description: 'Poste d\'infirmier en service de médecine interne.', urgent: false, date: '2024-06-05', statut: 'publie', site: 'medical', tags: ['Soins infirmiers', 'Hôpital'] },
    { id: 'm3', titre: 'Aide-Soignant(e)', entreprise: 'EHPAD Les Pins', lieu: 'Versailles', contrat: 'CDI', salaire: '1 800 – 2 100 €/mois', secteur: 'aide-soignant', description: 'Poste d\'aide-soignant en EHPAD.', urgent: false, date: '2024-06-08', statut: 'publie', site: 'medical', tags: ['Gérontologie', 'EHPAD'] },
  ],
  metiers: [
    { id: 'mt1', nom: 'Médecin', slug: 'medecin', secteur: 'Médecine', description: 'Le médecin diagnostique et traite les maladies.', salaire: '5 000 – 10 000 €/mois', debouches: 'Hôpital, clinique, cabinet libéral', statut: 'publie' },
    { id: 'mt2', nom: 'Infirmier(e)', slug: 'infirmier', secteur: 'Soins', description: 'L\'infirmier assure les soins aux patients.', salaire: '2 200 – 3 500 €/mois', debouches: 'Hôpital, clinique, EHPAD, libéral', statut: 'publie' },
    { id: 'mt3', nom: 'Kinésithérapeute', slug: 'kinesitherapeute', secteur: 'Rééducation', description: 'Le kiné rééduque les patients après blessure ou opération.', salaire: '2 500 – 5 000 €/mois', debouches: 'Cabinet libéral, hôpital, sport', statut: 'publie' },
  ],
  offresIT: [
    { id: 'it1', titre: 'Consultant Cybersécurité Senior', entreprise: 'TechSecure', lieu: 'Paris', contrat: 'CDI', salaire: '65 000 – 80 000 €/an', secteur: 'cyber', description: 'Mission de conseil en sécurité des SI pour grands comptes.', experience: '5 ans', urgent: false, date: '2024-06-01', statut: 'publie', site: 'recrutement', tags: ['ISO 27001', 'SIEM', 'Pentest'] },
    { id: 'it2', titre: 'DevOps Engineer', entreprise: 'CloudFirst', lieu: 'Lyon', contrat: 'CDI', salaire: '55 000 – 70 000 €/an', secteur: 'devops', description: 'Mise en place et gestion de pipelines CI/CD sur AWS.', experience: '3 ans', urgent: true, date: '2024-06-03', statut: 'publie', site: 'recrutement', tags: ['Kubernetes', 'Terraform', 'AWS'] },
    { id: 'it3', titre: 'Data Scientist', entreprise: 'DataLab', lieu: 'Paris', contrat: 'CDI', salaire: '50 000 – 65 000 €/an', secteur: 'data', description: 'Développement de modèles ML pour la prédiction client.', experience: '2 ans', urgent: false, date: '2024-06-05', statut: 'publie', site: 'recrutement', tags: ['Python', 'TensorFlow', 'SQL'] },
    { id: 'it4', titre: 'Développeur React Senior', entreprise: 'WebAgency', lieu: 'Remote', contrat: 'Freelance', salaire: '500 – 650 €/jour', secteur: 'dev', description: 'Développement d\'applications web React TypeScript.', experience: '4 ans', urgent: false, date: '2024-06-07', statut: 'brouillon', site: 'recrutement', tags: ['React', 'TypeScript', 'Node.js'] },
  ],
  articles: [
    { id: 'a1', titre: 'L\'IA au service du recrutement médical', extrait: 'Comment l\'intelligence artificielle transforme le recrutement dans le secteur de la santé.', categorie: 'IA & Santé', auteur: 'Dr. Martin', date: '2024-06-01', statut: 'publie', site: 'medical' },
    { id: 'a2', titre: 'Cybersécurité : les menaces de 2024', extrait: 'Tour d\'horizon des principales cybermenaces auxquelles font face les entreprises cette année.', categorie: 'Cybersécurité', auteur: 'Alice Dupont', date: '2024-05-20', statut: 'publie', site: 'recrutement' },
    { id: 'a3', titre: 'Comment réussir sa reconversion professionnelle', extrait: 'Les étapes clés pour changer de carrière avec succès et trouver sa voie.', categorie: 'Carrière', auteur: 'Sophie Bernard', date: '2024-05-15', statut: 'publie', site: 'carriere' },
    { id: 'a4', titre: 'Leadership et coaching d\'équipe', extrait: 'Les meilleures pratiques de coaching pour développer le leadership en entreprise.', categorie: 'Leadership', auteur: 'Jean-Paul Moreau', date: '2024-05-10', statut: 'publie', site: 'coaching' },
    { id: 'a5', titre: 'Choisir le bon formateur pour votre équipe', extrait: 'Critères essentiels pour sélectionner un formateur professionnel adapté à vos besoins.', categorie: 'Formation', auteur: 'Marie Leclerc', date: '2024-05-05', statut: 'brouillon', site: 'trainer' },
    { id: 'a6', titre: 'Certifications RNCP : tout ce qu\'il faut savoir', extrait: 'Guide complet sur les certifications reconnues par l\'État et leur valeur sur le marché.', categorie: 'Formation', auteur: 'Pierre Durand', date: '2024-04-28', statut: 'publie', site: 'formation' },
  ],
  coachs: [
    { id: 'c1', nom: 'Marie Fontaine', titre: 'Coach Exécutif ICF PCC', bio: 'Spécialiste du coaching de dirigeants avec 10 ans d\'expérience.', specialites: ['Dirigeants', 'Leadership', 'Stratégie'], certifications: ['ICF PCC', 'EMCC'], langues: ['FR', 'EN'], localisation: 'Paris', visible: true, ordre: 1, createdAt: '2023-01-10' },
    { id: 'c2', nom: 'Thomas Renard', titre: 'Coach Certifié EMCC', bio: 'Expert en coaching d\'équipe et management.', specialites: ['Équipes', 'Management', 'Cohésion'], certifications: ['EMCC', 'ICF ACC'], langues: ['FR'], localisation: 'Lyon', visible: true, ordre: 2, createdAt: '2023-03-15' },
    { id: 'c3', nom: 'Isabelle Morin', titre: 'Coach Reconversion ICF MCC', bio: 'Accompagnement des transitions professionnelles et reconversions.', specialites: ['Reconversion', 'Managers', 'Bien-être'], certifications: ['ICF MCC'], langues: ['FR', 'ES'], localisation: 'Bordeaux', visible: false, ordre: 3, createdAt: '2023-06-01' },
  ],
  creneaux: [
    { id: 'cr1', date: '2024-06-15', heure: '09:00', coach: 'c1', capacite: 1, statut: 'disponible' },
    { id: 'cr2', date: '2024-06-15', heure: '10:30', coach: 'c1', capacite: 1, statut: 'reserve', reservation: { prenom: 'Paul', nom: 'Dubois', email: 'paul.dubois@email.com', telephone: '06 12 34 56 78', profil: 'Directeur commercial' } },
    { id: 'cr3', date: '2024-06-16', heure: '14:00', coach: 'c2', capacite: 1, statut: 'disponible' },
    { id: 'cr4', date: '2024-06-17', heure: '11:00', coach: 'c3', capacite: 1, statut: 'annule' },
  ],
  formateurs: [
    { id: 'ft1', nom: 'Lucas Martin', email: 'lucas.martin@email.com', region: 'Île-de-France', expertise: ['IA', 'Data Science', 'Python'], tjm: '800 €', disponibilite: true, modalite: ['Présentiel', 'Distanciel'], bio: 'Formateur expert en IA avec 8 ans d\'expérience.', certifications: ['AWS Certified', 'Google Cloud'], statut: 'actif', createdAt: '2023-02-01' },
    { id: 'ft2', nom: 'Camille Petit', email: 'camille.petit@email.com', region: 'Auvergne-Rhône-Alpes', expertise: ['Cybersécurité', 'Réseaux', 'ISO 27001'], tjm: '750 €', disponibilite: true, modalite: ['Présentiel'], bio: 'Experte cybersécurité certifiée CISSP.', certifications: ['CISSP', 'CEH'], statut: 'actif', createdAt: '2023-04-10' },
    { id: 'ft3', nom: 'Antoine Leroy', email: 'antoine.leroy@email.com', region: 'Nouvelle-Aquitaine', expertise: ['Management', 'RH', 'Leadership'], tjm: '650 €', disponibilite: false, modalite: ['Distanciel', 'Hybride'], bio: 'Coach et formateur en management depuis 12 ans.', certifications: ['ICF ACC'], statut: 'inactif', createdAt: '2023-07-20' },
  ],
};

// ─── Users ────────────────────────────────────────────────────────────────────

const defaultUsers: User[] = [
  { id: 'u1', username: 'superadmin', email: 'admin@nexytal.fr', role: 'superadmin', sites: ['formation', 'medical', 'recrutement', 'carriere', 'coaching', 'trainer'], createdAt: '2024-01-01', active: true },
  { id: 'u2', username: 'admin_formation', email: 'formation@nexytal.fr', role: 'admin', sites: ['formation'], createdAt: '2024-02-01', active: true },
  { id: 'u3', username: 'admin_medical', email: 'medical@nexytal.fr', role: 'admin', sites: ['medical'], createdAt: '2024-02-15', active: true },
  { id: 'u4', username: 'user_recrutement', email: 'recrutement@nexytal.fr', role: 'user', sites: ['recrutement'], createdAt: '2024-03-01', active: true },
  { id: 'u5', username: 'admin_coaching', email: 'coaching@nexytal.fr', role: 'admin', sites: ['coaching', 'carriere'], createdAt: '2024-03-10', active: false },
];

// ─── Context ──────────────────────────────────────────────────────────────────

interface AppContextType {
  currentUser: User | null;
  users: User[];
  data: AppData;
  login: (username: string, password: string) => boolean;
  logout: () => void;
  setUsers: React.Dispatch<React.SetStateAction<User[]>>;
  setData: React.Dispatch<React.SetStateAction<AppData>>;
  canAccessSite: (site: SiteId) => boolean;
}

const AppContext = createContext<AppContextType | null>(null);

const CREDENTIALS: Record<string, string> = {
  superadmin: 'Nexytal@2024!',
  admin_formation: 'Formation@123',
  admin_medical: 'Medical@123',
  user_recrutement: 'Recrut@123',
  admin_coaching: 'Coaching@123',
};

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [currentUser, setCurrentUser] = useState<User | null>(() => {
    try {
      const stored = localStorage.getItem('nexytal_user');
      return stored ? JSON.parse(stored) : null;
    } catch { return null; }
  });

  const [users, setUsers] = useState<User[]>(() => {
    try {
      const stored = localStorage.getItem('nexytal_users');
      return stored ? JSON.parse(stored) : defaultUsers;
    } catch { return defaultUsers; }
  });

  const [data, setData] = useState<AppData>(() => {
    try {
      const stored = localStorage.getItem('nexytal_data');
      return stored ? JSON.parse(stored) : defaultData;
    } catch { return defaultData; }
  });

  useEffect(() => {
    if (currentUser) localStorage.setItem('nexytal_user', JSON.stringify(currentUser));
    else localStorage.removeItem('nexytal_user');
  }, [currentUser]);

  useEffect(() => {
    localStorage.setItem('nexytal_users', JSON.stringify(users));
  }, [users]);

  useEffect(() => {
    localStorage.setItem('nexytal_data', JSON.stringify(data));
  }, [data]);

  const login = useCallback((username: string, password: string): boolean => {
    const expected = CREDENTIALS[username];
    if (!expected || expected !== password) return false;
    const user = users.find(u => u.username === username && u.active);
    if (!user) return false;
    setCurrentUser(user);
    return true;
  }, [users]);

  const logout = useCallback(() => {
    setCurrentUser(null);
    localStorage.removeItem('nexytal_user');
  }, []);

  const canAccessSite = useCallback((site: SiteId): boolean => {
    if (!currentUser) return false;
    if (currentUser.role === 'superadmin') return true;
    return currentUser.sites.includes(site);
  }, [currentUser]);

  return (
    <AppContext.Provider value={{ currentUser, users, data, login, logout, setUsers, setData, canAccessSite }}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}

export { defaultData };
