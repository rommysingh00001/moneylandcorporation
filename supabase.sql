-- Moneyland Corporation production database blueprint
-- Run in Supabase SQL editor, then configure Storage buckets and Supabase Auth.
create extension if not exists pgcrypto;

create type public.property_status as enum ('draft','pending_verification','verified','rejected','sold','rented','archived');
create type public.property_category as enum ('Residential Flat','Luxury Floor / Builder Floor','Villa','Plot / Residential Land','Retail Shop','Showroom','Food Court','Office Space','Industrial Land','Agricultural Land','Farmhouse','Warehouse','PG / Rental','Commercial Property','Other');
create type public.bid_type as enum ('rent','buy');
create type public.bid_status as enum ('pending','approved','rejected','withdrawn','accepted');

create table if not exists public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 phone text,
 role text not null default 'buyer' check(role in ('buyer','owner','admin')),
 verification_status text not null default 'unverified' check(verification_status in ('unverified','pending','verified','rejected')),
 verification_provider text,
 verification_reference text,
 verification_last4 text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists public.locations(
 id uuid primary key default gen_random_uuid(),
 name text not null unique,
 kind text not null default 'locality',
 parent_name text,
 latitude double precision,
 longitude double precision,
 description text,
 is_active boolean not null default true,
 created_at timestamptz not null default now()
);

create table if not exists public.projects(
 id uuid primary key default gen_random_uuid(),
 name text not null unique,
 developer text,
 category text,
 location_id uuid references public.locations(id),
 location_text text not null,
 total_land_size text,
 total_towers text,
 building_height text,
 unit_sizes text,
 tentative_costing text,
 brief text,
 hero_image_path text,
 is_active boolean not null default true,
 is_featured boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists public.properties(
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references public.profiles(id),
 title text not null,
 category public.property_category not null,
 location_id uuid references public.locations(id),
 location_text text not null,
 project_name text,
 tower_no text,
 unit_no text,
 floor_no text,
 size_text text,
 demand numeric,
 bedrooms int,
 bathrooms int,
 parking text,
 facing text,
 possession_text text,
 description text,
 latitude double precision,
 longitude double precision,
 status public.property_status not null default 'pending_verification',
 is_featured boolean not null default false,
 public_listing_key text unique,
 verification_notes text,
 verified_by uuid references public.profiles(id),
 verified_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists public.property_media(
 id uuid primary key default gen_random_uuid(),
 property_id uuid not null references public.properties(id) on delete cascade,
 storage_path text not null,
 media_type text not null check(media_type in ('image','video','document')),
 sort_order int not null default 0,
 is_public boolean not null default false,
 created_at timestamptz not null default now()
);

create table if not exists public.inquiries(
 id uuid primary key default gen_random_uuid(),
 property_id uuid references public.properties(id),
 user_id uuid references public.profiles(id),
 name text,
 phone text,
 message text,
 source text default 'website',
 created_at timestamptz not null default now()
);

create table if not exists public.bids(
 id uuid primary key default gen_random_uuid(),
 property_id uuid not null references public.properties(id),
 bidder_id uuid not null references public.profiles(id),
 bid_type public.bid_type not null,
 offer_amount numeric not null,
 security_deposit numeric not null,
 deposit_payment_id text,
 status public.bid_status not null default 'pending',
 owner_note text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions(
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(id),
 plan_name text not null default 'Lifetime Brokerage-Free',
 amount numeric not null default 100000,
 payment_id text,
 status text not null default 'pending' check(status in ('pending','active','expired','refunded','cancelled')),
 starts_at timestamptz,
 ends_at timestamptz,
 created_at timestamptz not null default now()
);

create table if not exists public.hero_slides(
 id uuid primary key default gen_random_uuid(),
 title text not null,
 subtitle text,
 image_path text,
 property_id uuid references public.properties(id),
 sort_order int not null default 0,
 is_active boolean not null default true,
 created_at timestamptz not null default now()
);

create table if not exists public.branding_assets(
 id uuid primary key default gen_random_uuid(),
 name text not null unique,
 storage_path text not null,
 is_active boolean not null default true,
 created_at timestamptz not null default now()
);

create table if not exists public.builder_partners(
 id uuid primary key default gen_random_uuid(),
 name text not null unique,
 logo_path text,
 website text,
 note text,
 is_active boolean not null default true,
 sort_order int not null default 0
);

-- Prevent duplicate public listings for the same property identity once verified.
create unique index if not exists one_verified_public_listing_per_property
on public.properties(owner_id, lower(coalesce(project_name,'')), lower(coalesce(unit_no,'')), lower(location_text))
where status in ('pending_verification','verified');

alter table public.profiles enable row level security;
alter table public.locations enable row level security;
alter table public.projects enable row level security;
alter table public.properties enable row level security;
alter table public.property_media enable row level security;
alter table public.inquiries enable row level security;
alter table public.bids enable row level security;
alter table public.subscriptions enable row level security;
alter table public.hero_slides enable row level security;
alter table public.builder_partners enable row level security;
alter table public.branding_assets enable row level security;

-- Public can read active locations, active projects, verified properties, active hero slides, branding and partners.
create policy "public read active branding" on public.branding_assets for select using(is_active=true);
create policy "public read active locations" on public.locations for select using(is_active=true);
create policy "public read active projects" on public.projects for select using(is_active=true);
create policy "public read verified properties" on public.properties for select using(status='verified');
create policy "public read public media" on public.property_media for select using(is_public=true);
create policy "public read active heroes" on public.hero_slides for select using(is_active=true);
create policy "public read active partners" on public.builder_partners for select using(is_active=true);

-- Signed-in users may manage their own profile and create submissions/inquiries/bids.
create policy "profile self" on public.profiles for all using(auth.uid()=id) with check(auth.uid()=id);
create policy "owner creates property" on public.properties for insert with check(owner_id=auth.uid());
create policy "owner reads own property" on public.properties for select using(owner_id=auth.uid() or status='verified');
create policy "owner updates own unverified property" on public.properties for update using(owner_id=auth.uid() and status in ('draft','pending_verification')) with check(owner_id=auth.uid());
create policy "user creates inquiry" on public.inquiries for insert with check(user_id=auth.uid() or user_id is null);
create policy "user creates bid" on public.bids for insert with check(bidder_id=auth.uid());
create policy "bidder reads own bid" on public.bids for select using(bidder_id=auth.uid());
create policy "user reads own subscription" on public.subscriptions for select using(user_id=auth.uid());

-- Admin policies should be implemented using a server-side role claim / admin table or Supabase custom claims.
-- Do not make admin privileges public in browser code.

-- Storage buckets (create through Dashboard if these statements are unavailable in your project):
-- property-media (private by default)
-- property-documents (private)
-- branding (public read, admin write)
-- project-media (public read, admin write)

insert into public.builder_partners(name,sort_order) values
('DLF','1'),('M3M','2'),('Emaar India','3'),('Godrej Properties','4'),('Signature Global','5'),('Smartworld Developers','6'),('Whiteland Corporation','7'),('Elan Group','8'),('Tulip Infratech','9'),('AIPL','10'),('BPTP','11'),('ATS Infrastructure','12'),('Hero Realty','13'),('Ashiana Housing','14'),('Conscient','15'),('Spaze Group','16'),('Paras Buildtech','17'),('Pioneer Urban','18'),('ROF Group','19'),('Suncity Projects','20'),('Bestech Group','21'),('Reach Group','22'),('Ireo','23') on conflict(name) do nothing;
