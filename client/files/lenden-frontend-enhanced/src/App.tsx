import React from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import { StoreProvider, useStore } from './context/Store';
import { LoginScreen } from './pages/Login';
import { SignupScreen } from './pages/Signup';
import { ForgotPasswordScreen } from './pages/ForgotPassword';
import { DashboardScreen } from './pages/Dashboard';
import { ProductsScreen } from './pages/Products';
import { POSScreen } from './pages/POS';
import { CustomersScreen } from './pages/Customers';
import { TransactionsScreen } from './pages/Transactions';
import { ExpensesScreen } from './pages/Expenses';
import { TripsScreen } from './pages/Trips';

import ShopSelector from './pages/ShopSelector';

const Reports = React.lazy(() => import('./pages/Reports').then(m => ({ default: m.ReportsScreen })));
const Staff = React.lazy(() => import('./pages/Staff'));
const Settings = React.lazy(() => import('./pages/Settings').then(m => ({ default: m.SettingsScreen })));

const ProtectedRoute = ({ children, requireShop = true }: { children: React.ReactNode, requireShop?: boolean }) => {
    const { user } = useStore();
    const currentShop = localStorage.getItem('currentShop');

    if (!user) {
        return <Navigate to="/" replace />;
    }

    if (requireShop && !currentShop) {
        return <Navigate to="/select-shop" replace />;
    }

    return <>{children}</>;
};

const AppRoutes = () => {
    return (
        <Routes>
            <Route path="/" element={<LoginScreen />} />
            <Route path="/signup" element={<SignupScreen />} />
            <Route path="/forgot-password" element={<ForgotPasswordScreen />} />

            {/* Protected Routes */}
            <Route path="/select-shop" element={
                <ProtectedRoute requireShop={false}>
                    <ShopSelector />
                </ProtectedRoute>
            } />

            <Route path="/dashboard" element={<ProtectedRoute><DashboardScreen /></ProtectedRoute>} />
            <Route path="/products" element={<ProtectedRoute><ProductsScreen /></ProtectedRoute>} />
            <Route path="/pos" element={<ProtectedRoute><POSScreen /></ProtectedRoute>} />
            <Route path="/customers" element={<ProtectedRoute><CustomersScreen /></ProtectedRoute>} />
            <Route path="/reports" element={<ProtectedRoute><Reports /></ProtectedRoute>} />
            <Route path="/transactions" element={<ProtectedRoute><TransactionsScreen /></ProtectedRoute>} />
            <Route path="/expenses" element={<ProtectedRoute><ExpensesScreen /></ProtectedRoute>} />
            <Route path="/trips" element={<ProtectedRoute><TripsScreen /></ProtectedRoute>} />
            <Route path="/staff" element={<ProtectedRoute><Staff /></ProtectedRoute>} />
            <Route path="/settings" element={<ProtectedRoute><Settings /></ProtectedRoute>} />
        </Routes>
    );
}

const App: React.FC = () => {
    return (
        <StoreProvider>
            <HashRouter>
                <AppRoutes />
            </HashRouter>
        </StoreProvider>
    );
};

export default App;