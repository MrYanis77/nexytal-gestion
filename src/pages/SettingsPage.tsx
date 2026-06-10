import { useState } from 'react';
import { useApp } from '@/contexts/AppContext';
import { Settings } from 'lucide-react';

export default function SettingsPage() {
  const { currentUser } = useApp();
    const a = document.createElement('a');
  return (
    <div className="p-6 space-y-6 fade-up">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#6B728020' }}>
          <Settings className="w-5 h-5 text-muted-foreground" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Paramètres</h1>
          <p className="text-xs text-muted-foreground">Gestion des données et configuration de l'application</p>
        </div>
      </div>

      {/* Profile */}
      <div className="rounded-xl border border-border p-5 bg-card space-y-3">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Mon profil</h2>
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div><p className="text-xs text-muted-foreground mb-0.5">Identifiant</p><p className="font-medium text-foreground">{currentUser?.username}</p></div>
          <div><p className="text-xs text-muted-foreground mb-0.5">Email</p><p className="font-medium text-foreground">{currentUser?.email}</p></div>
          <div><p className="text-xs text-muted-foreground mb-0.5">Rôle</p><p className="font-medium text-foreground capitalize">{currentUser?.role}</p></div>
          <div><p className="text-xs text-muted-foreground mb-0.5">Compte créé le</p><p className="font-mono text-foreground">{currentUser?.createdAt}</p></div>
        </div>
      </div>

      {/* About */}
      <div className="rounded-xl border border-border p-5 bg-card space-y-2">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>À propos</h2>
        <div className="text-xs text-muted-foreground space-y-1">
          <p><strong className="text-foreground">NEXYTAL Gestion</strong> — Application de gestion connectée à l'API PHP</p>
          <p>Version 2.0.0 — React 19 + TypeScript + Tailwind CSS 4 + Axios</p>
          <p>Les données sont désormais gérées par le backend via l'API. (Fin du stockage local).</p>
        </div>
      </div>
    </div>
  );
}
