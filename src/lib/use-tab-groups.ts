import { useCallback, useState } from 'react';
import type { TabGroup } from '@/components/SiteHeader';

export function useTabGroups(groups: TabGroup[], defaultGroup?: string, defaultTab?: string) {
  const initialGroup = defaultGroup ?? groups[0]?.key ?? '';
  const initialTab = defaultTab ?? groups.find(g => g.key === initialGroup)?.tabs[0]?.key ?? groups[0]?.tabs[0]?.key ?? '';

  const [activeGroup, setActiveGroup] = useState(initialGroup);
  const [activeTab, setActiveTab] = useState(initialTab);

  const onGroupChange = useCallback((groupKey: string) => {
    setActiveGroup(groupKey);
    const firstTab = groups.find(g => g.key === groupKey)?.tabs[0]?.key;
    if (firstTab) setActiveTab(firstTab);
  }, [groups]);

  return { activeGroup, activeTab, setActiveTab, onGroupChange };
}
