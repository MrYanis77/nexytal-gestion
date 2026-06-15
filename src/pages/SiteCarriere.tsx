import { Briefcase } from 'lucide-react';
import { BlogSitePage } from './BlogSitePage';

export default function SiteCarriere() {
  return (
    <BlogSitePage
      siteId={4}
      color="#10B981"
      title="Nexytal Carrière"
      description="Articles et actualités pour le site carrière"
      icon={<Briefcase className="w-5 h-5" />}
    />
  );
}
