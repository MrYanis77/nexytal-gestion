import { useState } from 'react';
import { Link, useLocation } from 'wouter';
import { useApp, SiteId } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { NEXYTAL_SITES } from '@/lib/nexytal-sites';
import {
  LayoutDashboard, GraduationCap, Stethoscope, Briefcase,
  TrendingUp, Heart, Users, LogOut, ChevronLeft, ChevronRight,
  Settings, BookOpen, Zap, Menu, X, Database, Images, ClipboardCheck, CheckCircle, SlidersHorizontal, ScrollText
} from 'lucide-react';

interface NavItem {
  label: string;
  href: string;
  icon: React.ReactNode;
  site?: SiteId;
  color: string;
  badge?: string;
  role?: 'recruiter' | 'admin';
}

const SITE_ICONS: Record<string, React.ReactNode> = {
  formation: <GraduationCap className="w-4 h-4" />,
  recrutement: <Briefcase className="w-4 h-4" />,
  medical: <Stethoscope className="w-4 h-4" />,
  carriere: <TrendingUp className="w-4 h-4" />,
  trainers: <BookOpen className="w-4 h-4" />,
  coaching: <Heart className="w-4 h-4" />,
};

const RECRUTEMENT_ITEMS: NavItem[] = [
  { label: 'Recrutement', href: '/recrutement-gestion', icon: <Briefcase className="w-4 h-4" />, color: '#2563EB', role: 'admin' },
  { label: 'Valid. recruteurs', href: '/validation-recruteurs', icon: <Users className="w-4 h-4" />, color: '#10B981', badge: 'pending_recruteurs', role: 'admin' },
  { label: 'Validation offres', href: '/validation-offres', icon: <ClipboardCheck className="w-4 h-4" />, color: '#2563EB', badge: 'pending_offres', role: 'admin' },
  { label: 'Valid. coachs', href: '/validation-coaches', icon: <Heart className="w-4 h-4" />, color: '#F59E0B', badge: 'pending_coaches', role: 'admin' },
  { label: 'Valid. formateurs', href: '/validation-trainers', icon: <BookOpen className="w-4 h-4" />, color: '#0891B2', badge: 'pending_trainers', role: 'admin' },
  { label: 'Offres publiées', href: '/offres-publiees', icon: <CheckCircle className="w-4 h-4" />, color: '#10B981', role: 'admin' },
  { label: 'Config scoring', href: '/config-scoring', icon: <SlidersHorizontal className="w-4 h-4" />, color: '#8B5CF6', role: 'admin' },
];

const GENERAL_ITEMS: NavItem[] = [
  { label: 'Tableau de bord', href: '/dashboard', icon: <LayoutDashboard className="w-4 h-4" />, color: '#2563EB' },
  { label: 'Médiathèque', href: '/media', icon: <Images className="w-4 h-4" />, color: '#8B5CF6', role: 'admin' },
];

const SITE_NAV_ITEMS: NavItem[] = NEXYTAL_SITES.map(s => ({
  label: s.label,
  href: s.contentHref,
  icon: SITE_ICONS[s.code] ?? <Briefcase className="w-4 h-4" />,
  site: s.appSiteId,
  color: s.color,
  role: 'admin' as const,
}));

const ADMIN_ITEMS: NavItem[] = [
  { label: 'Gestion Données', href: '/data-management', icon: <Database className="w-4 h-4" />, color: '#6366f1' },
  { label: 'Logs & exports', href: '/logs', icon: <ScrollText className="w-4 h-4" />, color: '#475569' },
  { label: 'Utilisateurs', href: '/users', icon: <Users className="w-4 h-4" />, color: '#6B7280' },
  { label: 'Paramètres', href: '/settings', icon: <Settings className="w-4 h-4" />, color: '#6B7280' },
];

