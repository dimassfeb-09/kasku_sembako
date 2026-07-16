import { useEffect, useState } from 'react'
import { getUsers } from '../lib/api'
import type { User } from '../types'
import { useNavigate } from 'react-router-dom'

export function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    getUsers().then(setUsers).catch(() => navigate('/login')).finally(() => setLoading(false))
  }, [navigate])

  const filtered = users.filter(u => u.email.toLowerCase().includes(search.toLowerCase()))

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold">Users</h2>
          <p className="text-sm text-[var(--color-muted-foreground)] mt-0.5">{users.length} total users</p>
        </div>
        <div className="relative">
          <i className="ri-search-line absolute left-3 top-1/2 -translate-y-1/2 text-[var(--color-muted-foreground)] text-sm" />
          <input
            type="text" placeholder="Search by email…" value={search} onChange={e => setSearch(e.target.value)}
            className="input pl-9 w-64"
          />
        </div>
      </div>

      {/* Table */}
      {loading ? (
        <div className="card p-8 text-center text-sm text-[var(--color-muted-foreground)]">Loading…</div>
      ) : (
        <div className="card overflow-hidden">
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Joined</th>
                  <th>Subscription</th>
                  <th className="text-right">Backups</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(u => (
                  <tr key={u.id}>
                    <td>
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-full bg-[var(--color-primary-light)] flex items-center justify-center text-xs font-medium text-[var(--color-primary)]">
                          {u.email.charAt(0).toUpperCase()}
                        </div>
                        <span className="font-medium">{u.email}</span>
                      </div>
                    </td>
                    <td>
                      <span className={`badge ${u.role === 'admin' ? 'badge-admin' : 'badge-user'}`}>
                        {u.role === 'admin' && <i className="ri-shield-user-line mr-1" />}
                        {u.role}
                      </span>
                    </td>
                    <td className="text-[var(--color-muted-foreground)]">{new Date(u.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}</td>
                    <td>
                      {u.subscriptionStatus ? (
                        <span className={`badge badge-${u.subscriptionStatus}`}>
                          {u.subscriptionStatus.replace('_', ' ')}
                        </span>
                      ) : (
                        <span className="text-[var(--color-muted-foreground)] text-sm">—</span>
                      )}
                    </td>
                    <td className="text-right">
                      <span className="font-medium">{u.backupCount}</span>
                    </td>
                  </tr>
                ))}
                {filtered.length === 0 && (
                  <tr>
                    <td colSpan={5} className="text-center py-12 text-[var(--color-muted-foreground)]">
                      <i className="ri-user-search-line text-2xl block mb-2" />
                      No users found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
