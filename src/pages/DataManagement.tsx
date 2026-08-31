import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  buildNewsletterListFields,
  buildNewsletterSubscriberFields,
  buildNewsletterCampaignFields,
  buildNewsletterSubscriptionFields,
  buildSeoFields,
  buildEmailLogFields,
  subscriberToApi,
} from '@/lib/mappers';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { Database } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#6366f1';

const SITE_OPTIONS = [
  { value: '1', label: 'Alt Formation' },
  { value: '2', label: 'Recrutement' },
  { value: '3', label: 'Médical' },
  { value: '4', label: 'Carrière' },
  { value: '5', label: 'Trainer' },
  { value: '6', label: 'Coaching' },
];

export default function DataManagement() {
  const [siteId, setSiteId] = useState('1');
  const [modal, setModal] = useState<{ type: string; item?: Record<string, unknown> } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string; extra?: Record<string, string> } | null>(null);

  const siteQs = `?site_id=${siteId}`;

  const { data: newsletterData, refetch: refetchNews } = useFetch<{ data: Record<string, unknown>[] }>(`/marketing/newsletter${siteQs}`);
  const { data: listsData, refetch: refetchLists } = useFetch<{ data: Record<string, unknown>[] }>(`/marketing/lists${siteQs}`);
  const { data: campaignsData, refetch: refetchCamp } = useFetch<{ data: Record<string, unknown>[] }>(`/marketing/campaigns${siteQs}`);
  const { data: subscriptionsData, refetch: refetchSubs } = useFetch<{ data: Record<string, unknown>[] }>(`/marketing/subscriptions${siteQs}`);
  const { data: eventsData } = useFetch<{ data: Record<string, unknown>[] }>(`/marketing/events${siteQs}`);
  const { data: emailsData, refetch: refetchEmails } = useFetch<{ data: Record<string, unknown>[] }>(`/marketing/emails${siteQs}`);
  const { data: consentsData } = useFetch<{ data: Record<string, unknown>[] }>(`/gdpr/consents${siteQs}`);
  const { data: deletionsData, refetch: refetchDel } = useFetch<{ data: Record<string, unknown>[] }>(`/gdpr/deletion-requests${siteQs}`);
  const { data: seoData, refetch: refetchSeo } = useFetch<{ data: Record<string, unknown>[] }>(`/seo${siteQs}`);

  const listOptions = useMemo(
    () => (listsData?.data ?? []).map(l => ({ value: String(l.id), label: String(l.name) })),
    [listsData],
  );
  const subscriberOptions = useMemo(
    () => (newsletterData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.email) })),
    [newsletterData],
  );

  const listFields = useMemo(() => buildNewsletterListFields(), []);
  const subscriberFields = useMemo(() => buildNewsletterSubscriberFields(), []);
  const tabGroups = useMemo<TabGroup[]>(() => [
    {
      key: 'newsletter',
      label: 'Newsletter',
      tabs: [
        { key: 'newsletter', label: 'Abonnés', count: newsletterData?.data?.length ?? 0 },
        { key: 'lists', label: 'Listes', count: listsData?.data?.length ?? 0 },
        { key: 'campaigns', label: 'Campagnes', count: campaignsData?.data?.length ?? 0 },
        { key: 'subscriptions', label: 'Inscriptions', count: subscriptionsData?.data?.length ?? 0 },
      ],
    },
    {
      key: 'suivi',
      label: 'Suivi',
      tabs: [
        { key: 'events', label: 'Historique', count: eventsData?.data?.length ?? 0 },
        { key: 'emails', label: 'Emails envoyés', count: emailsData?.data?.length ?? 0 },
        { key: 'seo', label: 'Référencement', count: seoData?.data?.length ?? 0 },
      ],
    },
    {
      key: 'rgpd',
      label: 'Confidentialité',
      tabs: [
        { key: 'gdpr_consents', label: 'Consentements', count: consentsData?.data?.length ?? 0 },
        { key: 'gdpr_deletion_requests', label: 'Demandes de suppression', count: deletionsData?.data?.length ?? 0 },
      ],
    },
  ], [newsletterData, listsData, campaignsData, subscriptionsData, eventsData, emailsData, seoData, consentsData, deletionsData]);

  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(tabGroups, 'newsletter', 'newsletter');
  const campaignFields = useMemo(() => buildNewsletterCampaignFields(listOptions), [listOptions]);
  const subscriptionFields = useMemo(() => buildNewsletterSubscriptionFields(subscriberOptions, listOptions), [subscriberOptions, listOptions]);
  const seoFields = useMemo(() => buildSeoFields(), []);
  const emailLogFields = useMemo(() => buildEmailLogFields(), []);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      const map: Record<string, () => Promise<void>> = {
        newsletter: async () => { await api.delete(`/marketing/newsletter/${deleteTarget.id}${siteQs}`); refetchNews(); },
        list: async () => { await api.delete(`/marketing/lists/${deleteTarget.id}${siteQs}`); refetchLists(); },
        campaign: async () => { await api.delete(`/marketing/campaigns/${deleteTarget.id}${siteQs}`); refetchCamp(); },
        subscription: async () => {
          const q = deleteTarget.extra ?? {};
          await api.delete(`/marketing/subscriptions?subscriber_id=${q.subscriber_id}&list_id=${q.list_id}${siteQs.replace('?', '&')}`);
          refetchSubs();
        },
      };
      await map[deleteTarget.type]?.();
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Database className="w-5 h-5" />}
        title="Gestion des données"
        description="Newsletter, suivi et confidentialité"
        color={COLOR}
        tabGroups={tabGroups}
        activeGroup={activeGroup}
        onGroupChange={onGroupChange}
        activeTab={tab}
        onTabChange={setTab}
      />

      <div className="px-6 pt-4 flex items-center gap-3">
        <label className="text-sm text-muted-foreground">Site :</label>
        <select value={siteId} onChange={e => setSiteId(e.target.value)}
          className="bg-secondary border border-border rounded-md px-3 py-1.5 text-sm text-foreground">
          {SITE_OPTIONS.map(s => <option key={s.value} value={s.value}>{s.label}</option>)}
        </select>
      </div>

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'newsletter' && (
          <DataTable<Record<string, unknown>>
            data={newsletterData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvel abonné"
            onAdd={() => setModal({ type: 'subscriber' })}
            onDelete={item => setDeleteTarget({ type: 'newsletter', id: String(item.id), label: String(item.email) })}
            searchKeys={['email', 'first_name', 'last_name']}
            columns={[
              { key: 'email', label: 'Email', render: m => <span className="font-medium text-foreground">{String(m.email)}</span> },
              { key: 'status', label: 'Statut', render: m => <StatusBadge statut={String(m.status)} /> },
              { key: 'created_at', label: 'Inscrit le', render: m => String(m.created_at ?? '').slice(0, 10) },
            ]}
          />
        )}

        {tab === 'lists' && (
          <DataTable<Record<string, unknown>>
            data={listsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle liste"
            onAdd={() => setModal({ type: 'list' })}
            onEdit={item => setModal({ type: 'list', item })}
            onDelete={item => setDeleteTarget({ type: 'list', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Nom', render: l => <span className="font-medium text-foreground">{String(l.name)}</span> },
              { key: 'is_active', label: 'Active', render: l => l.is_active ? 'Oui' : 'Non' },
            ]}
          />
        )}

        {tab === 'campaigns' && (
          <DataTable<Record<string, unknown>>
            data={campaignsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle campagne"
            onAdd={() => setModal({ type: 'campaign' })}
            onEdit={item => setModal({ type: 'campaign', item })}
            onDelete={item => setDeleteTarget({ type: 'campaign', id: String(item.id), label: String(item.subject) })}
            searchKeys={['subject', 'status']}
            columns={[
              { key: 'subject', label: 'Objet', render: c => <span className="font-medium text-foreground">{String(c.subject)}</span> },
              { key: 'status', label: 'Statut', render: c => <StatusBadge statut={String(c.status)} /> },
              { key: 'recipients_count', label: 'Destinataires', hidden: 'lg' },
            ]}
          />
        )}

        {tab === 'subscriptions' && (
          <DataTable<any>
            data={subscriptionsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvel abonnement"
            onAdd={() => setModal({ type: 'subscription' })}
            onDelete={item => setDeleteTarget({
              type: 'subscription', id: `${item.subscriber_id}-${item.list_id}`, label: String(item.email),
              extra: { subscriber_id: String(item.subscriber_id), list_id: String(item.list_id) },
            })}
            searchKeys={['email', 'list_name']}
            columns={[
              { key: 'email', label: 'Abonné', render: s => String(s.email) },
              { key: 'list_name', label: 'Liste' },
              { key: 'subscribed_at', label: 'Depuis', render: s => String(s.subscribed_at ?? '').slice(0, 10) },
            ]}
          />
        )}

        {tab === 'events' && (
          <DataTable<any>
            data={eventsData?.data ?? []}
            accentColor={COLOR}
            searchKeys={['event_type', 'subscriber_email', 'campaign_subject']}
            columns={[
              { key: 'event_type', label: 'Type' },
              { key: 'subscriber_email', label: 'Abonné', hidden: 'md' },
              { key: 'campaign_subject', label: 'Campagne', hidden: 'lg' },
              { key: 'created_at', label: 'Date', render: e => String(e.created_at ?? '').slice(0, 10) },
            ]}
          />
        )}

        {tab === 'emails' && (
          <DataTable<any>
            data={emailsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau log"
            onAdd={() => setModal({ type: 'email_log' })}
            searchKeys={['recipient_email', 'subject', 'status']}
            columns={[
              { key: 'recipient_email', label: 'Destinataire', render: e => String(e.recipient_email) },
              { key: 'subject', label: 'Objet', hidden: 'md' },
              { key: 'status', label: 'Statut', render: e => <StatusBadge statut={String(e.status)} /> },
            ]}
          />
        )}

        {tab === 'seo' && (
          <DataTable<any>
            data={seoData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle entrée SEO"
            onAdd={() => setModal({ type: 'seo' })}
            onEdit={item => setModal({ type: 'seo', item })}
            searchKeys={['entity_type', 'entity_id', 'meta_title']}
            columns={[
              { key: 'entity', label: 'Entité', render: s => `${s.entity_type} #${s.entity_id}` },
              { key: 'meta_title', label: 'Titre', hidden: 'md' },
            ]}
          />
        )}

        {tab === 'gdpr_consents' && (
          <DataTable<any>
            data={consentsData?.data ?? []}
            accentColor={COLOR}
            searchKeys={['user_email', 'consent_type']}
            columns={[
              { key: 'user_email', label: 'Email', render: m => m.user_email ? String(m.user_email) : '—' },
              { key: 'consent_type', label: 'Type' },
              { key: 'granted', label: 'Accordé', render: m => m.granted ? 'Oui' : 'Non' },
              { key: 'granted_at', label: 'Date', render: m => String(m.granted_at ?? '').slice(0, 10) },
            ]}
          />
        )}

        {tab === 'gdpr_deletion_requests' && (
          <DataTable<any>
            data={deletionsData?.data ?? []}
            accentColor={COLOR}
            onEdit={item => setModal({ type: 'deletion', item })}
            searchKeys={['user_email']}
            columns={[
              { key: 'user_email', label: 'Email', render: m => <span className="font-medium text-foreground">{String(m.user_email)}</span> },
              { key: 'status', label: 'Statut', render: m => <StatusBadge statut={String(m.status)} /> },
            ]}
          />
        )}
      </div>

      <FormModal open={modal?.type === 'subscriber'} onClose={() => setModal(null)} onSave={async (raw) => {
        await api.post(`/marketing/newsletter${siteQs}`, subscriberToApi(raw));
        toast.success('Abonné créé'); refetchNews(); setModal(null);
      }} title="Nouvel abonné" fields={subscriberFields} initialData={modal?.item} accentColor={COLOR} />
      <FormModal open={modal?.type === 'list'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item;
        if (item) await api.put(`/marketing/lists/${item.id}${siteQs}`, raw);
        else await api.post(`/marketing/lists${siteQs}`, raw);
        toast.success('Liste enregistrée'); refetchLists(); setModal(null);
      }} title="Liste newsletter" fields={listFields} initialData={modal?.item} accentColor={COLOR} />
      <FormModal open={modal?.type === 'campaign'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item;
        const payload = { ...raw, list_id: raw.list_id ? Number(raw.list_id) : null };
        if (item) await api.put(`/marketing/campaigns/${item.id}${siteQs}`, payload);
        else await api.post(`/marketing/campaigns${siteQs}`, payload);
        toast.success('Campagne enregistrée'); refetchCamp(); setModal(null);
      }} title="Campagne" fields={campaignFields} initialData={modal?.item} accentColor={COLOR} wide />
      <FormModal open={modal?.type === 'subscription'} onClose={() => setModal(null)} onSave={async (raw) => {
        await api.post(`/marketing/subscriptions${siteQs}`, { subscriber_id: Number(raw.subscriber_id), list_id: Number(raw.list_id) });
        toast.success('Abonnement créé'); refetchSubs(); setModal(null);
      }} title="Abonnement liste" fields={subscriptionFields} initialData={modal?.item} accentColor={COLOR} />
      <FormModal open={modal?.type === 'seo'} onClose={() => setModal(null)} onSave={async (raw) => {
        await api.post(`/seo${siteQs}`, { ...raw, entity_id: Number(raw.entity_id) });
        toast.success('SEO enregistré'); refetchSeo(); setModal(null);
      }} title="Métadonnées SEO" fields={seoFields} initialData={modal?.item} accentColor={COLOR} wide />
      <FormModal open={modal?.type === 'email_log'} onClose={() => setModal(null)} onSave={async (raw) => {
        await api.post(`/marketing/emails${siteQs}`, raw);
        toast.success('Log créé'); refetchEmails(); setModal(null);
      }} title="Log email" fields={emailLogFields} initialData={modal?.item} accentColor={COLOR} />
      <FormModal open={modal?.type === 'deletion'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item;
        if (!item) return;
        await api.put(`/gdpr/deletion-requests/${item.id}${siteQs}`, raw);
        toast.success('Demande mise à jour'); refetchDel(); setModal(null);
      }} title="Statut suppression GDPR" fields={[
        { key: 'status', label: 'Statut', type: 'select', options: [
          { value: 'pending', label: 'En attente' }, { value: 'processing', label: 'En cours' },
          { value: 'completed', label: 'Terminé' }, { value: 'rejected', label: 'Rejeté' },
        ]},
      ]} initialData={modal?.item} accentColor={COLOR} />

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
