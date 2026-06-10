import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { useState, useEffect } from 'react';

export interface FieldDef {
  key: string;
  label: string;
  type: 'text' | 'textarea' | 'select' | 'switch' | 'number' | 'date' | 'email';
  options?: { value: string; label: string }[];
  placeholder?: string;
  required?: boolean;
  span?: boolean;
}

interface FormModalProps {
  open: boolean;
  onClose: () => void;
  onSave: (data: Record<string, unknown>) => void;
  title: string;
  fields: FieldDef[];
  initialData?: Record<string, unknown>;
  accentColor?: string;
}

export function FormModal({ open, onClose, onSave, title, fields, initialData, accentColor = '#2563EB' }: FormModalProps) {
  const [form, setForm] = useState<Record<string, unknown>>({});

  useEffect(() => {
    if (open) {
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
        } else {
          defaults[f.key] = initialData?.[f.key] ?? '';
        }
      });
      setForm(defaults);
    }
  }, [open, initialData]);

  const handleSave = () => {
    onSave(form);
    onClose();
  };

  const set = (key: string, val: unknown) => setForm(p => ({ ...p, [key]: val }));

  return (
    <Dialog open={open} onOpenChange={v => !v && onClose()}>
      <DialogContent className="max-w-2xl bg-card border-border text-foreground max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>{title}</DialogTitle>
        </DialogHeader>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 py-2">
          {fields.map(f => (
            <div key={f.key} className={f.span ? 'sm:col-span-2' : ''}>
              <Label className="text-sm text-foreground/80 mb-1.5 block">{f.label}{f.required && <span className="text-destructive ml-1">*</span>}</Label>

              {f.type === 'textarea' && (
                <Textarea
                  value={String(form[f.key] ?? '')}
                  onChange={e => set(f.key, e.target.value)}
                  placeholder={f.placeholder}
                  className="bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 min-h-[80px] resize-none"
                />
              )}

              {(f.type === 'text' || f.type === 'number' || f.type === 'date' || f.type === 'email') && (
                <Input
                  type={f.type}
                  value={String(form[f.key] ?? '')}
                  onChange={e => set(f.key, e.target.value)}
                  placeholder={f.placeholder}
                  className="bg-secondary border-border text-foreground placeholder:text-muted-foreground/50 h-9"
                />
              )}

              {f.type === 'select' && f.options && f.options.filter(o => o.value !== '').length > 0 && (
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
            </div>
          ))}
        </div>

        <DialogFooter className="gap-2">
          <Button variant="outline" onClick={onClose} className="border-border">Annuler</Button>
          <Button onClick={handleSave} style={{ background: accentColor }}>Enregistrer</Button>
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
