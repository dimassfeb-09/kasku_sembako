import { useEffect, useState } from 'react'
import { getStats, getSubscriptionSummary } from '../lib/api'
import type { Stats, SubscriptionSummary } from '../types'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

const metrics = [
  { key: 'totalUsers' as const, label: 'Total Users', icon: 'ri-group-line', color: 'bg-blue-500', light: 'bg-blue-50', text: 'text-blue-600' },
  { key: 'totalActiveSubscriptions' as const, label: 'Active Subscriptions', icon: 'ri-vip-crown-line', color: 'bg-emerald-500', light: 'bg-emerald-50', text: 'text-emerald-600' },
  { key: 'totalStores' as const, label: 'Total Stores', icon: 'ri-store-3-line', color: 'bg-violet-500', light: 'bg-violet-50', text: 'text-violet-600' },
  { key: 'totalBackups' as const, label: 'Total Backups', icon: 'ri-cloud-line', color: 'bg-amber-500', light: 'bg-amber-50', text: 'text-amber-600' },
]

export function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [summary, setSummary] = useState<SubscriptionSummary[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([getStats(), getSubscriptionSummary()])
      .then(([s, ss]) => { setStats(s); setSummary(ss) })
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])

  if (loading) {
    return (
      <div className="grid grid-cols-4 gap-5">
        {[1, 2, 3, 4].map(i => (
          <div key={i} className="card p-5 animate-pulse">
            <div className="w-10 h-10 rounded-xl bg-gray-200 mb-3" />
            <div className="h-8 w-20 bg-gray-200 rounded mb-1" />
            <div className="h-4 w-24 bg-gray-100 rounded" />
          </div>
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {metrics.map(m => {
          const val = stats?.[m.key] ?? 0
          return (
            <div key={m.key} className="card p-5 hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between mb-4">
                <div className={`w-10 h-10 rounded-xl ${m.light} flex items-center justify-center`}>
                  <i className={`${m.icon} ${m.text} text-lg`} />
                </div>
              </div>
              <div className="card-value">{val.toLocaleString()}</div>
              <div className="card-title mt-1">{m.label}</div>
            </div>
          )
        })}
      </div>

      {/* Chart + Summary */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <div className="lg:col-span-2 card p-5">
          <h3 className="font-semibold text-sm mb-4">Subscriptions by Status</h3>
          {summary.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={summary}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="name" tick={{ fontSize: 12, fill: '#94a3b8' }} />
                <YAxis tick={{ fontSize: 12, fill: '#94a3b8' }} />
                <Tooltip
                  contentStyle={{ borderRadius: 8, border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)' }}
                />
                <Bar dataKey="count" fill="#4f46e5" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-64 text-sm text-[var(--color-muted-foreground)]">
              No subscription data
            </div>
          )}
        </div>

        <div className="card p-5">
          <h3 className="font-semibold text-sm mb-4">Summary</h3>
          <div className="space-y-4">
            {summary.map(s => (
              <div key={s.status} className="flex items-center justify-between">
                <span className="text-sm capitalize text-[var(--color-secondary-foreground)]">{s.status.replace('_', ' ')}</span>
                <span className={`badge badge-${s.status} min-w-[2rem] text-center`}>
                  {s.count}
                </span>
              </div>
            ))}
            {summary.length === 0 && (
              <p className="text-sm text-[var(--color-muted-foreground)]">No subscriptions yet</p>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
