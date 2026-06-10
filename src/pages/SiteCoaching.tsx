import { useMemo, useState } from 'react';
import { Coach, Creneau, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  blogPostFromApi,
  blogPostToApi,
  bookingFromApi,
  bookingToApi,
  buildBlogArticleFields,
  buildBookingEditFields,
  buildCoachFields,
  coachFromApi,
  coachToApi,
  buildBlogCategoryFields,
  buildCityFields,
  buildSpecialtyFields,
  buildCertificationFields
} from '@/lib/mappers';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { Heart, Eye } from 'lucide-react';
import { toast } from 'sonner';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';

const COLOR = '#DC2626';

export default function SiteCoaching() {
  const [tab, setTab] = useState('coachs');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [viewBooking, setViewBooking] = useState<Creneau | null>(null);

  const { data: coachsData, refetch: refetchC } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/coaches?site=coaching');
  const { data: bookingsData, refetch: refetchCr } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/bookings?site=coaching');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site=coaching');
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: any[] }>('/blog/categories?site=coaching');
  const { data: citiesData, refetch: refetchCities } = useFetch<{ data: any[] }>('/coaching/cities');
  const { data: specialtiesData, refetch: refetchSpec } = useFetch<{ data: any[] }>('/coaching/specialties');
  const { data: certificationsData, refetch: refetchCert } = useFetch<{ data: any[] }>('/coaching/certifications');

  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [blogCategoriesData],
  );

  const cityOptions = useMemo(
    () => (citiesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [citiesData],
  );

  const coachs = useMemo(() => (coachsData?.data ?? []).map(coachFromApi), [coachsData]);
  const reservations = useMemo(() => (bookingsData?.data ?? []).map(bookingFromApi), [bookingsData]);
  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const coachFields = useMemo(() => buildCoachFields(cityOptions), [cityOptions]);
  const bookingFields = useMemo(() => buildBookingEditFields(), []);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);
  const cityFields = useMemo(() => buildCityFields(), []);
  const specialtyFields = useMemo(() => buildSpecialtyFields(), []);
  const certificationFields = useMemo(() => buildCertificationFields(), []);

  const saveCoach = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Coach | undefined;
    try {
      const payload = coachToApi(raw);
      if (item) {
        await api.put(`/coaching/coaches/${item.id}`, payload);
        toast.success('Coach mis à jour.');
      } else {
        await api.post('/coaching/coaches', { ...payload, site: 'coaching' });
        toast.success('Coach créé.');
      }
      refetchC();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveBooking = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Creneau | undefined;
    if (!item) return;
    try {
      const payload = bookingToApi(raw);
      await api.put(`/coaching/bookings/${item.id}`, payload);
      toast.success('Réservation mise à jour.');
      refetchCr();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      const payload = blogPostToApi(raw);
      if (item) {
        await api.put(`/blog/posts/${item.id}`, payload);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts', { ...payload, site: 'coaching' });
        toast.success('Article créé.');
      }
      refetchA();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveBlogCategory = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/blog/categories/${item.id}`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/blog/categories', { ...raw, site: 'coaching' });
        toast.success('Catégorie créée.');
      }
      refetchBc();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveCity = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/coaching/cities/${item.id}`, raw);
        toast.success('Ville mise à jour.');
      } else {
        await api.post('/coaching/cities', raw);
        toast.success('Ville créée.');
      }
      refetchCities();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveSpecialty = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/coaching/specialties/${item.id}`, raw);
        toast.success('Spécialité mise à jour.');
      } else {
        await api.post('/coaching/specialties', raw);
        toast.success('Spécialité créée.');
      }
      refetchSpec();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveCertification = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/coaching/certifications/${item.id}`, raw);
        toast.success('Certification mise à jour.');
      } else {
        await api.post('/coaching/certifications', raw);
        toast.success('Certification créée.');
      }
      refetchCert();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      if (deleteTarget.type === 'coach') {
        await api.delete(`/coaching/coaches/${deleteTarget.id}`);
        refetchC();
      } else if (deleteTarget.type === 'booking') {
        await api.delete(`/coaching/bookings/${deleteTarget.id}`);
        refetchCr();
      } else if (deleteTarget.type === 'article') {
        await api.delete(`/blog/posts/${deleteTarget.id}`);
        refetchA();
      } else if (deleteTarget.type === 'blog_category') {
        await api.delete(`/blog/categories/${deleteTarget.id}`);
        refetchBc();
      } else if (deleteTarget.type === 'city') {
        await api.delete(`/coaching/cities/${deleteTarget.id}`);
        refetchCities();
      } else if (deleteTarget.type === 'specialty') {
        await api.delete(`/coaching/specialties/${deleteTarget.id}`);
        refetchSpec();
      } else if (deleteTarget.type === 'certification') {
        await api.delete(`/coaching/certifications/${deleteTarget.id}`);
        refetchCert();
      }
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Heart className="w-5 h-5" />}
        title="Nexytal Coaching"
        description="Coachs, réservations clients et articles"
        color={COLOR}
        tabs={[
          { key: 'coachs', label: 'Coachs', count: coachs.length },
          { key: 'reservations', label: 'Réservations', count: reservations.length },
          { key: 'articles', label: 'Blog', count: articles.length },
          { key: 'blog_categories', label: 'Catégories Blog', count: blogCategoriesData?.data?.length ?? 0 },
          { key: 'cities', label: 'Villes', count: citiesData?.data?.length ?? 0 },
          { key: 'specialties', label: 'Spécialités', count: specialtiesData?.data?.length ?? 0 },
          { key: 'certifications', label: 'Certifications', count: certificationsData?.data?.length ?? 0 },
        ]}
        activeTab={tab}
        onTabChange={setTab}
      />

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'coachs' && (
          <DataTable<Coach>
            data={coachs}
            accentColor={COLOR}
            addLabel="Nouveau coach"
            onAdd={() => setModal({ type: 'coach' })}
            onEdit={item => setModal({ type: 'coach', item })}
            onDelete={item => setDeleteTarget({ type: 'coach', id: item.id, label: item.nom })}
            searchKeys={['nom', 'titre', 'localisation']}
            columns={[
              { key: 'nom', label: 'Coach', render: c => (
                <div>
                  <p className="font-medium text-foreground">{c.nom}</p>
                  <p className="text-xs text-muted-foreground">{c.titre}</p>
                </div>
              )},
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'localisation', label: 'Ville', hidden: 'sm' },
              { key: 'visible', label: 'Disponible', render: c => (
                <span className={`text-xs px-2 py-0.5 rounded-full ${c.visible ? 'bg-green-500/15 text-green-400' : 'bg-secondary text-muted-foreground'}`}>
                  {c.visible ? 'Oui' : 'Non'}
                </span>
              ), hidden: 'md' },
            ]}
          />
        )}

        {tab === 'reservations' && (
          <DataTable<Creneau>
            data={reservations}
            accentColor={COLOR}
            onEdit={item => setModal({ type: 'booking', item })}
            onDelete={item => setDeleteTarget({ type: 'booking', id: item.id, label: `${item.client_nom} — ${item.date}` })}
            onView={item => setViewBooking(item)}
            searchKeys={['client_nom', 'client_email', 'coach_nom']}
            emptyMessage="Aucune réservation. Les clients réservent via le site public."
            columns={[
              { key: 'date', label: 'Date', render: c => <span className="font-mono text-sm">{c.date} {c.heure}</span> },
              { key: 'client_nom', label: 'Client', render: c => (
                <div>
                  <p className="font-medium text-foreground">{c.client_nom}</p>
                  <p className="text-xs text-muted-foreground">{c.client_email}</p>
                </div>
              )},
              { key: 'coach_nom', label: 'Coach', hidden: 'sm' },
              { key: 'statut', label: 'Statut', render: c => <StatusBadge statut={c.statut} /> },
            ]}
          />
        )}

        {tab === 'articles' && (
          <DataTable<BlogArticle>
            data={articles}
            accentColor={COLOR}
            addLabel="Nouvel article"
            onAdd={() => setModal({ type: 'article' })}
            onEdit={item => setModal({ type: 'article', item })}
            onDelete={item => setDeleteTarget({ type: 'article', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie', 'auteur']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'categorie', label: 'Catégorie', hidden: 'sm' },
              { key: 'auteur', label: 'Auteur', hidden: 'md' },
              { key: 'date', label: 'Date', hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}

        {tab === 'blog_categories' && (
          <DataTable<any>
            data={blogCategoriesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' })}
            onEdit={item => setModal({ type: 'blog_category', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_category', id: item.id, label: item.name })}
            searchKeys={['name', 'slug']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name}</span> },
              { key: 'slug', label: 'Slug' },
              { key: 'color', label: 'Couleur', render: c => (
                c.color ? <div className="flex items-center gap-2"><div className="w-4 h-4 rounded-full" style={{ background: c.color }} />{c.color}</div> : '-'
              ) },
              { key: 'is_active', label: 'Statut', render: c => <StatusBadge statut={c.is_active ? 'active' : 'inactive'} /> },
            ]}
          />
        )}
        {tab === 'cities' && (
          <DataTable<any>
            data={citiesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle ville"
            onAdd={() => setModal({ type: 'city' })}
            onEdit={item => setModal({ type: 'city', item })}
            onDelete={item => setDeleteTarget({ type: 'city', id: item.id, label: item.name })}
            searchKeys={['name', 'slug']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name}</span> },
              { key: 'slug', label: 'Slug' },
            ]}
          />
        )}
        {tab === 'specialties' && (
          <DataTable<any>
            data={specialtiesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle spécialité"
            onAdd={() => setModal({ type: 'specialty' })}
            onEdit={item => setModal({ type: 'specialty', item })}
            onDelete={item => setDeleteTarget({ type: 'specialty', id: item.id, label: item.name })}
            searchKeys={['name', 'slug']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name}</span> },
              { key: 'slug', label: 'Slug' },
              { key: 'icon', label: 'Icône' },
            ]}
          />
        )}
        {tab === 'certifications' && (
          <DataTable<any>
            data={certificationsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle certification"
            onAdd={() => setModal({ type: 'certification' })}
            onEdit={item => setModal({ type: 'certification', item })}
            onDelete={item => setDeleteTarget({ type: 'certification', id: item.id, label: item.code })}
            searchKeys={['code', 'organization']}
            columns={[
              { key: 'code', label: 'Code', render: c => <span className="font-medium text-foreground">{c.code}</span> },
              { key: 'organization', label: 'Organisme' },
              { key: 'level', label: 'Niveau' },
            ]}
          />
        )}
      </div>

      <FormModal open={modal?.type === 'coach'} onClose={() => setModal(null)} onSave={saveCoach}
        title={modal?.item ? 'Modifier le coach' : 'Nouveau coach'}
        fields={coachFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'booking'} onClose={() => setModal(null)} onSave={saveBooking}
        title="Modifier la réservation"
        fields={bookingFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={articleFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={saveBlogCategory} title={modal?.item ? 'Modifier' : 'Nouvelle catégorie'} fields={blogCategoryFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'city'} onClose={() => setModal(null)} onSave={saveCity} title={modal?.item ? 'Modifier' : 'Nouvelle ville'} fields={cityFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'specialty'} onClose={() => setModal(null)} onSave={saveSpecialty} title={modal?.item ? 'Modifier' : 'Nouvelle spécialité'} fields={specialtyFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'certification'} onClose={() => setModal(null)} onSave={saveCertification} title={modal?.item ? 'Modifier' : 'Nouvelle certification'} fields={certificationFields} initialData={modal?.item as any} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />

      <Dialog open={!!viewBooking} onOpenChange={v => !v && setViewBooking(null)}>
        <DialogContent className="max-w-sm bg-card border-border text-foreground">
          <DialogHeader>
            <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>Détail réservation</DialogTitle>
          </DialogHeader>
          {viewBooking && (
            <div className="space-y-3 text-sm">
              <p><span className="text-muted-foreground">Date :</span> {viewBooking.date} {viewBooking.heure}</p>
              <p><span className="text-muted-foreground">Coach :</span> {viewBooking.coach_nom}</p>
              <p><span className="text-muted-foreground">Client :</span> {viewBooking.client_nom}</p>
              <p><span className="text-muted-foreground">Email :</span> {viewBooking.client_email}</p>
              <p><span className="text-muted-foreground">Statut :</span> <StatusBadge statut={viewBooking.statut} /></p>
              {viewBooking.notes && <p><span className="text-muted-foreground">Notes :</span> {viewBooking.notes}</p>}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
