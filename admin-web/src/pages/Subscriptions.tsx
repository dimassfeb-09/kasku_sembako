import { useEffect, useState } from 'react'
import { getSubscriptions } from '../lib/api'
import type { Subscription } from '../types'
import { useNavigate } from 'react-router-dom'

export function SubscriptionsPage() {
  const [subs, setSubs] = useState<Subscription[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    getSubscriptions().then(setSubs).catch(() => navigate('/login')).finally(() => setLoading(false))
  }, [navigate])

  const filtered = filter ? subs.filter(s => s.status === filter) : subs

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold">Subscriptions</h2>
          <p className="text-sm text-[var(--color-muted-foreground)] mt-0.5">{subs.length} total</p>
        </div>
        <div className="relative">
          <i className="ri-filter-3-line absolute left-3 top-1/2 -translate-y-1/2 text-[var(--color-muted-foreground)] text-sm pointer-events-none" />
          <select
            value={filter}
            onChange={e => setFilter(e.target.value)}
            className="select pl-9 min-w-[140px]"
          >
            <option value="">All statuses</option>
            <option value="active">Active</option>
            <option value="expired">Expired</option>
            <option value="canceled">Canceled</option>
            <option value="grace_period">Grace Period</option>
            <option value="on_hold">On Hold</option>
          </select>
        </div>
      </div>

      {loading ? (
        <div className="card p-8 text-center text-sm text-[var(--color-muted-foreground)]">Loading...</div>
      ) : (
        <div className="card overflow-hidden">
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>User ID</th>
                  <th>Product</th>
                  <th>Status</th>
                  <th>Expiry</th>
                  <th className="text-center">Ack</th>
                  <th>Created</th>
                </tr>
              </thead>
              <tbody>
                {filtered.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="text-center py-12 text-[var(--color-muted-foreground)]">
                      <i className="ri-inbox-line text-2xl block mb-2" />
                      No subscriptions found
                    </td>
                  </tr>
                ) : (
                  filtered.map(s => (
                    <tr key={s.id}>
                      <td>
                        <div className="flex items-center gap-2">
                          <i className="ri-user-line text-[var(--color-muted-foreground)]" />
                          <span className="text-xs font-mono text-[var(--color-muted-foreground)]">{s.userId.slice(0, 8)}...</span>
                        </div>
                      </td>
                      <td className="font-medium">{s.productId}</td>
                      <td>
                        <span className={'badge badge-' + s.status}>
                          {s.status === 'active' ? <i className="ri-checkbox-circle-line mr-1" /> : null}
                          {s.status.replace('_', ' ')}
                        </span>
                      </td>
                      <td className="text-[var(--color-muted-foreground)]">
                        {s.expiryTime ? (
                          <span className="flex items-center gap-1.5">
                            <i className="ri-calendar-line text-xs" />
                            {new Date(s.expiryTime).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}
                          </span>
                        ) : (
                          '\u2014'
                        )}
                      </td>
                      <td className="text-center">
                        {s.acknowledged ? (
                          <i className="ri-checkbox-circle-line text-emerald-500 text-lg" />
                        ) : (
                          <i className="ri-close-circle-line text-[var(--color-muted-foreground)] text-lg" />
                        )}
                      </td>
                      <td className="text-[var(--color-muted-foreground)]">
                        {new Date(s.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
