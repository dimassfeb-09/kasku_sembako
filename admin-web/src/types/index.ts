export interface Stats {
  totalUsers: number
  totalActiveSubscriptions: number
  totalBackups: number
  totalStores: number
  subscriptionsByStatus: Record<string, number>
}

export interface User {
  id: string
  email: string
  role: string
  createdAt: string
  subscriptionStatus: string
  subscriptionExpiry?: string
  backupCount: number
}

export interface Subscription {
  id: string
  userId: string
  productId: string
  status: string
  expiryTime?: string
  acknowledged: boolean
  createdAt: string
  updatedAt: string
}

export interface SubscriptionSummary {
  status: string
  count: number
}

export interface Store {
  id: string
  userId: string
  ownerName: string
  businessName: string
  businessCategory: string
  phone: string
  address: string
  createdAt: string
  updatedAt: string
}
