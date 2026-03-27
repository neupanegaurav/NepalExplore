# Supabase Setup

## What The Project Uses

ExploreNepal now uses Supabase as the shared backend for both apps:

- the mobile app reads approved data and submits pending rows
- the desktop/web portal signs users in first
- admin users can moderate all rows
- regular signed-in users can still only access approved public rows
- storage keeps uploaded spot images in the `spot-images` bucket

The mobile app still keeps a local SQLite cache for fast startup.

## Required Dart Defines

Run the mobile app with:

```bash
flutter run -t lib/main_mobile.dart \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=SUPABASE_SCHEMA=public \
  --dart-define=SUPABASE_TABLE=tourist_spots \
  --dart-define=SUPABASE_SPOT_IMAGES_BUCKET=spot-images
```

Run the desktop/web portal with:

```bash
flutter run -d chrome -t lib/main_admin.dart \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Optional:

```bash
--dart-define=SPOTS_FEED_URL=https://your-fallback-feed.example/spots.json
```

## Expected Table

- schema: `public`
- table: `tourist_spots`
- storage bucket: `spot-images`
- admin table: `admin_users`

The app will request:

- `https://<project>.supabase.co/rest/v1/tourist_spots?select=*`

It sends:

- `apikey: <anon key>`
- `Authorization: Bearer <anon key>`

## Recommended SQL

```sql
create table if not exists public.tourist_spots (
  id text primary key,
  name text not null,
  description text not null,
  latitude double precision not null,
  longitude double precision not null,
  category text not null,
  image_url text not null,
  user_images jsonb default '[]'::jsonb,
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
```

## Required Access

The mobile app uses the anon key, so RLS must allow only safe public actions:

- public read of approved rows
- public insert of pending rows
- admin-only moderation updates
- admin-only delete access

The schema file already creates these policies.

```sql
alter table public.tourist_spots enable row level security;

create policy "Public can read approved tourist spots"
on public.tourist_spots
for select
to anon, authenticated
using (
  deleted_at is null
  and status = 'approved'
);
```

## Role Setup

Any desktop/web user can sign in with a normal Supabase Auth account.

Only users added to `public.admin_users` are treated as admins.

1. Create an email/password user in Supabase Auth.
2. Copy that user's UUID.
3. Insert that user into `public.admin_users` only if they should moderate data.

Example:

```sql
insert into public.admin_users (user_id, email)
values ('YOUR_AUTH_USER_UUID', 'admin@example.com')
on conflict (user_id) do update
set email = excluded.email,
    is_active = true;
```

Without this step, sign-in still works, but the user only gets approved public data and cannot access moderation.

## Storage Setup

The schema file also creates a public storage bucket named `spot-images`.

Mobile submissions upload selected photos there first, then save the resulting public URLs in `tourist_spots.image_url` and `tourist_spots.user_images`.

## If the Schema Does Not Refresh

If you create or alter the table and the REST API does not see it immediately, run:

```sql
NOTIFY pgrst, 'reload schema';
```

## Launch Summary

- mobile app: `flutter run -t lib/main_mobile.dart`
- desktop/web portal: `flutter run -d chrome -t lib/main_admin.dart`
- production web portal build: `flutter build web -t lib/main_admin.dart`

## Mapping Notes

The app accepts both camelCase and snake_case remote fields.

Examples:

- `image_url` or `imageUrl`
- `user_images` or `userImages`
- `price_range` or `priceRange`
- `contact_phone` or `contactPhone`
- `contact_email` or `contactEmail`
- `promotional_message` or `promotionalMessage`
- `is_featured` or `isFeatured`

## Current Sync Behavior

- Supabase rows are treated as the remote source of truth
- the mobile app syncs approved rows into local SQLite
- local pending or rejected items that are not yet present remotely are preserved
- admin moderation updates the same Supabase rows the mobile app reads later
- signed-in non-admin portal users still read only approved rows
