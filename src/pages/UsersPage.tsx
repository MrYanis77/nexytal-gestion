import { useMemo, useState } from 'react';
import { useApp, User, Role, SiteId } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { userFromApi, userToApi } from '@/lib/mappers';
import { DataTable } from '@/components/DataTable';
import { ConfirmDelete } from '@/components/FormModal';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { Checkbox } from '@/components/ui/checkbox';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Users, Shield, UserCheck, UserX } from 'lucide-react';
import { toast } from 'sonner';

const SITES: { id: SiteId; label: string; color: string }[] = [
  { id: 'formation', label: 'Alt Formation', color: '#7C3AED' },
  { id: 'medical', label: 'Nexytal Medical', color: '#059669' },
  { id: 'recrutement', label: 'Nexytal Recrutement', color: '#2563EB' },
  { id: 'carriere', label: 'Nexytal Carrière', color: '#D97706' },
  { id: 'coaching', label: 'Nexytal Coaching', color: '#DC2626' },
  { id: 'trainer', label: 'Nexytal Trainer', color: '#0891B2' },
];

const ROLE_COLORS: Partial<Record<Role, string>> = {
  superadmin: 'bg-purple-500/20 text-purple-300',
  admin: 'bg-blue-500/20 text-blue-300',
  editor: 'bg-green-500/20 text-green-300',
  moderator: 'bg-amber-500/20 text-amber-300',
  recruiter: 'bg-cyan-500/20 text-cyan-300',
};

const ROLE_LABELS: Partial<Record<Role, string>> = {
  superadmin: 'Super Admin',
  admin: 'Administrateur',
  editor: 'Éditeur',
  moderator: 'Modérateur',
  recruiter: 'Recruteur',
};

interface UserForm {
  first_name: string;
  last_name: string;
  email: string;
  role: Role;
  sites: SiteId[];
  active: boolean;
  password: string;
}

const DEFAULT_FORM: UserForm = {
  first_name: '',
  last_name: '',
  email: '',
  role: 'editor',
  sites: [],
  active: true,
  password: '',
};

