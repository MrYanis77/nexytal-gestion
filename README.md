# NEXYTAL Gestion

[Français](#version-française) | [English](#english-version)

## Version française

NEXYTAL Gestion est le back-office central de l'écosystème NEXYTAL. L'application permet aux équipes internes d'administrer, depuis une interface unique, les contenus et les activités métier de plusieurs sites spécialisés : formation, recrutement, santé, carrière, coaching et formateurs.

Le projet ne correspond donc pas à un site public isolé. Il sert de point de pilotage commun et expose également une API consommée par les sites publics NEXYTAL. Les données restent cloisonnées par site grâce à des droits d'accès et à un contexte de site transmis à l'API.

### Sites gérés

| Site                | Domaine métier                | Contenus principaux                                        |
| ------------------- | ----------------------------- | ---------------------------------------------------------- |
| Alt Formation       | Formation professionnelle     | Formations, catégories, tarifs et offres de carrière       |
| Nexytal Recrutement | Recrutement généraliste et IT | Offres, recruteurs, candidats et candidatures              |
| Nexytal Medical     | Emploi et contenus santé      | Offres médicales, métiers et articles                      |
| Nexytal Carrière    | Évolution professionnelle     | Contenus carrière, entreprises et offres                   |
| Nexytal Trainer     | Réseau de formateurs          | Profils, expertises, compétences et candidatures           |
| Nexytal Coaching    | Accompagnement professionnel  | Coachs, spécialités, disponibilités et demandes de contact |

### Fonctionnalités principales

#### Pilotage multi-sites

- Tableau de bord consolidé avec les indicateurs de recrutement et les contenus récents.
- Navigation par site et filtrage des données selon le périmètre de l'utilisateur.
- Gestion des référentiels partagés et spécifiques à chaque activité.

#### Gestion éditoriale

- Création, modification, publication et suppression d'articles de blog.
- Gestion des catégories, tags, auteurs et commentaires.
- Administration des contenus propres à chaque site : formations, tarifs, métiers, entreprises, coachs, formateurs et pages associées.
- Paramétrage des métadonnées SEO.

#### Recrutement et candidatures

- Gestion des entreprises, recruteurs, candidats, offres et candidatures.
- File de validation des recruteurs, des offres, des coachs et des formateurs.
- Publication ou rejet des profils et des offres, avec suivi des statuts.
- Consultation des offres publiées et des statistiques par site.
- Configuration des critères de scoring des candidatures.
- Portail recruteur pour suivre les candidatures et télécharger les pièces jointes autorisées.

#### Médias et données transverses

- Médiathèque centralisée pour les images, vidéos et documents.
- Suivi de l'espace disque utilisé par les téléversements.
- Gestion des abonnés, listes et campagnes de newsletter.
- Consultation de l'historique des envois d'e-mails.
- Traitement des consentements et demandes de suppression RGPD.
- Consultation et export des journaux d'activité et des logs système.

#### Administration et sécurité

- Authentification de l'administration par jeton et session, avec protection CSRF des écritures.
- Rôles `superadmin`, `admin`, `recruiter` et `user`.
- Affectation des utilisateurs aux sites qu'ils sont autorisés à gérer.
- Gestion des comptes, paramètres applicatifs et plans tarifaires.
- Journalisation des actions sensibles et limitation du débit des requêtes.

### Architecture technique

Le dépôt réunit deux parties :

- `src/` : interface d'administration React 19 et TypeScript, construite avec Vite, Tailwind CSS 4, shadcn/ui et Wouter ;
- `api/` : API REST PHP, organisée par modules métier et connectée à MySQL avec PDO.

Les routes protégées de l'API utilisent le préfixe `/api/admin`. Des routes `/api/public/{site_slug}/...` mettent à disposition les données destinées aux sites publics. Lors du build, le dossier `api/` est copié dans `dist/api/` afin de produire un livrable regroupant le front-end et l'API.

```text
api/
  config/       configuration et connexion à la base
  core/         authentification, routage, validation, audit et uploads
  modules/      modules métier de l'API
  uploads/      fichiers téléversés
src/
  components/   composants d'interface partagés
  contexts/     session utilisateur et état applicatif
  hooks/        hooks de chargement et de gestion des données
  lib/          client API, mappers et utilitaires
  pages/        écrans du back-office
scripts/        diagnostics et tests de déploiement/API
```

### Prérequis

- Node.js 20 ou version ultérieure ;
- pnpm 10 (recommandé) ou npm ;
- PHP 8 avec l'extension PDO MySQL pour exécuter l'API localement ;
- MySQL ou MariaDB.

### Démarrage du front-end

```bash
pnpm install
pnpm dev
```

L'interface est servie par Vite, par défaut sur `http://localhost:3000`. En développement, les appels `/api` sont actuellement transmis à `https://connexion.nexytal.com` par la configuration de `vite.config.ts`.

Pour utiliser une autre API, créer ou adapter `.env.development` :

```dotenv
VITE_API_URL=https://exemple.test/api
```

### Configuration de l'API

Copier `api/config/.env.example` vers `api/config/.env` (ou vers `api/config/env` sur un hébergement Ionos), puis renseigner au minimum :

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_NAME=nexytal
DB_USER=nexytal
DB_PASSWORD=mot_de_passe_a_remplacer
DB_CHARSET=utf8mb4

APP_ENV=development
JWT_SECRET=une_cle_longue_unique_et_aleatoire
```

Les identifiants de base de données, secrets JWT et paramètres SMTP ne doivent jamais être commités. Le fichier d'exemple documente aussi la configuration des e-mails, des uploads, du CDN, des proxys de confiance et des tests de santé.

Le schéma de référence se trouve dans `schema_v2.sql`. Un export de la base utilisée par le projet est également conservé dans `api/sql/shema.sql`. Vérifier le contenu et la cible avant tout import dans une base existante.

### Commandes utiles

```bash
pnpm dev                 # serveur de développement Vite
pnpm check               # vérification TypeScript
pnpm build               # build de production dans dist/
pnpm preview             # prévisualisation du build
pnpm test:api            # tests d'insertion de l'API
pnpm test:deploy         # contrôles rapides du déploiement
pnpm test:deploy:full    # contrôles complets du déploiement
```

Les scripts de test d'API ciblent un environnement configuré et peuvent effectuer des écritures temporaires. Consulter leurs variables d'environnement avant de les lancer sur une instance partagée.

### Déploiement

```bash
pnpm build
```

Le résultat est généré dans `dist/`, API comprise. L'hébergement doit :

- servir l'application monopage en redirigeant les routes front-end vers `index.html` ;
- exécuter PHP pour les requêtes sous `/api` ;
- autoriser l'écriture dans le répertoire configuré pour les uploads ;
- fournir les variables d'environnement de production ;
- utiliser HTTPS et une valeur `JWT_SECRET` forte et propre à l'environnement.

Après déploiement, les points de contrôle de base sont `GET /api/health` et `GET /api/health/db`.

---

## English version

NEXYTAL Gestion is the central back office for the NEXYTAL ecosystem. It gives internal teams a single interface from which they can manage the content and business operations of several specialized websites covering training, recruitment, healthcare, career development, coaching, and professional trainers.

This project is therefore not a standalone public website. It is a shared control center that also exposes an API consumed by NEXYTAL's public websites. Data is scoped by website through access permissions and a site context sent to the API.

### Managed websites

| Website             | Business area                     | Main content                                      |
| ------------------- | --------------------------------- | ------------------------------------------------- |
| Alt Formation       | Professional training             | Courses, categories, pricing, and career openings |
| Nexytal Recrutement | General and IT recruitment        | Jobs, recruiters, candidates, and applications    |
| Nexytal Medical     | Healthcare jobs and content       | Medical jobs, professions, and articles           |
| Nexytal Carrière    | Career development                | Career content, companies, and job openings       |
| Nexytal Trainer     | Professional trainer network      | Profiles, expertise, skills, and applications     |
| Nexytal Coaching    | Professional coaching and support | Coaches, specialties, availability, and inquiries |

### Main features

#### Multi-site management

- Consolidated dashboard showing recruitment metrics and recent content.
- Site-based navigation and data filtering according to each user's access scope.
- Management of shared reference data and business-specific catalogs.

#### Editorial management

- Creation, editing, publication, and deletion of blog posts.
- Management of categories, tags, authors, and comments.
- Administration of site-specific content such as courses, pricing, professions, companies, coaches, trainers, and related pages.
- SEO metadata management.

#### Recruitment and applications

- Management of companies, recruiters, candidates, job offers, and applications.
- Review queues for recruiters, job offers, coaches, and trainers.
- Publication or rejection of profiles and job offers, with status tracking.
- Access to published offers and site-level statistics.
- Configuration of application scoring criteria.
- Recruiter portal for reviewing applications and downloading authorized attachments.

#### Media and cross-functional data

- Centralized media library for images, videos, and documents.
- Storage usage monitoring for uploaded files.
- Management of newsletter subscribers, lists, and campaigns.
- Access to email delivery history.
- Processing of GDPR consent records and deletion requests.
- Viewing and exporting activity logs and system logs.

#### Administration and security

- Token- and session-based administration authentication, with CSRF protection for write operations.
- `superadmin`, `admin`, `recruiter`, and `user` roles.
- Assignment of users to the websites they are allowed to manage.
- Management of accounts, application settings, and pricing plans.
- Auditing of sensitive operations and API rate limiting.

### Technical architecture

The repository contains two main parts:

- `src/`: the React 19 and TypeScript administration interface, built with Vite, Tailwind CSS 4, shadcn/ui, and Wouter;
- `api/`: a modular PHP REST API connected to MySQL through PDO.

Protected API routes use the `/api/admin` prefix. Routes under `/api/public/{site_slug}/...` expose data for the public websites. During the build, the `api/` directory is copied to `dist/api/`, producing a deployment package that contains both the front end and the API.

```text
api/
  config/       configuration and database connection
  core/         authentication, routing, validation, auditing, and uploads
  modules/      API business modules
  uploads/      uploaded files
src/
  components/   shared interface components
  contexts/     user session and application state
  hooks/        data loading and management hooks
  lib/          API client, mappers, and utilities
  pages/        back-office screens
scripts/        API diagnostics and deployment tests
```

### Requirements

- Node.js 20 or later;
- pnpm 10 (recommended) or npm;
- PHP 8 with the PDO MySQL extension to run the API locally;
- MySQL or MariaDB.

### Starting the front end

```bash
pnpm install
pnpm dev
```

Vite serves the interface at `http://localhost:3000` by default. In development, `/api` requests are currently proxied to `https://connexion.nexytal.com` through `vite.config.ts`.

To use a different API, create or update `.env.development`:

```dotenv
VITE_API_URL=https://example.test/api
```

### API configuration

Copy `api/config/.env.example` to `api/config/.env` (or to `api/config/env` on Ionos hosting), then provide at least the following values:

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_NAME=nexytal
DB_USER=nexytal
DB_PASSWORD=replace_with_a_password
DB_CHARSET=utf8mb4

APP_ENV=development
JWT_SECRET=a_long_unique_random_secret
```

Database credentials, JWT secrets, and SMTP settings must never be committed. The example file also documents email, upload, CDN, trusted proxy, and health-test settings.

The reference schema is stored in `schema_v2.sql`. An export of the database used by the project is also available in `api/sql/shema.sql`. Check both the file contents and the target database before importing anything into an existing database.

### Useful commands

```bash
pnpm dev                 # start the Vite development server
pnpm check               # run TypeScript checks
pnpm build               # create the production build in dist/
pnpm preview             # preview the production build
pnpm test:api            # run API insertion tests
pnpm test:deploy         # run quick deployment checks
pnpm test:deploy:full    # run full deployment checks
```

The API test scripts target a configured environment and may perform temporary writes. Review their environment variables before running them against a shared instance.

### Deployment

```bash
pnpm build
```

The output is generated in `dist/` and includes the API. The hosting environment must:

- serve the single-page application and redirect front-end routes to `index.html`;
- execute PHP for requests under `/api`;
- allow writes to the configured upload directory;
- provide the production environment variables;
- use HTTPS and a strong, environment-specific `JWT_SECRET` value.

After deployment, the basic health-check endpoints are `GET /api/health` and `GET /api/health/db`.
