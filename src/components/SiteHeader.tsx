export interface SiteTab {
  key: string;
  label: string;
  count?: number;
}

export interface TabGroup {
  key: string;
  label: string;
  tabs: SiteTab[];
}

interface SiteHeaderProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  color: string;
  /** Onglets plats (legacy) */
  tabs?: SiteTab[];
  activeTab?: string;
  onTabChange?: (key: string) => void;
  /** Navigation par sections (recommandé) */
  tabGroups?: TabGroup[];
  activeGroup?: string;
  onGroupChange?: (groupKey: string) => void;
  /** Masque le bloc titre/icône — onglets uniquement (module embarqué) */
  compact?: boolean;
}

export function SiteHeader({
  icon,
  title,
  description,
  color,
  tabs,
  activeTab,
  onTabChange,
  tabGroups,
  activeGroup,
  onGroupChange,
  compact = false,
}: SiteHeaderProps) {
  const visibleTabs = tabGroups
    ? tabGroups.find(g => g.key === activeGroup)?.tabs ?? tabGroups[0]?.tabs ?? []
    : tabs ?? [];

  return (
    <div className={`border-b border-border bg-card/50 px-6 pb-0 ${compact ? 'pt-3' : 'pt-6'}`}>
      {!compact && (
      <div className="flex items-center gap-3 mb-4">
        <div
          className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
          style={{ background: color + '20' }}
        >
          <span style={{ color }}>{icon}</span>
        </div>
        <div>
          <h1 className="text-xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>{title}</h1>
          <p className="text-xs text-muted-foreground">{description}</p>
        </div>
      </div>
      )}

      {tabGroups && tabGroups.length > 0 && (
        <div className="flex flex-wrap gap-2 mb-3">
          {tabGroups.map(group => (
            <button
              key={group.key}
              type="button"
              onClick={() => onGroupChange?.(group.key)}
              className={`px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
                activeGroup === group.key
                  ? 'text-white shadow-sm'
                  : 'bg-secondary text-muted-foreground hover:text-foreground'
              }`}
              style={activeGroup === group.key ? { background: color } : undefined}
            >
              {group.label}
            </button>
          ))}
        </div>
      )}

      {visibleTabs.length > 1 && (
        <div className="flex gap-1 overflow-x-auto pb-px">
          {visibleTabs.map(tab => (
            <button
              key={tab.key}
              type="button"
              onClick={() => onTabChange?.(tab.key)}
              className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium border-b-2 transition-all whitespace-nowrap
                ${activeTab === tab.key
                  ? 'border-current text-foreground'
                  : 'border-transparent text-muted-foreground hover:text-foreground'
                }`}
              style={activeTab === tab.key ? { color, borderColor: color } : {}}
            >
              {tab.label}
              {tab.count !== undefined && (
                <span
                  className={`text-xs px-1.5 py-0.5 rounded-full font-medium
                    ${activeTab === tab.key ? '' : 'bg-secondary text-muted-foreground'}`}
                  style={activeTab === tab.key ? { background: color + '25', color } : {}}
                >
                  {tab.count}
                </span>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
