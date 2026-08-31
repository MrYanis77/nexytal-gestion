import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Checkbox } from '@/components/ui/checkbox';
import { ScrollArea } from '@/components/ui/scroll-area';
import { useState, useEffect, type ReactNode } from 'react';
import { Plus, Trash2, ChevronDown } from 'lucide-react';
import { toast } from 'sonner';
import { FileUploadField } from '@/components/FileUploadField';
import type { UploadFileKind } from '@/lib/upload';

export type ModuleListItem = { title: string; description: string; duration?: string };

export interface FieldDef {
  key: string;
  label: string;
  type: 'text' | 'textarea' | 'select' | 'multi_select' | 'switch' | 'number' | 'date' | 'email' | 'module_list' | 'file' | 'link';
  /** Pour type file : image, vidéo ou document */
  fileKind?: UploadFileKind;
  /** Sous-dossier d'upload côté API (trainers, formation, blog…) */
  uploadContext?: string;
  options?: { value: string; label: string }[];
  placeholder?: string;
  required?: boolean;
  span?: boolean;
  /** Titre de section affiché avant ce champ */
  section?: string;
  hint?: string;
  /** Champs affichés après clic sur un lien du même groupe */
  toggleGroup?: string;
  /** module_list : variante FAQ (question / réponse, sans durée) */
  moduleListMode?: 'default' | 'faq';
}

interface FormModalProps {
  open: boolean;
  onClose: () => void;
  onSave: (data: Record<string, unknown>) => void | Promise<void>;
  title: string;
  fields: FieldDef[];
  initialData?: Record<string, unknown>;
  accentColor?: string;
  wide?: boolean;
  /** Boutons additionnels à gauche du footer (ex. Publier / Refuser) */
  footerExtra?: ReactNode;
  /** site_id pour l'upload média (prioritaire sur la détection par URL) */
  siteId?: string;
}

