import { useState } from 'react'
import type { FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { login } from '../lib/api'

export function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await login(email, password)
      localStorage.setItem('token', res.token)
      navigate('/')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-[var(--color-background)] flex">
      {/* Left — brand panel */}
      <div className="hidden lg:flex w-1/2 bg-[var(--color-sidebar)] items-center justify-center relative overflow-hidden">
        <div className="absolute inset-0 opacity-[0.03]" style={{ backgroundImage: 'radial-gradient(circle at 25px 25px, white 1px, transparent 0)', backgroundSize: '50px 50px' }} />
        <div className="relative text-center px-12">
          <div className="w-16 h-16 rounded-2xl bg-[var(--color-sidebar-active)] flex items-center justify-center mx-auto mb-6">
            <i className="ri-database-2-line text-white text-2xl" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-3">Kasirku Admin</h1>
          <p className="text-[var(--color-sidebar-foreground)] text-sm max-w-sm mx-auto leading-relaxed">
            Monitor your users, subscriptions, stores, and analytics in one place.
          </p>
        </div>
      </div>

      {/* Right — form */}
      <div className="flex-1 flex items-center justify-center px-6">
        <div className="w-full max-w-sm">
          <div className="lg:hidden flex items-center gap-3 mb-8">
            <div className="w-10 h-10 rounded-xl bg-[var(--color-primary)] flex items-center justify-center">
              <i className="ri-database-2-line text-white text-lg" />
            </div>
            <div>
              <div className="font-semibold text-base">Kasirku Admin</div>
              <div className="text-xs text-[var(--color-muted-foreground)]">Admin Panel</div>
            </div>
          </div>

          <h2 className="text-2xl font-bold mb-1">Welcome back</h2>
          <p className="text-sm text-[var(--color-muted-foreground)] mb-8">Sign in to your admin account</p>

          {error && (
            <div className="mb-6 p-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm flex items-center gap-2">
              <i className="ri-error-warning-line" />
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-sm font-medium mb-1.5">Email</label>
              <div className="relative">
                <i className="ri-mail-line absolute left-3 top-1/2 -translate-y-1/2 text-[var(--color-muted-foreground)] text-sm" />
                <input
                  type="email" required value={email} onChange={e => setEmail(e.target.value)}
                  className="input pl-10" placeholder="admin@example.com"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1.5">Password</label>
              <div className="relative">
                <i className="ri-lock-line absolute left-3 top-1/2 -translate-y-1/2 text-[var(--color-muted-foreground)] text-sm" />
                <input
                  type="password" required value={password} onChange={e => setPassword(e.target.value)}
                  className="input pl-10" placeholder="Enter your password"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary w-full py-2.5 disabled:opacity-60"
            >
              {loading ? 'Signing in…' : 'Sign In'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
