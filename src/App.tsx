import { Toaster } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { Route, Switch, Redirect } from "wouter";
import ErrorBoundary from "./components/ErrorBoundary";
import { ThemeProvider } from "./contexts/ThemeContext";
import { AppProvider, useApp } from "./contexts/AppContext";
import DashboardLayout from "./components/DashboardLayout";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import SiteFormation from "./pages/SiteFormation";
import SiteMedical from "./pages/SiteMedical";
import SiteRecrutement from "./pages/SiteRecrutement";
import SiteCarriere from "./pages/SiteCarriere";
import SiteCoaching from "./pages/SiteCoaching";
import SiteTrainer from "./pages/SiteTrainer";
import UsersPage from "./pages/UsersPage";
import SettingsPage from "./pages/SettingsPage";
import NotFound from "./pages/NotFound";

function ProtectedRoute({ component: Component, adminOnly = false }: { component: React.ComponentType; adminOnly?: boolean }) {
  const { currentUser } = useApp();
  if (!currentUser) return <Redirect to="/login" />;
  if (adminOnly && currentUser.role !== 'superadmin') return <Redirect to="/dashboard" />;
  return (
    <DashboardLayout>
      <Component />
    </DashboardLayout>
  );
}

function LoginRoute() {
  const { currentUser } = useApp();
  if (currentUser) return <Redirect to="/dashboard" />;
  return <Login />;
}

function Router() {
  return (
    <Switch>
      <Route path="/login" component={LoginRoute} />
      <Route path="/">
        <Redirect to="/login" />
      </Route>
      <Route path="/dashboard">
        <ProtectedRoute component={Dashboard} />
      </Route>
      <Route path="/formation">
        <ProtectedRoute component={SiteFormation} />
      </Route>
      <Route path="/medical">
        <ProtectedRoute component={SiteMedical} />
      </Route>
      <Route path="/recrutement">
        <ProtectedRoute component={SiteRecrutement} />
      </Route>
      <Route path="/carriere">
        <ProtectedRoute component={SiteCarriere} />
      </Route>
      <Route path="/coaching">
        <ProtectedRoute component={SiteCoaching} />
      </Route>
      <Route path="/trainer">
        <ProtectedRoute component={SiteTrainer} />
      </Route>
      <Route path="/users">
        <ProtectedRoute component={UsersPage} adminOnly />
      </Route>
      <Route path="/settings">
        <ProtectedRoute component={SettingsPage} />
      </Route>
      <Route component={NotFound} />
    </Switch>
  );
}

function App() {
  return (
    <ErrorBoundary>
      <ThemeProvider defaultTheme="light">
        <AppProvider>
          <TooltipProvider>
            <Toaster richColors position="top-right" />
            <Router />
          </TooltipProvider>
        </AppProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}

export default App;
