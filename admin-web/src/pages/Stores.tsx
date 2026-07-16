import { useEffect, useState } from 'react'
import { getStores } from '../lib/api'
import type { Store } from '../types'
import { useNavigate } from 'react-router-dom'

export function StoresPage() {
  const [stores, setStores] = useState<Store[]>([])
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    getStores().then(setStores).catch(() => navigate('/login')).finally(() => setLoading(false))
  }, [navigate])

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-xl font-bold">Stores</h2>
        <p className="text-sm text-[var(--color-muted-foreground)] mt-0.5">{stores.length} registered stores</p>
      </div>

      {loading ? (
        <div className="card p-8 text-center text-sm text-[var(--color-muted-foreground)]">Loading…</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
          {stores.map(s => (
            <div key={s.id} className="card p-5 hover:shadow-md transition-shadow">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center">
                  <i className="ri-store-3-line text-amber-600 text-lg" />
                </div>
                <div className="min-w-0">
                  <div className="font-semibold text-sm truncate">{s.businessName || 'Unnamed Store'}</div>
                  <div className="text-xs text-[var(--color-muted-foreground)]">{s.ownerName || 'No owner'}</div>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                {s.businessCategory && (
                  <div className="flex items-center gap-2 text-[var(--color-secondary-foreground)]">
                    <i className="ri-price-tag-3-line text-[var(--color-muted-foreground)] text-xs w-4" />
                    {s.businessCategory}
                  </div>
                )}
                {s.phone && (
                  <div className="flex items-center gap-2 text-[var(--color-secondary-foreground)]">
                    <i className="ri-phone-line text-[var(--color-muted-foreground)] text-xs w-4" />
                    {s.phone}
                  </div>
                )}
                {s.address && (
                  <div className="flex items-start gap-2 text-[var(--color-secondary-foreground)]">
                    <i className="ri-map-pin-line text-[var(--color-muted-foreground)] text-xs w-4 mt-0.5" />
                    <span className="truncate">{s.address}</span>
                  </div>
                )}
              </div>

              <div className="mt-4 pt-3 border-t border-[var(--color-border)] text-xs text-[var(--color-muted-foreground)] flex items-center gap-1.5">
                <i className="ri-calendar-line" />
                Joined {new Date(s.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })}
              </div>
            </div>
          ))}
          {stores.length === 0 && (
            <div className="card p-12 text-center text-[var(--color-muted-foreground)] col-span-full">
              <i className="ri-store-3-line text-3xl block mb-2" />
              No stores registered yet
            </div>
          )}
        </div>
      )}
    </div>
  )
}
