import type { Stats, User, Subscription, SubscriptionSummary, Store } from '../types'

function token(): string | null {
  return localStorage.getItem('token')
}

export function isAuthenticated(): boolean {
  return !!token()
}

/** Carries the backend's machine-readable `code` alongside the message. */
export class ApiError extends Error {
  status: number
  code?: string

  constructor(status: number, message: string, code?: string) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.code = code
  }
}

/**
 * The backend errors with {"message","code"}. Kept tolerant of a non-JSON
 * body: a proxy or gateway failure can still return HTML or plain text.
 */
async function readError(res: Response): Promise<{ message: string; code?: string }> {
  try {
    const body = await res.json()
    return {
      message: typeof body?.message === 'string' ? body.message : res.statusText,
      code: typeof body?.code === 'string' ? body.code : undefined,
    }
  } catch {
    return { message: res.statusText || `HTTP ${res.status}` }
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  const t = token()
  if (t) headers['Authorization'] = `Bearer ${t}`

  const res = await fetch(path, { ...init, headers })
  if (!res.ok) {
    if (res.status === 401) localStorage.removeItem('token')
    const { message, code } = await readError(res)
    throw new ApiError(res.status, message, code)
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
