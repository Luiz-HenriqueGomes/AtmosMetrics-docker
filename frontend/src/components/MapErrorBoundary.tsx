import { Component, type ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallbackHeight?: string;
}

interface State {
  hasError: boolean;
}

/**
 * ErrorBoundary específico para o mapa Leaflet.
 * Se o react-leaflet crashar (incompatibilidade com React 19),
 * mostra um fallback ao invés de derrubar a página inteira.
 */
class MapErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  componentDidCatch(error: Error) {
    console.warn('MapErrorBoundary: Leaflet map failed to render', error);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          height: this.props.fallbackHeight || '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #1e293b, #0f172a)',
          borderRadius: '0.75rem',
          color: '#94a3b8',
          gap: '0.75rem',
          fontSize: '0.9rem',
        }}>
          <span style={{ fontSize: '2rem' }}>🗺️</span>
          <span>O mapa não pôde ser carregado neste navegador.</span>
          <span style={{ fontSize: '0.75rem', opacity: 0.6 }}>
            Os dados continuam disponíveis nos rankings abaixo.
          </span>
        </div>
      );
    }

    return this.props.children;
  }
}

export default MapErrorBoundary;
