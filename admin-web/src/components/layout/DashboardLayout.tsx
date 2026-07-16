import { Outlet, useNavigate } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { isAuthenticated } from '../../lib/api'
import { useEffect, useState } from 'react'

export function DashboardLayout() {
  const navigate = useNavigate()
  const [authed, setAuthed] = useState(isAuthenticated())

  useEffect(() => {
    if (!isAuthenticated()) { navigate('/login', { replace: true }); return }
    setAuthed(true)
  }, [navigate])

  if (!authed) return null

  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col min-h-screen">
        <header className="h-16 bg-white border-b border-[var(--color-border)] flex items-center justify-between px-6 sticky top-0 z-10">
          <h2 className="text-lg font-semibold text-[var(--color-foreground)]">Overview</h2>
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[var(--color-primary-light)] flex items-center justify-center">
              <i className="ri-user-line text-sm text-[var(--color-primary)]" />
            </div>
          </div>
        </header>
        <main className="flex-1 p-6 overflow-auto">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
