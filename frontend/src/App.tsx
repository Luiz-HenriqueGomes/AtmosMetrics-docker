import { useState, useEffect, Suspense, lazy } from 'react';
import Sidebar from './components/Sidebar';
import CustomCursor from './components/CustomCursor';
import { api } from './services/api';
import './App.css';

// Lazy loading — cada página só é carregada quando necessária.
const DashboardPage = lazy(() => import('./pages/DashboardPage'));
const FocosPage = lazy(() => import('./pages/FocosPage'));
const QualidadeArPage = lazy(() => import('./pages/QualidadeArPage'));
const LocalidadesPage = lazy(() => import('./pages/LocalidadesPage'));
const SatelitesPage = lazy(() => import('./pages/SatelitesPage'));
const ConfiguracoesPage = lazy(() => import('./pages/ConfiguracoesPage'));

function PageLoader() {
  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      height: '100%',
      color: 'var(--text-muted)',
      fontSize: '0.9rem',
      gap: '0.5rem',
    }}>
      <div style={{
        width: '20px',
        height: '20px',
        border: '2px solid var(--border)',
        borderTop: '2px solid var(--accent)',
        borderRadius: '50%',
        animation: 'spin 0.8s linear infinite',
      }} />
      Carregando...
    </div>
  );
}

export default function App() {
  const [activePage, setActivePage] = useState('dashboard');
  const [apiStatus, setApiStatus] = useState<'online' | 'offline' | 'loading'>('loading');
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  // Atualiza o atributo no DOM para o CSS global (Dark/Light Mode)
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  // Verifica o status da API ao iniciar
  useEffect(() => {
    api.getHealth()
      .then(data => setApiStatus(data.banco === 'conectado' ? 'online' : 'offline'))
      .catch(() => setApiStatus('offline'));
  }, []);

  const toggleTheme = () => setTheme(prev => prev === 'light' ? 'dark' : 'light');

  const renderPage = () => {
    switch (activePage) {
      case 'dashboard':     return <DashboardPage />;
      case 'anomalias':     return <FocosPage />;
      case 'qualidade_ar':  return <QualidadeArPage />;
      case 'localidades':   return <LocalidadesPage />;
      case 'satelites':     return <SatelitesPage />;
      case 'configuracoes': return <ConfiguracoesPage />;
      default:
        return (
          <div style={{ color: 'var(--text-secondary)', padding: '2rem', textAlign: 'center' }}>
            <p>🚧 Página "<strong>{activePage}</strong>" em construção.</p>
          </div>
        );
    }
  };

  return (
    <div className="app-layout">
      <CustomCursor />
      <Sidebar
        activePage={activePage}
        onNavigate={setActivePage}
        apiStatus={apiStatus}
        theme={theme}
        toggleTheme={toggleTheme}
      />
      <main className="app-main">
        <div
          key={activePage}
          className="page-transition"
          style={{ width: '100%', height: '100%' }}
        >
          <Suspense fallback={<PageLoader />}>
            {renderPage()}
          </Suspense>
        </div>
      </main>
    </div>
  );
}
