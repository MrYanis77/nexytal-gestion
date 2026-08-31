interface ScoreBadgeProps {
  score: number | null | undefined;
  className?: string;
}

function scoreColor(score: number): string {
  if (score >= 80) return 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30';
  if (score >= 60) return 'bg-green-500/15 text-green-400 border-green-500/25';
  if (score >= 40) return 'bg-amber-500/20 text-amber-400 border-amber-500/30';
  return 'bg-red-500/20 text-red-400 border-red-500/30';
}

export default function ScoreBadge({ score, className = '' }: ScoreBadgeProps) {
  if (score === null || score === undefined) {
    return (
      <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-xs border border-border text-muted-foreground ${className}`}>
        —
      </span>
    );
  }

  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded-md text-xs font-semibold border ${scoreColor(score)} ${className}`}
      title={`Score d'affinité : ${score}/100`}
    >
      {score}
    </span>
  );
}

export function scoreLabel(score: number): string {
  if (score >= 80) return 'Excellent';
  if (score >= 60) return 'Bon';
  if (score >= 40) return 'Moyen';
  return 'Faible';
}
