import { useEffect, useMemo, useState } from 'react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Film, FileText, ImageIcon, Loader2, Search } from 'lucide-react';
import {
  fetchMediaList,
  mediaMatchesKind,
  mediaSearchHaystack,
  type MediaItem,
} from '@/lib/media';
import { resolveMediaUrl, type UploadFileKind } from '@/lib/upload';

interface MediaPickerDialogProps {
  open: boolean;
  onClose: () => void;
  onSelect: (url: string, item?: MediaItem) => void;
  fileKind?: UploadFileKind;
  title?: string;
}

function MediaThumb({ item }: { item: MediaItem }) {
  const url = resolveMediaUrl(item.url);
  if (item.file_type === 'video') {
    return (
      <div className="flex h-full w-full items-center justify-center bg-black/30">
        <Film className="h-8 w-8 text-muted-foreground" />
      </div>
    );
  }
  if (item.file_type === 'document') {
    return (
      <div className="flex h-full w-full items-center justify-center bg-secondary">
        <FileText className="h-8 w-8 text-muted-foreground" />
      </div>
    );
  }
  return (
    <img
      src={url}
      alt={item.alt_text ?? item.original_name ?? item.file_name}
      className="h-full w-full object-cover"
      loading="lazy"
    />
  );
}

export function MediaPickerDialog({
  open,
  onClose,
  onSelect,
  fileKind = 'image',
  title = 'Choisir dans la médiathèque',
}: MediaPickerDialogProps) {
  const [search, setSearch] = useState('');
  const [items, setItems] = useState<MediaItem[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    setLoading(true);
    const fileType = fileKind === 'video' ? 'video' : fileKind === 'document' ? 'document' : 'image';
    fetchMediaList({ fileType, limit: 100 })
      .then(list => { if (!cancelled) setItems(list); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [open, fileKind]);

  const filtered = useMemo(() => {
    const list = items.filter(i => mediaMatchesKind(i, fileKind));
    const q = search.trim().toLowerCase();
    if (!q) return list;
    return list.filter(i => mediaSearchHaystack(i).includes(q));
  }, [items, fileKind, search]);

  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className="max-w-3xl bg-card border-border text-foreground">
        <DialogHeader>
          <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>{title}</DialogTitle>
        </DialogHeader>

        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Rechercher un fichier…"
            className="pl-9 bg-secondary border-border"
          />
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-16 text-muted-foreground">
            <Loader2 className="h-6 w-6 animate-spin mr-2" />
            Chargement…
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-12 text-center text-sm text-muted-foreground">
            <ImageIcon className="h-10 w-10 mx-auto mb-2 opacity-40" />
            Aucun média trouvé. Uploadez des fichiers depuis la page Médiathèque.
          </div>
        ) : (
          <ScrollArea className="h-[min(60vh,420px)] pr-2">
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
              {filtered.map(item => (
                <button
                  key={item.id}
                  type="button"
                  className="group rounded-lg border border-border overflow-hidden text-left hover:ring-2 hover:ring-primary/50 transition-all bg-secondary/30"
                  onClick={() => {
                    onSelect(item.url, item);
                    onClose();
                  }}
                >
                  <div className="aspect-square overflow-hidden bg-secondary">
                    <MediaThumb item={item} />
                  </div>
                  <div className="p-2 space-y-0.5">
                    <p className="text-xs font-medium truncate text-foreground">
                      {item.original_name ?? item.file_name}
                    </p>
                    <p className="text-[10px] text-muted-foreground truncate">{item.url}</p>
                  </div>
                </button>
              ))}
            </div>
          </ScrollArea>
        )}

        <div className="flex justify-end">
          <Button variant="outline" onClick={onClose} className="border-border">
            Annuler
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
