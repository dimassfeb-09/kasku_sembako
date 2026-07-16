import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { DashboardLayout } from './components/layout/DashboardLayout'
import { LoginPage } from './pages/Login'
import { DashboardPage } from './pages/Dashboard'
import { UsersPage } from './pages/Users'
import { SubscriptionsPage } from './pages/Subscriptions'
import { StoresPage } from './pages/Stores'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route element={<DashboardLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="subscriptions" element={<SubscriptionsPage />} />
          <Route path="stores" element={<StoresPage />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
