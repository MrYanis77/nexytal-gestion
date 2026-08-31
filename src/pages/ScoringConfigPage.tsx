import { useEffect, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { ScoringConfigResponse, ScoringWeights, scoringWeightsTotal } from '@/lib/mappers/spec';
import { Button } from '@/components/ui/button';
import { SlidersHorizontal } from 'lucide-react';
import { toast } from 'sonner';

const WEIGHT_LABELS: { key: keyof ScoringWeights; label: string }[] = [
  { key: 'competences', label: 'Compétences clés' },
  { key: 'experience', label: 'Expérience' },
  { key: 'localisation', label: 'Localisation / mode travail' },
  { key: 'diplome', label: 'Diplôme / certifications' },
  { key: 'langues', label: 'Langues' },
  { key: 'bonus_champs_site', label: 'Bonus champs site (max)' },
];

const SITE_OPTIONS = [
  { id: '', label: 'Global (tous sites)' },
  { id: '1', label: 'Alt Formation' },
  { id: '2', label: 'Nexytal Recrutement' },
  { id: '3', label: 'Nexytal Medical' },
  { id: '4', label: 'Nexytal Carrière' },
  { id: '5', label: 'Nexytal Trainer' },
  { id: '6', label: 'Nexytal Coaching' },
];

const DEFAULT_WEIGHTS: ScoringWeights = {
  competences: 40,
  experience: 25,
  localisation: 15,
  diplome: 12,
  langues: 8,
  bonus_champs_site: 10,
};

export default function ScoringConfigPage() {
  const [siteScope, setSiteScope] = useState('');
  const [weights, setWeights] = useState<ScoringWeights>(DEFAULT_WEIGHTS);
  const [saving, setSaving] = useState(false);

  const qs = siteScope ? `?site_id=${siteScope}` : '';
  const { data, loading, refetch } = useFetch<{ data: ScoringConfigResponse }>(
    `/recrutement/config/scoring${qs}`,
  );

  useEffect(() => {
    if (data?.data?.weights) {
      setWeights(data.data.weights);
    }
  }, [data]);

  const mainTotal = scoringWeightsTotal(weights);
  const isValid = mainTotal === 100;

  const save = async () => {
    if (!isValid) {
      toast.error(`La somme des 5 critères principaux doit être 100 (actuel : ${mainTotal})`);
      return;
    }
    setSaving(true);
    try {
      await api.put(`/recrutement/config/scoring${qs}`, { weights });
      toast.success('Configuration enregistrée');
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde'));
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="p-6 space-y-6 fade-up max-w-2xl">
      <div>
        <h1 className="text-2xl font-bold text-foreground flex items-center gap-2" style={{ fontFamily: 'Space Grotesk' }}>
          <SlidersHorizontal className="w-6 h-6 text-violet-500" />
          Configuration scoring
        </h1>
        <p className="text-sm text-muted-foreground mt-1">
          Poids des critères d'affinité (total principal = 100)
        </p>
      </div>

      <div>
        <label className="text-sm font-medium text-foreground block mb-2">Périmètre</label>
        <select
          value={siteScope}
          onChange={e => setSiteScope(e.target.value)}
          className="w-full text-sm rounded-lg border border-border bg-card px-3 py-2"
        >
          {SITE_OPTIONS.map(s => (
            <option key={s.id || 'global'} value={s.id}>{s.label}</option>
          ))}
        </select>
      </div>

      {loading ? (
        <p className="text-sm text-muted-foreground">Chargement…</p>
      ) : (
        <div className="space-y-5 rounded-xl border border-border p-5 bg-card">
          {WEIGHT_LABELS.map(({ key, label }) => (
            <div key={key}>
              <div className="flex justify-between text-sm mb-1.5">
                <span className="text-foreground">{label}</span>
                <span className="font-semibold text-foreground">{weights[key]}</span>
              </div>
              <input
                type="range"
                min={0}
                max={key === 'bonus_champs_site' ? 20 : 60}
                value={weights[key]}
                onChange={e => setWeights(w => ({ ...w, [key]: Number(e.target.value) }))}
                className="w-full accent-violet-500"
              />
            </div>
          ))}

          <div className={`text-sm font-medium ${isValid ? 'text-emerald-500' : 'text-amber-500'}`}>
            Total critères principaux : {mainTotal}/100
            {!isValid && ' — ajustez les sliders pour atteindre 100'}
          </div>

          <Button onClick={save} disabled={saving || !isValid}>
            {saving ? 'Enregistrement…' : 'Enregistrer'}
          </Button>
        </div>
      )}
    </div>
  );
}
