import { useApp } from '@/contexts/AppContext';
import { Link } from 'wouter';
import { GraduationCap, Stethoscope, Briefcase, TrendingUp, Heart, BookOpen, ArrowRight, FileText, Users, Calendar } from 'lucide-react';

const SITES = [
  {
    id: 'formation' as const,
    label: 'Alt Formation',
    icon: GraduationCap,
    color: '#7C3AED',
    bg: 'rgba(124,58,237,0.1)',
    href: '/formation',
    description: 'Formations, certifications RNCP, blog',
  },
  {
    id: 'medical' as const,
    label: 'Nexytal Medical',
    icon: Stethoscope,
    color: '#059669',
    bg: 'rgba(5,150,105,0.1)',
    href: '/medical',
    description: 'Offres d\'emploi santé, métiers, blog',
  },
  {
    id: 'recrutement' as const,
    label: 'Nexytal Recrutement',
    icon: Briefcase,
    color: '#2563EB',
    bg: 'rgba(37,99,235,0.1)',
    href: '/recrutement',
    description: 'Offres IT, ressources, blog',
  },
  {
    id: 'carriere' as const,
    label: 'Nexytal Carrière',
    icon: TrendingUp,
    color: '#D97706',
    bg: 'rgba(217,119,6,0.1)',
    href: '/carriere',
    description: 'Blog carrière, articles, newsletter',
  },
  {
    id: 'coaching' as const,
    label: 'Nexytal Coaching',
    icon: Heart,
    color: '#DC2626',
    bg: 'rgba(220,38,38,0.1)',
    href: '/coaching',
    description: 'Coachs, créneaux, blog',
  },
  {
    id: 'trainer' as const,
    label: 'Nexytal Trainer',
    icon: BookOpen,
    color: '#0891B2',
    bg: 'rgba(8,145,178,0.1)',
    href: '/trainer',
    description: 'Formateurs, expertises, blog',
  },
];

export default function Dashboard() {
  const { currentUser, data, canAccessSite } = useApp();

  const stats = [
    { label: 'Formations', value: data.formations.length, icon: GraduationCap, color: '#7C3AED' },
    { label: 'Offres Santé', value: data.offresEmploi.length, icon: Stethoscope, color: '#059669' },
    { label: 'Offres IT', value: data.offresIT.length, icon: Briefcase, color: '#2563EB' },
    { label: 'Articles', value: data.articles.length, icon: FileText, color: '#D97706' },
    { label: 'Coachs', value: data.coachs.length, icon: Heart, color: '#DC2626' },
    { label: 'Formateurs', value: data.formateurs.length, icon: BookOpen, color: '#0891B2' },
    { label: 'Créneaux', value: data.creneaux.length, icon: Calendar, color: '#6366F1' },
    { label: 'Métiers', value: data.metiers.length, icon: Users, color: '#EC4899' },
  ];

  const recentArticles = [...data.articles].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 5);

  return (
    <div className="p-6 space-y-8 fade-up">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>
          Bonjour, {currentUser?.username} 👋
        </h1>
        <p className="text-muted-foreground text-sm mt-1">
          Vue d'ensemble de tous vos sites NEXYTAL
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {stats.map(s => (
          <div key={s.label} className="rounded-xl border border-border p-4 bg-card">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-7 h-7 rounded-lg flex items-center justify-center"
                style={{ background: s.color + '20' }}>
                <s.icon className="w-3.5 h-3.5" style={{ color: s.color }} />
              </div>
              <span className="text-xs text-muted-foreground">{s.label}</span>
            </div>
            <p className="text-2xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>
              {s.value}
            </p>
          </div>
        ))}
      </div>

      {/* Sites grid */}
      <div>
        <h2 className="text-base font-semibold text-foreground mb-4" style={{ fontFamily: 'Space Grotesk' }}>
          Sites gérés
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {SITES.map(site => {
            const accessible = canAccessSite(site.id);
            return (
              <div key={site.id}
                className={`rounded-xl border border-border p-5 transition-all duration-200 ${accessible ? 'hover:border-border/80 cursor-pointer group' : 'opacity-40 cursor-not-allowed'}`}
                style={{ background: accessible ? site.bg : undefined }}>
                <div className="flex items-start justify-between mb-3">
                  <div className="w-10 h-10 rounded-xl flex items-center justify-center"
                    style={{ background: site.color + '25' }}>
                    <site.icon className="w-5 h-5" style={{ color: site.color }} />
                  </div>
                  {accessible && (
                    <Link href={site.href}>
                      <div className="w-7 h-7 rounded-lg flex items-center justify-center border border-border/50 text-muted-foreground group-hover:text-foreground group-hover:border-border transition-all">
                        <ArrowRight className="w-3.5 h-3.5" />
                      </div>
                    </Link>
                  )}
                </div>
                <h3 className="font-semibold text-foreground text-sm mb-1" style={{ fontFamily: 'Space Grotesk' }}>
                  {site.label}
                </h3>
                <p className="text-xs text-muted-foreground">{site.description}</p>
              </div>
            );
          })}
        </div>
      </div>

      {/* Recent articles */}
      <div>
        <h2 className="text-base font-semibold text-foreground mb-4" style={{ fontFamily: 'Space Grotesk' }}>
          Articles récents
        </h2>
        <div className="rounded-xl border border-border overflow-hidden bg-card">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border bg-secondary/50">
                <th className="text-left px-4 py-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Titre</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider hidden sm:table-cell">Site</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider hidden md:table-cell">Catégorie</th>
                <th className="text-left px-4 py-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Statut</th>
              </tr>
            </thead>
            <tbody>
              {recentArticles.map((a, i) => {
                const site = SITES.find(s => s.id === a.site);
                return (
                  <tr key={a.id} className={`border-b border-border/50 hover:bg-secondary/30 transition-colors ${i === recentArticles.length - 1 ? 'border-0' : ''}`}>
                    <td className="px-4 py-3 text-foreground font-medium truncate max-w-[200px]">{a.titre}</td>
                    <td className="px-4 py-3 hidden sm:table-cell">
                      {site && (
                        <span className="inline-flex items-center gap-1.5 text-xs px-2 py-0.5 rounded-full"
                          style={{ background: site.color + '20', color: site.color }}>
                          <site.icon className="w-3 h-3" />
                          {site.label}
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-muted-foreground text-xs hidden md:table-cell">{a.categorie}</td>
                    <td className="px-4 py-3">
                      <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${a.statut === 'publie' ? 'bg-green-500/15 text-green-400' : 'bg-yellow-500/15 text-yellow-400'}`}>
                        {a.statut === 'publie' ? 'Publié' : 'Brouillon'}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
