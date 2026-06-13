import React, { Component, type ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          height: '100vh',
          background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
          color: '#e2e8f0',
          fontFamily: 'Inter, system-ui, sans-serif',
          textAlign: 'center',
          padding: '2rem',
        }}>
          <h1 style={{ fontSize: '2rem', marginBottom: '1rem', color: '#f87171' }}>
            ⚠️ Algo deu errado
          </h1>
          <p style={{ fontSize: '1.1rem', marginBottom: '1.5rem', opacity: 0.8 }}>
            Ocorreu um erro inesperado na aplicação.
          </p>
          <p style={{ fontSize: '0.85rem', marginBottom: '2rem', opacity: 0.5, maxWidth: '500px' }}>
            {this.state.error?.message}
          </p>
          <button
            onClick={() => window.location.reload()}
            style={{
              padding: '0.75rem 2rem',
              borderRadius: '0.5rem',
              border: 'none',
              background: '#3b82f6',
              color: '#fff',
              fontSize: '1rem',
              cursor: 'pointer',
            }}
          >
            Recarregar Página
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
