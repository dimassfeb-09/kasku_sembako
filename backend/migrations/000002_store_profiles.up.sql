CREATE TABLE store_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id),
    owner_name TEXT NOT NULL DEFAULT '',
    business_name TEXT NOT NULL DEFAULT '',
    business_category TEXT NOT NULL DEFAULT '',
    phone TEXT NOT NULL DEFAULT '',
    address TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
