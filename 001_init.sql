-- 001_init.sql
-- Tables for Mi-Todo app (Supabase/Postgres)
-- Note: run as service_role or via Supabase SQL editor

create table if not exists tenants (
  id uuid primary key default gen_random_uuid(),
  name text,
  created_at timestamptz default now()
);

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  name text,
  tenant_id uuid references tenants(id),
  created_at timestamptz default now()
);

create table if not exists transactions (
  id text primary key,
  user_id uuid references users(id),
  tenant_id uuid references tenants(id),
  name text,
  amount numeric,
  type text,
  category text,
  date timestamptz,
  description text,
  currency text,
  created_at timestamptz default now()
);

create table if not exists meals (
  id text primary key,
  user_id uuid references users(id),
  tenant_id uuid references tenants(id),
  name text,
  calories int,
  proteins int,
  carbs int,
  fats int,
  photo_url text,
  date timestamptz,
  created_at timestamptz default now()
);

create table if not exists workouts (
  id text primary key,
  user_id uuid references users(id),
  tenant_id uuid references tenants(id),
  type text,
  duration_min int,
  calories_burned int,
  notes text,
  date timestamptz,
  created_at timestamptz default now()
);

create table if not exists habits (
  id text primary key,
  user_id uuid references users(id),
  tenant_id uuid references tenants(id),
  title text,
  frequency text,
  streak int default 0,
  done_dates jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

create table if not exists goals (
  id text primary key,
  user_id uuid references users(id),
  tenant_id uuid references tenants(id),
  title text,
  target_date timestamptz,
  progress int default 0,
  steps jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

-- Enable Row Level Security (RLS) and basic policies
-- You will need to adjust policies based on your auth setup.
-- Example RLS for transactions (users can access own rows):
alter table transactions enable row level security;
create policy "transactions_is_owner" on transactions for all using (auth.uid() = user_id::text);

-- Repeat similar policies for other tables as needed.
