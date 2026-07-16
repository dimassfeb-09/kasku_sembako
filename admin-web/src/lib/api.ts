import type { Stats, User, Subscription, SubscriptionSummary, Store } from '../types'

function token(): string | null {
  return localStorage.getItem('token')
}

export function isAuthenticated(): boolean {
  return !!token()
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  const t = token()
  if (t) headers['Authorization'] = `Bearer ${t}`

  const res = await fetch(path, { ...init, headers })
  if (!res.ok) {
    if (res.status === 401) localStorage.removeItem('token')
    throw new Error(`${res.status}: ${await res.text()}`)
  }
  return res.json()
}

export function login(email: string, password: string) {
  return request<{ token: string; user: { id: string; email: string; role: string } }>(
    '/auth/login',
    { method: 'POST', body: JSON.stringify({ email, password }) }
  )
}

export function getStats() { return request<Stats>('/api/admin/stats') }
export function getUsers() { return request<User[]>('/api/admin/users') }
export function getSubscriptions() { return request<Subscription[]>('/api/admin/subscriptions') }
export function getSubscriptionSummary() { return request<SubscriptionSummary[]>('/api/admin/subscriptions/summary') }
export function getStores() { return request<Store[]>('/api/admin/stores') }
