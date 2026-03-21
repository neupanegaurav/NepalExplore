create table if not exists public.tourist_spots (
  id text primary key,
  name text not null,
  description text not null,
  latitude double precision not null,
  longitude double precision not null,
  category text not null,
  image_url text not null,
  user_images jsonb not null default '[]'::jsonb,
  status text not null default 'approved',
  price_range text null,
  contact_name text null,
  contact_phone text null,
  contact_email text null,
  promotional_message text null,
  promotion_tier text null,
  is_featured boolean not null default false,
  submission_kind text not null default 'spot',
  submitted_by uuid null references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null
);

alter table public.tourist_spots
  add column if not exists contact_name text null,
  add column if not exists promotion_tier text null,
  add column if not exists submission_kind text not null default 'spot',
  add column if not exists submitted_by uuid null references auth.users (id) on delete set null,
  add column if not exists created_at timestamptz not null default now();

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'tourist_spots_submission_kind_check'
  ) then
    alter table public.tourist_spots
      add constraint tourist_spots_submission_kind_check
      check (submission_kind in ('spot', 'business'));
  end if;
end $$;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists tourist_spots_status_idx
on public.tourist_spots (status);

create index if not exists tourist_spots_category_idx
on public.tourist_spots (category);

create index if not exists tourist_spots_deleted_at_idx
on public.tourist_spots (deleted_at);

create index if not exists tourist_spots_submission_kind_idx
on public.tourist_spots (submission_kind);

create index if not exists tourist_spots_submitted_by_idx
on public.tourist_spots (submitted_by);

create or replace function public.set_tourist_spots_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists tourist_spots_set_updated_at on public.tourist_spots;

create trigger tourist_spots_set_updated_at
before update on public.tourist_spots
for each row
execute function public.set_tourist_spots_updated_at();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid()
      and is_active = true
  );
$$;

alter table public.tourist_spots enable row level security;
alter table public.admin_users enable row level security;

drop policy if exists "Public can read tourist spots" on public.tourist_spots;
drop policy if exists "Public can read approved tourist spots" on public.tourist_spots;
drop policy if exists "Public can submit pending tourist spots" on public.tourist_spots;
drop policy if exists "Admins can read all tourist spots" on public.tourist_spots;
drop policy if exists "Admins can insert tourist spots" on public.tourist_spots;
drop policy if exists "Admins can update tourist spots" on public.tourist_spots;
drop policy if exists "Admins can delete tourist spots" on public.tourist_spots;
drop policy if exists "Admins can read their own admin profile" on public.admin_users;

create policy "Admins can read their own admin profile"
on public.admin_users
for select
to authenticated
using (user_id = auth.uid());

create policy "Public can read approved tourist spots"
on public.tourist_spots
for select
to anon, authenticated
using (
  deleted_at is null
  and status = 'approved'
);

create policy "Public can submit pending tourist spots"
on public.tourist_spots
for insert
to anon, authenticated
with check (
  deleted_at is null
  and status = 'pending'
  and is_featured = false
  and submission_kind in ('spot', 'business')
  and submitted_by is not distinct from auth.uid()
);

create policy "Admins can read all tourist spots"
on public.tourist_spots
for select
to authenticated
using (public.is_admin());

create policy "Admins can insert tourist spots"
on public.tourist_spots
for insert
to authenticated
with check (public.is_admin());

create policy "Admins can update tourist spots"
on public.tourist_spots
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "Admins can delete tourist spots"
on public.tourist_spots
for delete
to authenticated
using (public.is_admin());

insert into storage.buckets (id, name, public)
values ('spot-images', 'spot-images', true)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "Public can view spot images" on storage.objects;
drop policy if exists "Public can upload spot images" on storage.objects;
drop policy if exists "Admins can delete spot images" on storage.objects;

create policy "Public can view spot images"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'spot-images');

create policy "Public can upload spot images"
on storage.objects
for insert
to anon, authenticated
with check (bucket_id = 'spot-images');

create policy "Admins can delete spot images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'spot-images'
  and public.is_admin()
);

notify pgrst, 'reload schema';
