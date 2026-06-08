import { useState } from 'react';
import { useApp } from '@/contexts/AppContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';
import { Eye, EyeOff, Lock, User, Zap } from 'lucide-react';
import { useLocation } from 'wouter';

export default function Login() {
  const { login, currentUser } = useApp();
  const [, navigate] = useLocation();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);

  // Si déjà connecté, rediriger immédiatement
  if (currentUser) {
    navigate('/dashboard');
    return null;
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!username || !password) {
      toast.error('Veuillez remplir tous les champs.');
      return;
    }
    setLoading(true);
    await new Promise(r => setTimeout(r, 400));
    const ok = login(username.trim(), password);
    setLoading(false);
    if (ok) {
      navigate('/dashboard');
    } else {
      toast.error('Identifiants incorrects ou compte inactif.');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background relative overflow-hidden">
      {/* Background grid */}
      <div className="absolute inset-0 opacity-[0.03]" style={{
        backgroundImage: 'linear-gradient(rgba(255,255,255,0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.3) 1px, transparent 1px)',
        backgroundSize: '40px 40px'
      }} />
      {/* Glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full opacity-10"
        style={{ background: 'radial-gradient(circle, #2563EB 0%, transparent 70%)' }} />

      <div className="relative z-10 w-full max-w-md px-4 fade-up">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center gap-2 mb-4">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center"
              style={{ background: 'linear-gradient(135deg, #2563EB, #7C3AED)' }}>
              <Zap className="w-5 h-5 text-white" />
            </div>
            <span className="text-2xl font-bold tracking-tight" style={{ fontFamily: 'Space Grotesk' }}>
              NEXYTAL
            </span>
          </div>
          <h1 className="text-3xl font-bold text-foreground mb-1" style={{ fontFamily: 'Space Grotesk' }}>
            Espace Gestion
          </h1>
          <p className="text-muted-foreground text-sm">
            Connectez-vous pour accéder au tableau de bord
          </p>
        </div>

        {/* Card */}
        <div className="rounded-2xl border border-border p-8"
          style={{ background: 'oklch(0.13 0.008 264)', boxShadow: '0 24px 80px rgba(0,0,0,0.4)' }}>
          <form onSubmit={handleSubmit} className="space-y-5">
            <div className="space-y-2">
              <Label htmlFor="username" className="text-sm font-medium text-foreground/80">
                Identifiant
              </Label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  id="username"
                  type="text"
                  placeholder="superadmin"
                  value={username}
                  onChange={e => setUsername(e.target.value)}
                  className="pl-10 bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 focus:border-primary/50 h-11"
                  autoComplete="username"
                  autoFocus
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="password" className="text-sm font-medium text-foreground/80">
                Mot de passe
              </Label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  id="password"
                  type={showPwd ? 'text' : 'password'}
                  placeholder="••••••••••"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  className="pl-10 pr-10 bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 focus:border-primary/50 h-11"
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  onClick={() => setShowPwd(!showPwd)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showPwd ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <Button
              type="submit"
              disabled={loading}
              className="w-full h-11 font-semibold text-sm"
              style={{ background: 'linear-gradient(135deg, #2563EB, #1d4ed8)', boxShadow: '0 4px 20px rgba(37,99,235,0.3)' }}
            >
              {loading ? (
                <span className="flex items-center gap-2">
                  <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  Connexion…
                </span>
              ) : 'Se connecter'}
            </Button>
          </form>

          {/* Hint */}
          <div className="mt-6 p-3 rounded-lg border border-border/50 bg-secondary/50">
            <p className="text-xs text-muted-foreground text-center">
              Accès démo : <span className="font-mono text-foreground/70">superadmin</span> / <span className="font-mono text-foreground/70">Nexytal@2024!</span>
            </p>
          </div>
        </div>

        <p className="text-center text-xs text-muted-foreground mt-6">
          © 2024 NEXYTAL — Tous droits réservés
        </p>
      </div>
    </div>
  );
}
