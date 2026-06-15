import { useCallback, useMemo, useRef, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  buildMediaQuery,
  deleteMedia,
  FILE_TYPE_LABELS,
  mediaSearchHaystack,
  SITE_LABELS,
  updateMediaAltText,
  type DiskSpaceStats,
  type MediaItem,
} from '@/lib/media';
import {
  uploadMediaFile,
  resolveMediaUrl,
  formatFileSize,
  FILE_ACCEPT,
  type UploadFileKind,
} from '@/lib/upload';
import { SiteHeader } from '@/components/SiteHeader';
import { ConfirmDelete } from '@/components/FormModal';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import {
  Copy,
  Film,
  FileText,
  HardDrive,
  ImageIcon,
  Loader2,
  Search,
  Trash2,
  Upload,
  Images,
  ExternalLink,
  Plus,
} from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#8B5CF6';

const SITE_OPTIONS = [
  { value: 'all', label: 'Tous les sites' },
  { value: 'global', label: 'Global (partagé)' },
  ...Object.entries(SITE_LABELS).map(([value, label]) => ({ value, label })),
];

type TypeTab = 'all' | 'image' | 'video' | 'document';

const DISK_LOW_BYTES = 256 * 1024 * 1024;

function DiskSpaceIndicator({ stats, loading }: { stats: DiskSpaceStats | null; loading: boolean }) {
  if (loading) {
    return (
      <div className="flex items-center gap-2 text-xs text-muted-foreground shrink-0">
        <Loader2 className="h-3.5 w-3.5 animate-spin" />
        Espace disque…
      </div>
    );
  }

  if (!stats || stats.total_bytes == null || stats.free_bytes == null) {
    return (
      <div className="flex items-center gap-1.5 text-xs text-muted-foreground shrink-0" title="Quota non disponible sur cet hébergement">
        <HardDrive className="h-3.5 w-3.5" />
        Espace disque : N/D
      </div>
    );
  }

  const used = stats.used_bytes ?? Math.max(0, stats.total_bytes - stats.free_bytes);
  const pct = stats.total_bytes > 0 ? Math.min(100, (used / stats.total_bytes) * 100) : 0;
  const isLow = stats.free_bytes < DISK_LOW_BYTES;
  const barColor = isLow ? '#EF4444' : pct > 85 ? '#F59E0B' : COLOR;

  return (
    <div
      className="flex items-center gap-2 min-w-[200px] max-w-[280px] shrink-0"
      title={`${stats.free_mb ?? '?'} Mo libres sur ${stats.total_mb ?? '?'} Mo`}
    >
      <HardDrive className={`h-3.5 w-3.5 shrink-0 ${isLow ? 'text-red-500' : 'text-muted-foreground'}`} />
      <div className="flex-1 space-y-0.5">
        <div className="flex justify-between text-[10px] text-muted-foreground leading-none">
          <span>Disque</span>
          <span className={isLow ? 'text-red-500 font-medium' : ''}>
            {stats.free_mb} Mo libres
          </span>
        </div>
        <div className="h-1.5 rounded-full bg-secondary overflow-hidden">
          <div
            className="h-full rounded-full transition-all"
            style={{ width: `${pct}%`, background: barColor }}
          />
        </div>
      </div>
    </div>
  );
}

function MediaPreview({ item }: { item: MediaItem }) {
  const url = resolveMediaUrl(item.url);
  if (item.file_type === 'video') {
    return (
      <video src={url} controls className="max-h-64 w-full rounded-lg border border-border bg-black/20" />
    );
  }
  if (item.file_type === 'document') {
    return (
      <div className="flex flex-col items-center gap-3 py-8 rounded-lg border border-border bg-secondary/40">
        <FileText className="h-16 w-16 text-muted-foreground" />
        <a href={url} target="_blank" rel="noreferrer" className="text-sm text-primary hover:underline flex items-center gap-1">
          Ouvrir le PDF <ExternalLink className="h-3.5 w-3.5" />
        </a>
      </div>
    );
  }
  return (
    <img
      src={url}
      alt={item.alt_text ?? ''}
      className="max-h-64 w-full object-contain rounded-lg border border-border bg-secondary/30"
    />
  );
}

