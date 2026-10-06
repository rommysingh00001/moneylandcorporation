-- MONEYLAND VERIFIED — SUPABASE SCHEMA
-- Run this entire file in Supabase SQL Editor.
-- Never store raw Aadhaar numbers. Production Aadhaar authentication must be handled by a compliant identity provider.

create extension if not exists pgcrypto;

create type public.user_role as enum ('buyer','owner','admin');
create type public.property_status as enum ('draft','pending_verification','field_verification','approved','live','rejected','sold','rented');
create type public.deal_type as enum ('sale','rent','lease');
create type public.property_category as enum ('flat_apartment','builder_floor','independent_floor','villa','plot','commercial_shop','office_space','warehouse','showroom','industrial_property','independent_house','farm_house');
create type public.bid_status as enum ('pending','approved','rejected','withdrawn');
create type public.media_type as enum ('document','photo','video');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text unique,
  role public.user_role not null default 'buyer',
  is_identity_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.properties (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  category public.property_category not null,
  deal_type public.deal_type not null default 'sale',
  sector text not null,
  locality text,
  society_name text,
  tower_block text,
  floor text,
  unit_no text,
  bhk text,
  size_sqft numeric,
  plot_size_sqyd numeric,
  demand numeric not null,
  complete_address text not null,
  description text,
  rera_no text,
  owner_name_as_document text not null,
  property_record_name text,
  jamabandi_name text,
  owner_name_match boolean not null default false,
  document_match boolean not null default false,
  field_verified boolean not null default false,
  admin_approved boolean not null default false,
  status public.property_status not null default 'pending_verification',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.property_media (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete cascade,
  media_type public.media_type not null,
  storage_path text not null,
  sort_order int not null default 0,
  is_public boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.bids (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete cascade,
  buyer_id uuid not null references public.profiles(id) on delete restrict,
  amount numeric not null,
  message text,
  status public.bid_status not null default 'pending',
  owner_response text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.field_verifications (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties(id) on delete cascade,
  verifier_name text,
  remarks text,
  gps_lat double precision,
  gps_lng double precision,
  verified_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete set null,
  property_id uuid references public.properties(id) on delete set null,
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public
as $$ select exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'); $$;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$ begin insert into public.profiles(id, full_name) values(new.id, coalesce(new.raw_user_meta_data->>'full_name','')) on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists profiles_updated_at on public.profiles; create trigger profiles_updated_at before update on public.profiles for each row execute procedure public.set_updated_at();
drop trigger if exists properties_updated_at on public.properties; create trigger properties_updated_at before update on public.properties for each row execute procedure public.set_updated_at();
drop trigger if exists bids_updated_at on public.bids; create trigger bids_updated_at before update on public.bids for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.property_media enable row level security;
alter table public.bids enable row level security;
alter table public.field_verifications enable row level security;
alter table public.audit_logs enable row level security;

-- Profiles: user sees own profile; admin sees all.
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select using (id=auth.uid() or public.is_admin());
drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles for update using (id=auth.uid() or public.is_admin());

-- Public can see only approved/live listings. Owners/admins can see their own / all respectively.
drop policy if exists properties_public_select on public.properties;
create policy properties_public_select on public.properties for select using (status='live' or owner_id=auth.uid() or public.is_admin());
drop policy if exists properties_owner_insert on public.properties;
create policy properties_owner_insert on public.properties for insert with check (owner_id=auth.uid());
drop policy if exists properties_owner_update on public.properties;
create policy properties_owner_update on public.properties for update using (owner_id=auth.uid() or public.is_admin()) with check (owner_id=auth.uid() or public.is_admin());
drop policy if exists properties_admin_delete on public.properties;
create policy properties_admin_delete on public.properties for delete using (public.is_admin());

-- Media: public sees only public media attached to live property; owner/admin can see private media.
drop policy if exists media_select on public.property_media;
create policy media_select on public.property_media for select using (
  is_public and exists(select 1 from public.properties p where p.id=property_id and p.status='live')
  or exists(select 1 from public.properties p where p.id=property_id and p.owner_id=auth.uid())
  or public.is_admin()
);
drop policy if exists media_insert on public.property_media;
create policy media_insert on public.property_media for insert with check (exists(select 1 from public.properties p where p.id=property_id and (p.owner_id=auth.uid() or public.is_admin())));
drop policy if exists media_delete on public.property_media;
create policy media_delete on public.property_media for delete using (exists(select 1 from public.properties p where p.id=property_id and (p.owner_id=auth.uid() or public.is_admin())));

-- Bids: buyer creates; buyer sees own; property owner sees bids on own property; admin sees all.
drop policy if exists bids_select on public.bids;
create policy bids_select on public.bids for select using (buyer_id=auth.uid() or exists(select 1 from public.properties p where p.id=property_id and p.owner_id=auth.uid()) or public.is_admin());
drop policy if exists bids_insert on public.bids;
create policy bids_insert on public.bids for insert with check (buyer_id=auth.uid() and exists(select 1 from public.properties p where p.id=property_id and p.status='live'));
drop policy if exists bids_update on public.bids;
create policy bids_update on public.bids for update using (buyer_id=auth.uid() or exists(select 1 from public.properties p where p.id=property_id and p.owner_id=auth.uid()) or public.is_admin()) with check (buyer_id=auth.uid() or exists(select 1 from public.properties p where p.id=property_id and p.owner_id=auth.uid()) or public.is_admin());

-- Field verification and audit logs are admin-controlled.
drop policy if exists field_admin on public.field_verifications;
create policy field_admin on public.field_verifications for all using (public.is_admin()) with check (public.is_admin());
drop policy if exists audit_admin on public.audit_logs;
create policy audit_admin on public.audit_logs for all using (public.is_admin()) with check (public.is_admin());

-- Storage buckets. Property documents should remain private; photos/videos may be public only after approval.
insert into storage.buckets(id,name,public) values ('property-documents','property-documents',false) on conflict(id) do nothing;
insert into storage.buckets(id,name,public) values ('property-media','property-media',false) on conflict(id) do nothing;

-- These storage policies assume paths begin with the authenticated user's UUID.
drop policy if exists property_docs_owner on storage.objects;
create policy property_docs_owner on storage.objects for all to authenticated using (bucket_id='property-documents' and (owner=auth.uid() or public.is_admin())) with check (bucket_id='property-documents' and (owner=auth.uid() or public.is_admin()));
drop policy if exists property_media_owner on storage.objects;
create policy property_media_owner on storage.objects for all to authenticated using (bucket_id='property-media' and (owner=auth.uid() or public.is_admin())) with check (bucket_id='property-media' and (owner=auth.uid() or public.is_admin()));

-- IMPORTANT: The portal never exposes owner phone/email in public property data.
-- WhatsApp contact remains the Moneyland number: +91 8178593108.
