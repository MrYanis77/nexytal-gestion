interface SiteHeaderProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  color: string;
  tabs?: { key: string; label: string; count?: number }[];
  activeTab?: string;
  onTabChange?: (key: string) => void;
}

export function SiteHeader({ icon, title, description, color, tabs, activeTab, onTabChange }: SiteHeaderProps) {
  return (
    <div className="border-b border-border bg-card/50 px-6 pt-6 pb-0">
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
          style={{ background: color + '20' }}>
          <span style={{ color }}>{icon}</span>
        </div>
        <div>
          <h1 className="text-xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>{title}</h1>
          <p className="text-xs text-muted-foreground">{description}</p>
        </div>
      </div>

      {tabs && (
        <div className="flex gap-1 overflow-x-auto">
          {tabs.map(tab => (
            <button
              key={tab.key}
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
                <span className={`text-xs px-1.5 py-0.5 rounded-full font-medium
                  ${activeTab === tab.key ? '' : 'bg-secondary text-muted-foreground'}`}
                  style={activeTab === tab.key ? { background: color + '25', color } : {}}>
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
