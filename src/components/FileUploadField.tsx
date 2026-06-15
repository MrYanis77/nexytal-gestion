import { useRef, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Upload, X, Loader2, Film, FileText, Images } from 'lucide-react';
import { toast } from 'sonner';
import { MediaPickerDialog } from '@/components/MediaPickerDialog';
import {
  uploadMediaFile,
  resolveMediaUrl,
  FILE_ACCEPT,
  FILE_KIND_HINT,
  type UploadFileKind,
} from '@/lib/upload';

interface FileUploadFieldProps {
  value: string;
  onChange: (url: string) => void;
  fileKind: UploadFileKind;
  uploadContext?: string;
  placeholder?: string;
  allowUrl?: boolean;
}

export function FileUploadField({
  value,
  onChange,
  fileKind,
  uploadContext,
  placeholder,
  allowUrl = true,
}: FileUploadFieldProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [pickerOpen, setPickerOpen] = useState(false);

  const displayUrl = resolveMediaUrl(value);

  const handleFile = async (file: File | null) => {
    if (!file) return;
    setUploading(true);
    try {
      const result = await uploadMediaFile(file, {
        type: fileKind,
        context: uploadContext,
      });
      onChange(result.url);
      toast.success('Fichier uploadé');
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Échec de l\'upload');
    } finally {
      setUploading(false);
      if (inputRef.current) inputRef.current.value = '';
    }
  };

  return (
    <div className="space-y-2">
      {value && fileKind === 'image' && (
        <div className="relative inline-block max-w-full">
          <img
            src={displayUrl}
            alt="Aperçu"
            className="max-h-40 rounded-lg border border-border object-cover"
            onError={e => { (e.target as HTMLImageElement).style.opacity = '0.3'; }}
          />
          <Button
            type="button"
            variant="secondary"
            size="icon"
            className="absolute -top-2 -right-2 h-7 w-7 rounded-full shadow"
            onClick={() => onChange('')}
          >
            <X className="h-3.5 w-3.5" />
          </Button>
        </div>
      )}

      {value && fileKind === 'video' && (
        <div className="relative max-w-full">
          <video
            src={displayUrl}
            controls
            className="max-h-48 w-full rounded-lg border border-border bg-black/20"
          />
          <Button
            type="button"
            variant="secondary"
            size="icon"
            className="absolute top-2 right-2 h-7 w-7 rounded-full shadow"
            onClick={() => onChange('')}
          >
            <X className="h-3.5 w-3.5" />
          </Button>
        </div>
      )}

      {value && fileKind === 'document' && (
        <div className="flex items-center gap-2 rounded-lg border border-border bg-secondary/40 px-3 py-2 text-sm">
          <FileText className="h-4 w-4 shrink-0 text-muted-foreground" />
          <a href={displayUrl} target="_blank" rel="noreferrer" className="truncate text-primary hover:underline">
            {value.split('/').pop()}
          </a>
          <Button type="button" variant="ghost" size="icon" className="ml-auto h-7 w-7" onClick={() => onChange('')}>
            <X className="h-3.5 w-3.5" />
          </Button>
        </div>
      )}

      <div className="flex flex-wrap gap-2">
        <input
          ref={inputRef}
          type="file"
          accept={FILE_ACCEPT[fileKind]}
          className="hidden"
          onChange={e => handleFile(e.target.files?.[0] ?? null)}
        />
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="border-border"
          disabled={uploading}
          onClick={() => inputRef.current?.click()}
        >
          {uploading ? (
            <Loader2 className="h-4 w-4 mr-1.5 animate-spin" />
          ) : fileKind === 'video' ? (
            <Film className="h-4 w-4 mr-1.5" />
          ) : (
            <Upload className="h-4 w-4 mr-1.5" />
          )}
          {uploading ? 'Envoi…' : fileKind === 'video' ? 'Choisir une vidéo' : 'Choisir un fichier'}
        </Button>
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="border-border"
          onClick={() => setPickerOpen(true)}
        >
          <Images className="h-4 w-4 mr-1.5" />
          Médiathèque
        </Button>
        {value && (
          <span className="text-xs text-muted-foreground self-center truncate max-w-[200px]">
            {value.split('/').pop()}
          </span>
        )}
      </div>

      <p className="text-xs text-muted-foreground">{FILE_KIND_HINT[fileKind]}</p>

      {allowUrl && (
        <Input
          value={value}
          onChange={e => onChange(e.target.value)}
          placeholder={placeholder ?? 'Ou coller une URL…'}
          className="bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 h-9 text-sm"
        />
      )}

      <MediaPickerDialog
        open={pickerOpen}
        onClose={() => setPickerOpen(false)}
        onSelect={url => onChange(url)}
        fileKind={fileKind}
      />
    </div>
  );
}
