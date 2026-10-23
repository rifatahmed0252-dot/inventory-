-- Thai Glass Inventory: initial Supabase schema draft
-- Review and run in Supabase SQL Editor only after creating your project.
create extension if not exists pgcrypto;

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Thai Glass Inventory',
  currency text not null default 'BDT' check (currency = 'BDT'),
  default_language text not null default 'bn' check (default_language in ('bn','en')),
  created_at timestamptz not null default now()
);

create table if not exists public.business_members (
  business_id uuid not null references public.businesses(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','manager','employee')),
  created_at timestamptz not null default now(),
  primary key (business_id, user_id)
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  unique (business_id, name)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  sku text,
  name text not null,
  category_id uuid references public.categories(id) on delete set null,
  unit text not null,
  length_ft numeric(12,3),
  purchase_price numeric(14,2) not null default 0 check (purchase_price >= 0),
  selling_price numeric(14,2) not null default 0 check (selling_price >= 0),
  low_stock_threshold numeric(14,3) not null default 0 check (low_stock_threshold >= 0),
  is_active boolean not null default true,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  product_id uuid not null references public.products(id),
  movement_type text not null check (movement_type in ('opening','purchase','sale','adjustment_in','adjustment_out','return_in','return_out')),
  quantity_delta numeric(14,3) not null check (quantity_delta <> 0),
  unit_cost numeric(14,2) not null default 0,
  reference_type text,
  reference_id uuid,
  note text,
  created_by uuid references auth.users(id),
  device_id text,
  created_at timestamptz not null default now(),
  client_created_at timestamptz
);

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  invoice_number text,
  supplier_name text,
  total_amount numeric(14,2) not null default 0,
  status text not null default 'posted' check (status in ('draft','posted','void')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.purchase_items (
  id uuid primary key default gen_random_uuid(),
  purchase_id uuid not null references public.purchases(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity numeric(14,3) not null check (quantity > 0),
  unit_cost numeric(14,2) not null check (unit_cost >= 0),
  line_total numeric(14,2) not null check (line_total >= 0)
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  invoice_number text not null,
  customer_name text,
  total_amount numeric(14,2) not null default 0,
  status text not null default 'posted' check (status in ('draft','posted','void')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  unique (business_id, invoice_number)
);

create table if not exists public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  product_id uuid not null references public.products(id),
  product_name_snapshot text not null,
  quantity numeric(14,3) not null check (quantity > 0),
  unit_price numeric(14,2) not null check (unit_price >= 0),
  unit_cost_snapshot numeric(14,2) not null default 0,
  line_total numeric(14,2) not null check (line_total >= 0)
);

create table if not exists public.price_history (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  product_id uuid not null references public.products(id),
  old_purchase_price numeric(14,2),
  new_purchase_price numeric(14,2),
  old_selling_price numeric(14,2),
  new_selling_price numeric(14,2),
  changed_by uuid references auth.users(id),
  changed_at timestamptz not null default now()
);

create index if not exists products_business_idx on public.products(business_id);
create index if not exists movements_business_date_idx on public.stock_movements(business_id, created_at desc);
create index if not exists sales_business_date_idx on public.sales(business_id, created_at desc);

-- IMPORTANT before production:
-- Enable RLS on every table, add policies scoped to business_members,
-- and perform stock validation + sale posting in a database transaction/RPC.
-- Never expose a service_role key in browser code.