export function FormModal({ open, onClose, onSave, title, fields, initialData, accentColor = '#2563EB', wide, footerExtra, siteId }: FormModalProps) {
  const [form, setForm] = useState<Record<string, unknown>>({});
  const [saving, setSaving] = useState(false);
  const [expandedToggleGroups, setExpandedToggleGroups] = useState<Set<string>>(new Set());

  useEffect(() => {
    if (open) {
      setExpandedToggleGroups(new Set());
      const defaults: Record<string, unknown> = {};
      fields.forEach(f => {
        if (f.type === 'switch') {
          defaults[f.key] = initialData?.[f.key] ?? false;
        } else if (f.type === 'select' && f.options?.length) {
          const valid = f.options.filter(o => o.value !== '');
          const init = initialData?.[f.key];
          const initStr = init != null && init !== '' ? String(init) : '';
          defaults[f.key] = valid.some(o => o.value === initStr)
            ? initStr
            : valid[0]?.value ?? '';
        } else if (f.type === 'multi_select') {
          const init = initialData?.[f.key];
          if (Array.isArray(init)) {
            defaults[f.key] = init.map(String);
          } else if (typeof init === 'string' && init.trim()) {
            defaults[f.key] = init.split(',').map(s => s.trim()).filter(Boolean);
          } else {
            defaults[f.key] = [];
          }
        } else if (f.type === 'module_list') {
          const init = initialData?.[f.key];
          defaults[f.key] = Array.isArray(init) && init.length > 0
            ? init.map(m => ({
                title: String((m as ModuleListItem).title ?? ''),
                description: String((m as ModuleListItem).description ?? ''),
                duration: String((m as ModuleListItem).duration ?? ''),
              }))
            : [{ title: '', description: '', duration: '' }];
        } else if (f.type === 'file') {
          defaults[f.key] = initialData?.[f.key] ?? '';
        } else {
          defaults[f.key] = initialData?.[f.key] ?? '';
        }
      });
      setForm(defaults);
    }
  }, [open, initialData, fields]);

  const handleSave = async () => {
    for (const f of fields) {
      if (!f.required) continue;
      const val = form[f.key];
      if (f.type === 'switch') continue;
      if (f.type === 'multi_select') {
        if (!Array.isArray(val) || val.length === 0) {
          toast.error(`Le champ « ${f.label} » est obligatoire.`);
          return;
        }
        continue;
      }
      if (val == null || String(val).trim() === '') {
        toast.error(`Le champ « ${f.label} » est obligatoire.`);
        return;
      }
    }
    setSaving(true);
    try {
      await onSave(form);
    } catch {
      // La modale reste ouverte en cas d'erreur
    } finally {
      setSaving(false);
    }
  };

  const set = (key: string, val: unknown) => setForm(p => ({ ...p, [key]: val }));

  const toggleMultiSelect = (key: string, value: string, checked: boolean) => {
    setForm(p => {
      const current = Array.isArray(p[key]) ? (p[key] as string[]) : [];
      return {
        ...p,
        [key]: checked ? [...current, value] : current.filter(v => v !== value),
      };
    });
  };

  const multiSelectSummary = (key: string, options: { value: string; label: string }[], placeholder: string) => {
    const selected = Array.isArray(form[key]) ? (form[key] as string[]) : [];
    const labels = options.filter(o => selected.includes(o.value)).map(o => o.label);
    if (labels.length === 0) return placeholder;
    if (labels.length <= 2) return labels.join(', ');
    return `${labels.length} éléments sélectionnés`;
  };

  const updateModuleList = (key: string, index: number, field: keyof ModuleListItem, value: string) => {
    setForm(p => {
      const list = [...((p[key] as ModuleListItem[]) ?? [])];
      list[index] = { ...list[index], [field]: value };
      return { ...p, [key]: list };
    });
  };

  const addModuleListItem = (key: string) => {
    setForm(p => ({
      ...p,
      [key]: [...((p[key] as ModuleListItem[]) ?? []), { title: '', description: '', duration: '' }],
    }));
  };

  const removeModuleListItem = (key: string, index: number) => {
    setForm(p => {
      const list = [...((p[key] as ModuleListItem[]) ?? [])];
      if (list.length <= 1) return { ...p, [key]: [{ title: '', description: '', duration: '' }] };
      list.splice(index, 1);
      return { ...p, [key]: list };
    });
  };

  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className={`${wide ? 'max-w-5xl' : 'max-w-2xl'} bg-card border-border text-foreground max-h-[90vh] overflow-y-auto`}>
        <DialogHeader>
          <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>{title}</DialogTitle>
        </DialogHeader>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 py-2">
          {fields.flatMap((f, idx) => {
            if (f.toggleGroup && f.type !== 'link' && !expandedToggleGroups.has(f.toggleGroup)) {
              return [];
            }

            const showSection = f.section && (idx === 0 || fields[idx - 1]?.section !== f.section);
            const nodes: ReactNode[] = [];
            if (showSection) {
              nodes.push(
                <div key={`section-${f.section}-${idx}`} className={`sm:col-span-2 ${idx > 0 ? 'mt-2 pt-4 border-t border-border' : ''}`}>
                  <h3 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>{f.section}</h3>
                </div>
              );
            }
            nodes.push(
            <div key={f.key} className={f.span ? 'sm:col-span-2' : ''}>
              {f.type !== 'link' && (
                <Label className="text-sm text-foreground/80 mb-1.5 block">{f.label}{f.required && <span className="text-destructive ml-1">*</span>}</Label>
              )}
              {f.hint && f.type !== 'link' && <p className="text-xs text-muted-foreground mb-1.5">{f.hint}</p>}

              {f.type === 'link' && f.toggleGroup && (
                <button
                  type="button"
                  className="text-sm font-medium underline-offset-2 hover:underline"
                  style={{ color: accentColor }}
                  onClick={() => setExpandedToggleGroups(prev => {
                    const next = new Set(prev);
                    if (next.has(f.toggleGroup!)) next.delete(f.toggleGroup!);
                    else next.add(f.toggleGroup!);
                    return next;
                  })}
                >
                  {expandedToggleGroups.has(f.toggleGroup) ? 'Masquer le formulaire auteur' : f.label}
                </button>
              )}

              {f.type === 'textarea' && (
                <Textarea
                  value={String(form[f.key] ?? '')}
                  onChange={e => set(f.key, e.target.value)}
                  placeholder={f.placeholder}
                  className={`bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 resize-y ${
                    f.key.endsWith('_text') ? 'min-h-[120px]' : 'min-h-[80px]'
                  }`}
                />
              )}

              {(f.type === 'text' || f.type === 'number' || f.type === 'date' || f.type === 'email') && (
                <Input
                  type={f.type}
                  value={String(form[f.key] ?? '')}
                  onChange={e => set(f.key, e.target.value)}
                  onWheel={f.type === 'number' ? (e) => e.currentTarget.blur() : undefined}
                  placeholder={f.placeholder}
                  className="bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 h-9"
                />
              )}

              {f.type === 'multi_select' && f.options && (
                f.options.length > 0 ? (
                  <Popover>
                    <PopoverTrigger asChild>
                      <button
                        type="button"
                        className="flex h-9 w-full items-center justify-between gap-2 rounded-md border border-border bg-secondary px-3 py-2 text-sm text-left shadow-xs outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
                      >
                        <span className={`truncate ${Array.isArray(form[f.key]) && (form[f.key] as string[]).length ? 'text-foreground' : 'text-muted-foreground'}`}>
                          {multiSelectSummary(f.key, f.options, f.placeholder ?? 'Sélectionner…')}
                        </span>
                        <ChevronDown className="h-4 w-4 shrink-0 text-muted-foreground" />
                      </button>
                    </PopoverTrigger>
                    <PopoverContent className="w-[var(--radix-popover-trigger-width)] p-0 bg-card border-border" align="start">
                      <ScrollArea className="max-h-56">
                        <div className="p-1">
                          {f.options.map(o => {
                            const checked = Array.isArray(form[f.key]) && (form[f.key] as string[]).includes(o.value);
                            return (
                              <label
                                key={o.value}
                                className="flex cursor-pointer items-center gap-2 rounded-sm px-2 py-2 text-sm hover:bg-secondary/80"
                              >
                                <Checkbox
                                  checked={checked}
                                  onCheckedChange={v => toggleMultiSelect(f.key, o.value, v === true)}
                                />
                                <span className="text-foreground">{o.label}</span>
                              </label>
                            );
                          })}
                        </div>
                      </ScrollArea>
                    </PopoverContent>
                  </Popover>
                ) : (
                  <p className="text-sm text-amber-600/90 bg-amber-500/10 border border-amber-500/20 rounded-md px-3 py-2">
                    {f.hint ?? 'Aucun choix disponible. Créez d\'abord des éléments dans l\'onglet Référentiels.'}
                  </p>
                )
              )}

              {f.type === 'select' && f.options && (
                f.options.filter(o => o.value !== '').length > 0 ? (
                  <Select
                    value={form[f.key] != null && String(form[f.key]) !== '' ? String(form[f.key]) : undefined}
                    onValueChange={v => set(f.key, v)}
                  >
                    <SelectTrigger className="bg-secondary border-border text-foreground h-9">
                      <SelectValue placeholder={f.placeholder ?? 'Sélectionner…'} />
                    </SelectTrigger>
                    <SelectContent className="bg-card border-border text-foreground">
                      {f.options.filter(o => o.value !== '').map(o => (
                        <SelectItem key={o.value} value={o.value}>{o.label}</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                ) : (
                  <p className="text-sm text-amber-600/90 bg-amber-500/10 border border-amber-500/20 rounded-md px-3 py-2">
                    {f.hint ?? 'Aucun choix disponible. Créez d\'abord un élément dans l\'onglet Annuaire.'}
                  </p>
                )
              )}

              {f.type === 'switch' && (
                <div className="flex items-center gap-2 mt-1">
                  <Switch
                    checked={Boolean(form[f.key])}
                    onCheckedChange={v => set(f.key, v)}
                    style={{ '--switch-bg': accentColor } as React.CSSProperties}
                  />
                  <span className="text-sm text-muted-foreground">{Boolean(form[f.key]) ? 'Oui' : 'Non'}</span>
                </div>
              )}

              {f.type === 'module_list' && (
                <div className="space-y-3">
                  {((form[f.key] as ModuleListItem[]) ?? []).map((mod, modIdx) => (
                    <div key={modIdx} className="rounded-lg border border-border bg-secondary/40 p-3 space-y-2">
                      <div className="flex items-center justify-between gap-2">
                        <span className="text-xs font-medium text-muted-foreground">
                          {f.moduleListMode === 'faq' ? `Question ${modIdx + 1}` : `Module ${modIdx + 1}`}
                        </span>
                        <Button
                          type="button"
                          variant="ghost"
                          size="icon"
                          className="h-7 w-7 text-muted-foreground hover:text-destructive"
                          onClick={() => removeModuleListItem(f.key, modIdx)}
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                      </div>
                      <Input
                        value={mod.title}
                        onChange={e => updateModuleList(f.key, modIdx, 'title', e.target.value)}
                        placeholder={f.moduleListMode === 'faq' ? 'Question fréquente…' : 'Nom du module'}
                        className="bg-secondary border-border text-foreground h-9"
                      />
                      {f.moduleListMode !== 'faq' && (
                        <Input
                          value={mod.duration ?? ''}
                          onChange={e => updateModuleList(f.key, modIdx, 'duration', e.target.value)}
                          placeholder="Durée (ex. 6 semaines)"
                          className="bg-secondary border-border text-foreground h-9"
                        />
                      )}
                      <Textarea
                        value={mod.description}
                        onChange={e => updateModuleList(f.key, modIdx, 'description', e.target.value)}
                        placeholder={f.moduleListMode === 'faq' ? 'Réponse…' : 'Contenu et détails du module…'}
                        className="bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 min-h-[88px] resize-y"
                      />
                    </div>
                  ))}
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="border-border w-full"
                    onClick={() => addModuleListItem(f.key)}
                  >
                    <Plus className="h-4 w-4 mr-1.5" />
                    {f.moduleListMode === 'faq' ? 'Ajouter une question' : 'Ajouter un module'}
                  </Button>
                </div>
              )}

              {f.type === 'file' && (
                <FileUploadField
                  value={String(form[f.key] ?? '')}
                  onChange={url => set(f.key, url)}
                  fileKind={f.fileKind ?? 'image'}
                  uploadContext={f.uploadContext}
                  siteId={siteId}
                  placeholder={f.placeholder}
                />
              )}
            </div>
            );
            return nodes;
          })}
        </div>

        <DialogFooter className="gap-2 sm:justify-between">
          <div className="flex flex-wrap gap-2">{footerExtra}</div>
          <div className="flex gap-2">
          <Button variant="outline" onClick={onClose} className="border-border" disabled={saving}>Annuler</Button>
          <Button onClick={handleSave} style={{ background: accentColor }} disabled={saving}>
            {saving ? 'Enregistrement…' : 'Enregistrer'}
          </Button>
          </div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Confirm Delete Dialog ────────────────────────────────────────────────────

interface ConfirmDeleteProps {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  label?: string;
}

export function ConfirmDelete({ open, onClose, onConfirm, label = 'cet élément' }: ConfirmDeleteProps) {
  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className="max-w-sm bg-card border-border text-foreground">
        <DialogHeader>
          <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>Confirmer la suppression</DialogTitle>
        </DialogHeader>
        <p className="text-sm text-muted-foreground py-2">
          Êtes-vous sûr de vouloir supprimer <strong className="text-foreground">{label}</strong> ? Cette action est irréversible.
        </p>
        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose} className="border-border">Annuler</Button>
          <Button variant="destructive" onClick={() => { onConfirm(); onClose(); }}>Supprimer</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
