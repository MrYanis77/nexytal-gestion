import { TrendingUp } from 'lucide-react';
import { SiteRecruitmentBoard } from './SiteRecruitmentBoard';

const COLOR = '#D97706';

export default function SiteCarriere() {
  return (
    <SiteRecruitmentBoard
      siteId={4}
      color={COLOR}
      title="Nexytal Carrière"
      description="Offres, candidatures, entreprises et actualités du site carrière"
      icon={<TrendingUp className="w-5 h-5" />}
      showSitePricing
    />
  );
}