function GridThumb({ item }: { item: MediaItem }) {
  const url = resolveMediaUrl(item.url);
  if (item.file_type === 'video') {
    return (
      <div className="flex h-full w-full items-center justify-center bg-black/40">
        <Film className="h-10 w-10 text-white/70" />
      </div>
    );
  }
  if (item.file_type === 'document') {
    return (
      <div className="flex h-full w-full items-center justify-center bg-secondary">
        <FileText className="h-10 w-10 text-muted-foreground" />
      </div>
    );
  }
  return (
    <img
      src={url}
      alt={item.alt_text ?? item.file_name}
      className="h-full w-full object-cover"
      loading="lazy"
    />
  );
}

export default function MediaLibraryPage() {
  const [siteFilter, setSiteFilter] = useState('all');
  const [typeTab, setTypeTab] = useState<TypeTab>('all');
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState<MediaItem | null>(null);
  const [altDraft, setAltDraft] = useState('');
  const [savingAlt, setSavingAlt] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<MediaItem | null>(null);
  const [uploading, setUploading] = useState(false);
  const [uploadType, setUploadType] = useState<UploadFileKind>('image');
  const [uploadContext, setUploadContext] = useState('global');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const querySite = siteFilter === 'global' ? undefined : siteFilter;
  const mediaPath = `/media${buildMediaQuery({ siteId: querySite, limit: 100 })}`;

  const { data, loading, refetch } = useFetch<{ data: MediaItem[] }>(mediaPath);
  const { data: diskData, loading: diskLoading, refetch: refetchDisk } = useFetch<{ data: DiskSpaceStats }>('/media/disk-space');
  const diskStats = diskData?.data ?? null;

  const siteFiltered = useMemo(() => {
    let list = data?.data ?? [];
    if (siteFilter === 'global') {
      list = list.filter(i => i.site_id === null);
    }
    return list;
  }, [data, siteFilter]);

  const typeCounts = useMemo(() => ({
    all: siteFiltered.length,
    image: siteFiltered.filter(i => i.file_type === 'image').length,
    video: siteFiltered.filter(i => i.file_type === 'video').length,
    document: siteFiltered.filter(i => i.file_type === 'document').length,
  }), [siteFiltered]);

  const headerTabs = useMemo(
    () => [
      { key: 'all', label: 'Tous', count: typeCounts.all },
      { key: 'image', label: 'Images', count: typeCounts.image },
      { key: 'video', label: 'Vidéos', count: typeCounts.video },
      { key: 'document', label: 'Documents', count: typeCounts.document },
    ],
    [typeCounts],
  );

  const items = useMemo(() => {
    let list = siteFiltered;
    if (typeTab !== 'all') {
      list = list.filter(i => i.file_type === typeTab);
    }
    const q = search.trim().toLowerCase();
    if (!q) return list;
    return list.filter(i => mediaSearchHaystack(i).includes(q));
  }, [siteFiltered, typeTab, search]);

  const openDetail = (item: MediaItem) => {
    setSelected(item);
    setAltDraft(item.alt_text ?? '');
  };

  const copyUrl = useCallback(async (url: string) => {
    try {
      await navigator.clipboard.writeText(url);
      toast.success('URL copiée');
    } catch {
      toast.error('Impossible de copier l\'URL');
    }
  }, []);

  const handleUpload = async (files: FileList | null) => {
    if (!files?.length) return;
    setUploading(true);
    let ok = 0;
    try {
      for (const file of Array.from(files)) {
        const siteId = siteFilter !== 'all' && siteFilter !== 'global' ? siteFilter : undefined;
        await uploadMediaFile(file, { type: uploadType, context: uploadContext, siteId });
        ok++;
      }
      toast.success(ok > 1 ? `${ok} fichiers uploadés` : 'Fichier uploadé');
      refetch();
      refetchDisk();
    } catch (err) {
      toast.error(getApiErrorMessage(err));
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const saveAlt = async () => {
    if (!selected) return;
    setSavingAlt(true);
    try {
      const updated = await updateMediaAltText(selected.id, altDraft.trim() || null);
      toast.success('Texte alternatif enregistré');
      setSelected(updated);
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err));
    } finally {
      setSavingAlt(false);
    }
  };

  const confirmDelete = async () => {
    if (!deleteTarget) return;
    try {
      await deleteMedia(deleteTarget.id);
      toast.success('Média supprimé');
      if (selected?.id === deleteTarget.id) setSelected(null);
      setDeleteTarget(null);
      refetch();
      refetchDisk();
    } catch (err) {
      toast.error(getApiErrorMessage(err));
    }
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Images className="w-5 h-5" />}
        title="Médiathèque"
        description="Images, vidéos et documents uploadés pour tous les sites Nexytal"
        color={COLOR}
        tabs={headerTabs}
        activeTab={typeTab}
        onTabChange={key => setTypeTab(key as TypeTab)}
      />

      <div className="px-6 pt-4 flex flex-wrap items-center gap-3 border-b border-border pb-4">
        <label className="text-sm text-muted-foreground shrink-0">Site :</label>
        <select
          value={siteFilter}
          onChange={e => setSiteFilter(e.target.value)}
          className="bg-secondary border border-border rounded-md px-3 py-1.5 text-sm text-foreground min-w-[180px]"
        >
          {SITE_OPTIONS.map(s => (
            <option key={s.value} value={s.value}>{s.label}</option>
          ))}
        </select>
        <div className="ml-auto flex flex-wrap items-center gap-4">
          <span className="text-xs text-muted-foreground">
            {loading ? 'Chargement…' : `${items.length} élément${items.length !== 1 ? 's' : ''} affiché${items.length !== 1 ? 's' : ''}`}
          </span>
          <DiskSpaceIndicator stats={diskStats} loading={diskLoading} />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6">
        <div className="space-y-4">
          {/* Toolbar — même style que DataTable */}
          <div className="flex items-center gap-3 flex-wrap">
            <div className="relative flex-1 min-w-[200px]">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder="Rechercher par nom, URL, texte alternatif…"
                value={search}
                onChange={e => setSearch(e.target.value)}
                className="pl-9 h-9 bg-secondary border-border text-sm"
              />
            </div>

            <Select value={uploadType} onValueChange={v => setUploadType(v as UploadFileKind)}>
              <SelectTrigger className="w-[120px] bg-secondary border-border h-9 text-sm">
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="bg-card border-border">
                <SelectItem value="image">Image</SelectItem>
                <SelectItem value="video">Vidéo</SelectItem>
                <SelectItem value="document">PDF</SelectItem>
              </SelectContent>
            </Select>

            <Select value={uploadContext} onValueChange={setUploadContext}>
              <SelectTrigger className="w-[130px] bg-secondary border-border h-9 text-sm">
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="bg-card border-border">
                <SelectItem value="global">Global</SelectItem>
                <SelectItem value="formation">Formation</SelectItem>
                <SelectItem value="trainer">Trainer</SelectItem>
                <SelectItem value="blog">Blog</SelectItem>
                <SelectItem value="recrutement">Recrutement</SelectItem>
                <SelectItem value="medical">Médical</SelectItem>
              </SelectContent>
            </Select>

            <input
              ref={fileInputRef}
              type="file"
              multiple
              accept={FILE_ACCEPT[uploadType]}
              className="hidden"
              onChange={e => handleUpload(e.target.files)}
            />

            <Button
              size="sm"
              disabled={uploading}
              onClick={() => fileInputRef.current?.click()}
              className="h-9 gap-2 text-sm font-medium"
              style={{ background: COLOR, boxShadow: `0 2px 12px ${COLOR}40` }}
            >
              {uploading ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <Plus className="w-4 h-4" />
              )}
              {uploading ? 'Envoi…' : 'Uploader un fichier'}
            </Button>
          </div>

          {loading ? (
            <div className="flex justify-center py-20">
              <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
          ) : items.length === 0 ? (
            <div className="rounded-xl border border-dashed border-border bg-card/50 py-16 text-center">
              <ImageIcon className="h-12 w-12 mx-auto text-muted-foreground/40 mb-3" />
              <p className="text-sm text-muted-foreground">Aucun média pour ces filtres.</p>
              <Button
                variant="outline"
                size="sm"
                className="mt-4 border-border gap-2"
                onClick={() => fileInputRef.current?.click()}
              >
                <Upload className="h-4 w-4" />
                Uploader un fichier
              </Button>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
              {items.map(item => (
                <div
                  key={item.id}
                  role="button"
                  tabIndex={0}
                  className="group rounded-xl border border-border overflow-hidden bg-card hover:shadow-md transition-shadow cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  onClick={() => openDetail(item)}
                  onKeyDown={e => { if (e.key === 'Enter' || e.key === ' ') openDetail(item); }}
                >
                  <div className="aspect-square overflow-hidden bg-secondary relative">
                    <GridThumb item={item} />
                    <div className="absolute top-2 left-2">
                      <Badge variant="secondary" className="text-[10px] px-1.5 py-0 bg-background/90">
                        {FILE_TYPE_LABELS[item.file_type] ?? item.file_type}
                      </Badge>
                    </div>
                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors" />
                  </div>
                  <div className="p-2.5 space-y-1 border-t border-border">
                    <p className="text-xs font-medium truncate text-foreground" title={item.original_name ?? item.file_name}>
                      {item.original_name ?? item.file_name}
                    </p>
                    <p className="text-[10px] text-muted-foreground truncate">
                      {item.site_id ? SITE_LABELS[String(item.site_id)] : 'Global'} · {formatFileSize(item.file_size)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <Dialog open={!!selected} onOpenChange={v => !v && setSelected(null)}>
        <DialogContent className="max-w-lg bg-card border-border text-foreground">
          {selected && (
            <>
              <DialogHeader>
                <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>
                  {selected.original_name ?? selected.file_name}
                </DialogTitle>
              </DialogHeader>

              <MediaPreview item={selected} />

              <div className="space-y-3 text-sm">
                <div className="flex flex-wrap gap-2">
                  <Badge variant="outline">{FILE_TYPE_LABELS[selected.file_type]}</Badge>
                  <Badge variant="outline">{formatFileSize(selected.file_size)}</Badge>
                  <Badge variant="outline">
                    {selected.site_id ? SITE_LABELS[String(selected.site_id)] : 'Global'}
                  </Badge>
                </div>

                <div>
                  <Label className="text-xs text-muted-foreground">URL publique</Label>
                  <div className="flex gap-2 mt-1">
                    <Input readOnly value={resolveMediaUrl(selected.url)} className="bg-secondary border-border text-xs font-mono h-9" />
                    <Button type="button" variant="outline" size="icon" className="shrink-0 border-border h-9 w-9" onClick={() => copyUrl(resolveMediaUrl(selected.url))}>
                      <Copy className="h-4 w-4" />
                    </Button>
                  </div>
                </div>

                <div>
                  <Label htmlFor="alt-text" className="text-xs text-muted-foreground">Texte alternatif (SEO / accessibilité)</Label>
                  <Textarea
                    id="alt-text"
                    value={altDraft}
                    onChange={e => setAltDraft(e.target.value)}
                    placeholder="Description de l'image pour les lecteurs d'écran et Google"
                    className="mt-1 bg-secondary border-border min-h-[72px] resize-y"
                  />
                </div>

                <p className="text-[11px] text-muted-foreground">
                  Ajouté le {new Date(selected.created_at).toLocaleString('fr-FR')}
                  {selected.mime_type && ` · ${selected.mime_type}`}
                </p>
              </div>

              <DialogFooter className="gap-2 flex-wrap sm:flex-nowrap">
                <Button variant="destructive" size="sm" onClick={() => setDeleteTarget(selected)}>
                  <Trash2 className="h-4 w-4 mr-1.5" /> Supprimer
                </Button>
                <Button variant="outline" size="sm" className="border-border" onClick={() => setSelected(null)}>
                  Fermer
                </Button>
                <Button size="sm" style={{ background: COLOR }} disabled={savingAlt} onClick={saveAlt}>
                  {savingAlt ? 'Enregistrement…' : 'Enregistrer'}
                </Button>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>

      <ConfirmDelete
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={confirmDelete}
        label={deleteTarget?.original_name ?? deleteTarget?.file_name ?? 'ce média'}
      />
    </div>
  );
}
