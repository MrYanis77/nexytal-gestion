import { useState } from 'react';
import { Link, useLocation } from 'wouter';
import { useApp, SiteId } from '@/contexts/AppContext';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import {
  LayoutDashboard, GraduationCap, Stethoscope, Briefcase,
  TrendingUp, Heart, Users, LogOut, ChevronLeft, ChevronRight,
  Settings, BookOpen, Zap, Menu, X
} from 'lucide-react';

interface NavItem {
  label: string;
  href: string;
  icon: React.ReactNode;
  site?: SiteId;
  color: string;
  badge?: string;
}

const NAV_ITEMS: NavItem[] = [
  { label: 'Tableau de bord', href: '/dashboard', icon: <LayoutDashboard className="w-4 h-4" />, color: '#2563EB' },
  { label: 'Alt Formation', href: '/formation', icon: <GraduationCap className="w-4 h-4" />, site: 'formation', color: '#7C3AED' },
  { label: 'Nexytal Medical', href: '/medical', icon: <Stethoscope className="w-4 h-4" />, site: 'medical', color: '#059669' },
  { label: 'Nexytal Recrutement', href: '/recrutement', icon: <Briefcase className="w-4 h-4" />, site: 'recrutement', color: '#2563EB' },
  { label: 'Nexytal Carrière', href: '/carriere', icon: <TrendingUp className="w-4 h-4" />, site: 'carriere', color: '#D97706' },
  { label: 'Nexytal Coaching', href: '/coaching', icon: <Heart className="w-4 h-4" />, site: 'coaching', color: '#DC2626' },
  { label: 'Nexytal Trainer', href: '/trainer', icon: <BookOpen className="w-4 h-4" />, site: 'trainer', color: '#0891B2' },
];

const ADMIN_ITEMS: NavItem[] = [
  { label: 'Utilisateurs', href: '/users', icon: <Users className="w-4 h-4" />, color: '#6B7280' },
  { label: 'Paramètres', href: '/settings', icon: <Settings className="w-4 h-4" />, color: '#6B7280' },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { currentUser, logout, canAccessSite } = useApp();
  const [location] = useLocation();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  const initials = currentUser?.username.slice(0, 2).toUpperCase() ?? 'NU';

  const roleLabel: Record<string, string> = {
    superadmin: 'Super Admin',
    admin: 'Administrateur',
    user: 'Utilisateur',
  };

  const roleColor: Record<string, string> = {
    superadmin: 'bg-purple-500/20 text-purple-300',
    admin: 'bg-blue-500/20 text-blue-300',
    user: 'bg-green-500/20 text-green-300',
  };

  const NavContent = () => (
    <div className="flex flex-col h-full">
      {/* Logo */}
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

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-4 px-2 space-y-1">
        {NAV_ITEMS.map(item => {
          const accessible = !item.site || canAccessSite(item.site);
          const active = location === item.href || location.startsWith(item.href + '/');
          if (!accessible) return null;
          return (
            <Link key={item.href} href={item.href}>
              <div onClick={() => setMobileOpen(false)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-150 group cursor-pointer
                  ${active
                    ? 'text-white'
                    : 'text-muted-foreground hover:text-foreground hover:bg-secondary'
                  }`}
                style={active ? { background: item.color + '22', borderLeft: `2px solid ${item.color}`, paddingLeft: '10px' } : {}}
              >
                <span style={{ color: active ? item.color : undefined }}
                  className={`flex-shrink-0 transition-colors ${!active ? 'group-hover:text-foreground' : ''}`}>
                  {item.icon}
                </span>
                {!collapsed && (
                  <span className="text-sm font-medium truncate">{item.label}</span>
                )}
                {!collapsed && active && item.site && (
                  <span className="ml-auto w-1.5 h-1.5 rounded-full pulse-dot flex-shrink-0"
                    style={{ background: item.color }} />
                )}
              </div>
            </Link>
          );
        })}

        {/* Admin section */}
        {currentUser?.role === 'superadmin' && (
          <>
            <div className={`pt-4 pb-2 ${collapsed ? 'hidden' : ''}`}>
              <p className="text-xs font-semibold text-muted-foreground/50 uppercase tracking-wider px-3">
                Administration
              </p>
            </div>
            {collapsed && <div className="my-2 border-t border-border" />}
            {ADMIN_ITEMS.map(item => {
              const active = location === item.href;
              return (
                <Link key={item.href} href={item.href}>
                  <div onClick={() => setMobileOpen(false)}
                    className={`flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-150 group cursor-pointer
                      ${active
                        ? 'bg-secondary text-foreground'
                        : 'text-muted-foreground hover:text-foreground hover:bg-secondary'
                      }`}
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

      {/* User */}
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
      {/* Mobile overlay */}
      {mobileOpen && (
        <div className="fixed inset-0 z-40 bg-black/60 lg:hidden" onClick={() => setMobileOpen(false)} />
      )}

      {/* Mobile sidebar */}
      <aside className={`fixed inset-y-0 left-0 z-50 w-64 bg-sidebar border-r border-border transform transition-transform duration-300 lg:hidden
        ${mobileOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <NavContent />
      </aside>

      {/* Desktop sidebar */}
      <aside className={`hidden lg:flex flex-col border-r border-border transition-all duration-300 flex-shrink-0
        ${collapsed ? 'w-16' : 'w-60'}`}
        style={{ background: 'oklch(0.12 0.008 264)' }}>
        <NavContent />
        {/* Collapse toggle */}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="absolute bottom-20 -right-3 w-6 h-6 rounded-full border border-border bg-sidebar flex items-center justify-center text-muted-foreground hover:text-foreground transition-colors shadow-md z-10"
        >
          {collapsed ? <ChevronRight className="w-3 h-3" /> : <ChevronLeft className="w-3 h-3" />}
        </button>
      </aside>

      {/* Main content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Mobile header */}
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