export default function UsersPage() {
  const { currentUser } = useApp();
  const [modal, setModal] = useState<{ item?: User } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; label: string } | null>(null);
  const [form, setForm] = useState<UserForm>(DEFAULT_FORM);

  const { data: usersData, refetch } = useFetch<{ data: Record<string, unknown>[] }>('/users');
  const users = useMemo(() => (usersData?.data ?? []).map(userFromApi), [usersData]);

  const openAdd = () => { setForm(DEFAULT_FORM); setModal({}); };
  const openEdit = (u: User) => {
    setForm({
      first_name: u.first_name ?? u.username.split(' ')[0] ?? '',
      last_name: u.last_name ?? u.username.split(' ').slice(1).join(' ') ?? '',
      email: u.email,
      role: u.role === 'user' ? 'editor' : u.role,
      sites: u.sites,
      active: u.active,
      password: '',
    });
    setModal({ item: u });
  };

  const handleSave = async () => {
    if (!form.email || !form.first_name || !form.last_name) {
      toast.error('Prénom, nom et email requis.');
      return;
    }

    try {
      const payload = userToApi(form);
      if (modal?.item) {
        await api.put(`/users/${modal.item.id}`, payload);
        toast.success('Utilisateur mis à jour.');
      } else {
        if (!form.password) {
          toast.error('Mot de passe requis pour un nouvel utilisateur.');
          return;
        }
        await api.post('/users', payload);
        toast.success('Utilisateur créé.');
      }
      refetch();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      await api.delete(`/users/${deleteTarget.id}`);
      toast.success('Utilisateur désactivé.');
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  const toggleSite = (site: SiteId) => {
    setForm(f => ({
      ...f,
      sites: f.sites.includes(site) ? f.sites.filter(s => s !== site) : [...f.sites, site],
    }));
  };

  const stats = [
    { label: 'Total', value: users.length, icon: Users, color: '#2563EB' },
    { label: 'Super Admin', value: users.filter(u => u.role === 'superadmin').length, icon: Shield, color: '#7C3AED' },
    { label: 'Actifs', value: users.filter(u => u.active).length, icon: UserCheck, color: '#059669' },
    { label: 'Inactifs', value: users.filter(u => !u.active).length, icon: UserX, color: '#DC2626' },
  ];

  return (
    <div className="p-6 space-y-6 fade-up">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#2563EB20' }}>
          <Users className="w-5 h-5 text-blue-400" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Gestion des utilisateurs</h1>
          <p className="text-xs text-muted-foreground">Comptes admin alignés sur core_admin_users</p>
        </div>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        {stats.map(s => (
          <div key={s.label} className="rounded-xl border border-border p-4 bg-card">
            <div className="flex items-center gap-2 mb-2">
              <div className="w-7 h-7 rounded-lg flex items-center justify-center" style={{ background: s.color + '20' }}>
                <s.icon className="w-3.5 h-3.5" style={{ color: s.color }} />
              </div>
              <span className="text-xs text-muted-foreground">{s.label}</span>
            </div>
            <p className="text-2xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>{s.value}</p>
          </div>
        ))}
      </div>

      <DataTable<User>
        data={users}
        accentColor="#2563EB"
        addLabel="Nouvel utilisateur"
        onAdd={openAdd}
        onEdit={openEdit}
        onDelete={u => u.id !== currentUser?.id ? setDeleteTarget({ id: u.id, label: u.username }) : toast.error('Vous ne pouvez pas supprimer votre propre compte.')}
        searchKeys={['username', 'email', 'role']}
        columns={[
          { key: 'username', label: 'Utilisateur', render: u => (
            <div className="flex items-center gap-2.5">
              <Avatar className="w-7 h-7 flex-shrink-0">
                <AvatarFallback className="text-xs font-bold" style={{ background: '#2563EB30', color: '#60a5fa' }}>
                  {(u.first_name?.[0] ?? u.username[0] ?? '?').toUpperCase()}
                </AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium text-foreground text-sm">{u.username}</p>
                <p className="text-xs text-muted-foreground">{u.email}</p>
              </div>
            </div>
          )},
          { key: 'role', label: 'Rôle', render: u => (
            <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${ROLE_COLORS[u.role] ?? 'bg-secondary text-muted-foreground'}`}>
              {ROLE_LABELS[u.role] ?? u.role}
            </span>
          )},
          { key: 'sites', label: 'Sites', render: u => (
            <div className="flex flex-wrap gap-1">
              {u.role === 'superadmin'
                ? <span className="text-xs text-purple-400">Tous les sites</span>
                : u.sites.slice(0, 2).map(s => {
                    const site = SITES.find(x => x.id === s);
                    return site ? (
                      <span key={s} className="text-xs px-1.5 py-0.5 rounded" style={{ background: site.color + '20', color: site.color }}>
                        {site.label.replace('Nexytal ', '')}
                      </span>
                    ) : null;
                  })
              }
              {u.role !== 'superadmin' && u.sites.length > 2 && (
                <span className="text-xs text-muted-foreground">+{u.sites.length - 2}</span>
              )}
            </div>
          ), hidden: 'sm' },
          { key: 'createdAt', label: 'Créé le', render: u => <span className="text-xs text-muted-foreground font-mono">{u.createdAt}</span>, hidden: 'lg' },
          { key: 'active', label: 'Statut', render: u => (
            <span className={`text-xs px-2 py-0.5 rounded-full ${u.active ? 'bg-green-500/15 text-green-400' : 'bg-red-500/15 text-red-400'}`}>
              {u.active ? 'Actif' : 'Inactif'}
            </span>
          )},
        ]}
      />

      <Dialog open={modal !== null} onOpenChange={v => !v && setModal(null)}>
        <DialogContent className="max-w-lg bg-card border-border text-foreground max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>
              {modal?.item ? 'Modifier l\'utilisateur' : 'Nouvel utilisateur'}
            </DialogTitle>
          </DialogHeader>

          <div className="space-y-4 py-2">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label className="text-sm text-foreground/80 mb-1.5 block">Prénom *</Label>
                <Input value={form.first_name} onChange={e => setForm(f => ({ ...f, first_name: e.target.value }))}
                  className="bg-secondary border-border h-9" />
              </div>
              <div>
                <Label className="text-sm text-foreground/80 mb-1.5 block">Nom *</Label>
                <Input value={form.last_name} onChange={e => setForm(f => ({ ...f, last_name: e.target.value }))}
                  className="bg-secondary border-border h-9" />
              </div>
            </div>

            <div>
              <Label className="text-sm text-foreground/80 mb-1.5 block">Email *</Label>
              <Input type="email" value={form.email} onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
                placeholder="email@nexytal.fr" className="bg-secondary border-border h-9" />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label className="text-sm text-foreground/80 mb-1.5 block">Rôle</Label>
                <Select value={form.role} onValueChange={v => setForm(f => ({ ...f, role: v as Role }))}>
                  <SelectTrigger className="bg-secondary border-border h-9">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent className="bg-card border-border text-foreground">
                    <SelectItem value="superadmin">Super Admin</SelectItem>
                    <SelectItem value="admin">Administrateur</SelectItem>
                    <SelectItem value="editor">Éditeur</SelectItem>
                    <SelectItem value="moderator">Modérateur</SelectItem>
                    <SelectItem value="recruiter">Recruteur</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label className="text-sm text-foreground/80 mb-1.5 block">
                  {modal?.item ? 'Nouveau mot de passe' : 'Mot de passe *'}
                </Label>
                <Input type="password" value={form.password} onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
                  placeholder={modal?.item ? 'Laisser vide = inchangé' : '••••••••'}
                  className="bg-secondary border-border h-9" />
              </div>
            </div>

            {form.role !== 'superadmin' && (
              <div>
                <Label className="text-sm text-foreground/80 mb-2 block">Sites accessibles</Label>
                <div className="grid grid-cols-2 gap-2">
                  {SITES.map(site => (
                    <label key={site.id} className="flex items-center gap-2.5 p-2.5 rounded-lg border border-border cursor-pointer hover:bg-secondary/50 transition-colors">
                      <Checkbox
                        checked={form.sites.includes(site.id)}
                        onCheckedChange={() => toggleSite(site.id)}
                        className="border-border"
                      />
                      <span className="text-sm text-foreground/80">{site.label}</span>
                    </label>
                  ))}
                </div>
              </div>
            )}

            <div className="flex items-center gap-3 p-3 rounded-lg border border-border bg-secondary/30">
              <Switch checked={form.active} onCheckedChange={v => setForm(f => ({ ...f, active: v }))} />
              <div>
                <p className="text-sm font-medium text-foreground">Compte actif</p>
                <p className="text-xs text-muted-foreground">Un compte inactif ne peut pas se connecter.</p>
              </div>
            </div>
          </div>

          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setModal(null)} className="border-border">Annuler</Button>
            <Button onClick={handleSave} style={{ background: '#2563EB' }}>Enregistrer</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