function NavLink({
  item,
  collapsed,
  active,
  onNavigate,
  badge,
}: {
  item: NavItem;
  collapsed: boolean;
  active: boolean;
  onNavigate: () => void;
  badge?: React.ReactNode;
}) {
  return (
    <Link href={item.href}>
      <div
        onClick={onNavigate}
        className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-150 group cursor-pointer
          ${active ? 'text-white' : 'text-muted-foreground hover:text-foreground hover:bg-secondary'}`}
        style={active ? { background: item.color + '22', borderLeft: `2px solid ${item.color}`, paddingLeft: '10px' } : {}}
      >
        <span style={{ color: active ? item.color : undefined }}
          className={`flex-shrink-0 transition-colors ${!active ? 'group-hover:text-foreground' : ''}`}>
          {item.icon}
        </span>
        {!collapsed && <span className="text-sm font-medium truncate">{item.label}</span>}
        {!collapsed && badge}
      </div>
    </Link>
  );
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { currentUser, logout, canAccessSite } = useApp();
  const [location] = useLocation();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const { data: pendingData } = useFetch<{ pagination?: { total?: number }; data?: unknown[] }>(
    '/recrutement/offers/pending',
  );
  const pendingOffersCount = pendingData?.pagination?.total ?? pendingData?.data?.length ?? 0;

  const { data: pendingRecruteursData } = useFetch<{ data?: { count: number } }>('/recrutement/recruteurs/pending-count');
  const pendingRecruteursCount = pendingRecruteursData?.data?.count ?? 0;

  const { data: pendingCoachesData } = useFetch<{ data?: { count: number } }>('/coaching/coaches/pending-count');
  const pendingCoachesCount = pendingCoachesData?.data?.count ?? 0;

  const { data: pendingTrainersData } = useFetch<{ data?: { count: number } }>('/trainer/trainers/pending-count');
  const pendingTrainersCount = pendingTrainersData?.data?.count ?? 0;


  const initials = currentUser?.username.slice(0, 2).toUpperCase() ?? 'NU';

  const roleLabel: Record<string, string> = {
    superadmin: 'Super Admin',
    admin: 'Administrateur',
    recruiter: 'Recruteur',
    user: 'Utilisateur',
  };

  const roleColor: Record<string, string> = {
    superadmin: 'bg-purple-500/20 text-purple-300',
    admin: 'bg-blue-500/20 text-blue-300',
    recruiter: 'bg-cyan-500/20 text-cyan-300',
    user: 'bg-green-500/20 text-green-300',
  };

  const canSee = (item: NavItem) => {
    if (item.role === 'recruiter' && !['recruiter', 'superadmin', 'admin'].includes(currentUser?.role ?? '')) return false;
    if (item.role === 'admin' && !['superadmin', 'admin'].includes(currentUser?.role ?? '')) return false;
    if (item.site && !canAccessSite(item.site)) return false;
    return true;
  };

  const badgeFor = (item: NavItem) => {
    if (item.badge === 'pending_offres' && pendingOffersCount > 0) {
      return <span className="ml-auto text-xs font-semibold px-2 py-0.5 rounded-full bg-yellow-500/20 text-yellow-400">{pendingOffersCount}</span>;
    }
    if (item.badge === 'pending_recruteurs' && pendingRecruteursCount > 0) {
      return <span className="ml-auto text-xs font-semibold px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400">{pendingRecruteursCount}</span>;
    }

    if (item.badge === 'pending_coaches' && pendingCoachesCount > 0) {
      return <span className="ml-auto text-xs font-semibold px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-400">{pendingCoachesCount}</span>;
    }
    if (item.badge === 'pending_trainers' && pendingTrainersCount > 0) {
      return <span className="ml-auto text-xs font-semibold px-2 py-0.5 rounded-full bg-cyan-500/20 text-cyan-400">{pendingTrainersCount}</span>;
    }
    return null;
  };

  const renderSection = (title: string, items: NavItem[]) => {
    const visible = items.filter(canSee);
    if (visible.length === 0) return null;
    return (
      <>
        {!collapsed && (
          <p className="text-xs font-semibold text-muted-foreground/50 uppercase tracking-wider px-3 pt-3 pb-1">
            {title}
          </p>
        )}
        {collapsed && <div className="my-2 border-t border-border" />}
        {visible.map(item => {
          const active = location === item.href || (item.href !== '/dashboard' && location.startsWith(item.href));
          return (
            <NavLink
              key={item.href}
              item={item}
              collapsed={collapsed}
              active={active}
              onNavigate={() => setMobileOpen(false)}
              badge={badgeFor(item)}
            />
          );
        })}
      </>
    );
  };

  const NavContent = () => (
    <div className="flex flex-col h-full">
      <div className={`flex items-center gap-3 px-4 py-5 border-b border-border ${collapsed ? 'justify-center' : ''}`}>
        <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ background: 'linear-gradient(135deg, #2563EB, #7C3AED)' }}>
          <Zap className="w-4 h-4 text-white" />
        </div>
        {!collapsed && (
          <div className="min-w-0">
            <div className="font-bold text-sm tracking-wide text-foreground" style={{ fontFamily: 'Space Grotesk' }}>NEXYTAL</div>
            <div className="text-xs text-muted-foreground">Gestion</div>
          </div>
        )}
      </div>

      <nav className="flex-1 overflow-y-auto py-4 px-2 space-y-1">
        {renderSection('Général', GENERAL_ITEMS)}
        {renderSection('Recrutement', RECRUTEMENT_ITEMS)}
        {renderSection('Sites publics', SITE_NAV_ITEMS)}

        {currentUser?.role === 'superadmin' && (
          <>
            {!collapsed && (
              <p className="text-xs font-semibold text-muted-foreground/50 uppercase tracking-wider px-3 pt-4 pb-1">
                Administration
              </p>
            )}
            {collapsed && <div className="my-2 border-t border-border" />}
            {ADMIN_ITEMS.map(item => {
              const active = location === item.href;
              return (
                <Link key={item.href} href={item.href}>
                  <div onClick={() => setMobileOpen(false)}
                    className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-150 group cursor-pointer
                      ${active ? 'bg-secondary text-foreground' : 'text-muted-foreground hover:text-foreground hover:bg-secondary'}`}
                  >
                    <span className="flex-shrink-0">{item.icon}</span>
                    {!collapsed && <span className="text-sm font-medium">{item.label}</span>}
                  </div>
                </Link>
              );
            })}
          </>
        )}
      </nav>

      <div className="border-t border-border p-3">
        <div className={`flex items-center gap-3 ${collapsed ? 'justify-center' : ''}`}>
          <Avatar className="w-8 h-8 flex-shrink-0">
            <AvatarFallback className="text-xs font-bold" style={{ background: 'linear-gradient(135deg, #2563EB, #7C3AED)', color: 'white' }}>
              {initials}
            </AvatarFallback>
          </Avatar>
          {!collapsed && (
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-foreground truncate">{currentUser?.username}</p>
              <Badge className={`text-xs px-1.5 py-0 ${roleColor[currentUser?.role ?? 'user']}`} variant="outline">
                {roleLabel[currentUser?.role ?? 'user']}
              </Badge>
            </div>
          )}
          {!collapsed && (
            <Button variant="ghost" size="icon" onClick={logout}
              className="w-7 h-7 text-muted-foreground hover:text-destructive hover:bg-destructive/10 flex-shrink-0">
              <LogOut className="w-3.5 h-3.5" />
            </Button>
          )}
        </div>
        {collapsed && (
          <Button variant="ghost" size="icon" onClick={logout}
            className="w-full mt-2 h-7 text-muted-foreground hover:text-destructive hover:bg-destructive/10">
            <LogOut className="w-3.5 h-3.5" />
          </Button>
        )}
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-background overflow-hidden">
      {mobileOpen && (
        <div className="fixed inset-0 z-40 bg-black/60 lg:hidden" onClick={() => setMobileOpen(false)} />
      )}

      <aside className={`fixed inset-y-0 left-0 z-50 w-64 bg-sidebar border-r border-border transform transition-transform duration-300 lg:hidden
        ${mobileOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <NavContent />
      </aside>

      <aside className={`hidden lg:flex flex-col border-r border-border transition-all duration-300 flex-shrink-0 relative
        ${collapsed ? 'w-16' : 'w-60'}`}
        style={{ background: 'oklch(0.12 0.008 264)' }}>
        <NavContent />
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="absolute bottom-20 -right-3 w-6 h-6 rounded-full border border-border bg-sidebar flex items-center justify-center text-muted-foreground hover:text-foreground transition-colors shadow-md z-10"
        >
          {collapsed ? <ChevronRight className="w-3 h-3" /> : <ChevronLeft className="w-3 h-3" />}
        </button>
      </aside>

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="lg:hidden flex items-center gap-3 px-4 py-3 border-b border-border bg-sidebar">
          <button onClick={() => setMobileOpen(!mobileOpen)} className="text-muted-foreground hover:text-foreground">
            {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
          </button>
          <div className="flex items-center gap-2">
            <Zap className="w-4 h-4 text-primary" />
            <span className="font-bold text-sm" style={{ fontFamily: 'Space Grotesk' }}>NEXYTAL Gestion</span>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
