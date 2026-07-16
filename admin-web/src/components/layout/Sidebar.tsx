import { NavLink, useNavigate } from 'react-router-dom'

const nav = [
  { to: '/', label: 'Dashboard', icon: 'ri-dashboard-3-line' },
  { to: '/users', label: 'Users', icon: 'ri-group-line' },
  { to: '/subscriptions', label: 'Subscriptions', icon: 'ri-vip-crown-line' },
  { to: '/stores', label: 'Stores', icon: 'ri-store-3-line' },
]

export function Sidebar() {
  const navigate = useNavigate()

  const handleLogout = () => {
    localStorage.removeItem('token')
    navigate('/login')
  }

  return (
    <aside className="w-64 min-h-screen bg-[var(--color-sidebar)] flex flex-col">
      {/* Logo */}
      <div className="h-16 flex items-center gap-3 px-6 border-b border-white/10">
        <div className="w-8 h-8 rounded-lg bg-[var(--color-sidebar-active)] flex items-center justify-center">
          <i className="ri-database-2-line text-white text-sm" />
        </div>
        <div>
          <div className="text-white font-semibold text-sm leading-tight">Kasirku</div>
          <div className="text-[var(--color-sidebar-foreground)] text-xs">Admin Panel</div>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-1">
        {nav.map(item => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === '/'}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                isActive
                  ? 'bg-[var(--color-sidebar-active)] text-white shadow-sm'
                  : 'text-[var(--color-sidebar-foreground)] hover:bg-white/5 hover:text-white'
              }`
            }
          >
            <i className={`${item.icon} text-lg`} />
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* Logout */}
      <div className="px-3 pb-4 border-t border-white/10 pt-4">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-[var(--color-sidebar-foreground)] hover:bg-white/5 hover:text-white w-full transition-all"
        >
          <i className="ri-logout-box-r-line text-lg" />
          Sign Out
        </button>
      </div>
    </aside>
  )
}
