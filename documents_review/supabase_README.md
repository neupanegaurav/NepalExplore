# Supabase SQL

This folder contains the SQL needed for the shared mobile-app and desktop/web portal backend.

## Files

- `schema_tourist_spots.sql` - creates the `public.tourist_spots` table, `public.admin_users`, the `spot-images` storage bucket, indexes, RLS policies, and reloads the PostgREST schema cache
- `seed_tourist_spots.sql` - inserts the current app seed data into Supabase

## Order

1. Run `schema_tourist_spots.sql`
2. Run `seed_tourist_spots.sql`
3. Create any sign-in users you want in Supabase Auth
4. Insert only moderator accounts into `public.admin_users`

Example admin grant:

```sql
insert into public.admin_users (user_id, email)
values ('YOUR_AUTH_USER_UUID', 'admin@example.com')
on conflict (user_id) do update
set email = excluded.email,
    is_active = true;
```

## Flutter Run Example

```bash
flutter run -t lib/main_mobile.dart \
  --dart-define=SUPABASE_URL=https://kymqjgqhuwiktyjqcbyv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=SUPABASE_SCHEMA=public \
  --dart-define=SUPABASE_TABLE=tourist_spots \
  --dart-define=SUPABASE_SPOT_IMAGES_BUCKET=spot-images
```

Desktop/web portal example:

```bash
flutter run -d chrome -t lib/main_admin.dart \
  --dart-define=SUPABASE_URL=https://kymqjgqhuwiktyjqcbyv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```
