import { useEffect, useState } from 'react';
import { type LucideIcon } from 'lucide-react';
import './StatCard.css';

interface StatCardProps {
  label: string;
  value: string | number;
  sub?: string;
  icon: LucideIcon;
  accent?: string;       // cor CSS var ou hex
  iconBg?: string;
  cardGlow?: string;
  loading?: boolean;
}

export default function StatCard({
  label,
  value,
  sub,
  icon: Icon,
  accent = 'var(--accent)',
  iconBg = 'rgba(59,130,246,0.1)',
  cardGlow,
  loading = false,
}: StatCardProps) {
  const [displayValue, setDisplayValue] = useState<string | number>(0);

  useEffect(() => {
    if (!loading && typeof value === 'number') {
      // Animação simples sem framer-motion animate()
      const startTime = performance.now();
      const duration = 1200;
      const startVal = 0;
      const endVal = value;

      const step = (currentTime: number) => {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        // easeOut
        const eased = 1 - Math.pow(1 - progress, 3);
        setDisplayValue(Math.floor(startVal + (endVal - startVal) * eased));
        if (progress < 1) {
          requestAnimationFrame(step);
        }
      };
      requestAnimationFrame(step);
    } else if (!loading) {
      setDisplayValue(value);
    }
  }, [value, loading]);

  return (
    <div
      className="stat-card"
      style={{
        '--card-accent': accent,
        '--card-icon-bg': iconBg,
        '--card-glow': cardGlow,
      } as React.CSSProperties}
    >
      <div className="stat-card-bar" />

      <div className="stat-card-header">
        <span className="stat-card-label">{label}</span>
        <div className="stat-card-icon">
          <Icon size={16} />
        </div>
      </div>

      <div className={`stat-card-value ${loading ? 'loading' : ''}`}>
        {!loading && String(typeof value === 'number' ? (displayValue as number).toLocaleString('pt-BR') : displayValue)}
      </div>

      {sub && (
        <div className="stat-card-sub">
          {sub}
        </div>
      )}
    </div>
  );
}
