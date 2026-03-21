# ExploreNepal

One Flutter repo with:

- a mobile app for travelers
- a desktop/web portal for signed-in users
- Supabase as the shared backend and API

## Architecture

The project now runs as two Flutter entrypoints against the same Supabase data:

- `lib/main_mobile.dart` for the mobile app
- `lib/main_admin.dart` for the desktop/web portal
- `lib/main.dart` auto-selects portal on web/macOS/Windows and mobile app on iOS/Android

The mobile app:

- fetches approved rows from Supabase
- submits new spots and business listings as `pending`
- keeps a local SQLite cache for fast startup
- shows only the public traveler experience on iOS and Android

The desktop/web portal on web, macOS, and Windows:

- opens with a login screen first
- signed-in regular users can only access approved public data
- signed-in admin users can access the same public app plus the admin moderation tab

Admin users can:

- load pending, approved, and rejected submissions
- approve, reject, edit, feature, or soft-delete rows

Regular signed-in users cannot:

- see pending or rejected submissions
- access admin moderation actions

## Run The Mobile App

```bash
flutter run -t lib/main_mobile.dart
```

Default behavior:

```bash
flutter run
```

This now auto-selects:

- `iOS` and `Android` -> public mobile app
- `web`, `macOS`, and `Windows` -> login-first desktop/web portal

## Run The Desktop/Web Portal

```bash
flutter run -d chrome -t lib/main_admin.dart
```

## Build The Web Portal

```bash
flutter build web -t lib/main_admin.dart
```

## Run And Build By Platform

Mobile public app:

```bash
flutter run -d android -t lib/main_mobile.dart
flutter run -d ios -t lib/main_mobile.dart
flutter build apk --release -t lib/main_mobile.dart
flutter build ios --release -t lib/main_mobile.dart
```

Desktop/web portal:

```bash
flutter run -d chrome -t lib/main_admin.dart
flutter run -d macos -t lib/main_admin.dart
flutter run -d windows -t lib/main_admin.dart
flutter build web -t lib/main_admin.dart
flutter build macos --release -t lib/main_admin.dart
flutter build windows --release -t lib/main_admin.dart
```

Admin refresh behavior:

- in the admin dashboard, pressing `Refresh` fetches the latest server rows
- if new pending submissions are found, they are populated immediately
- the dashboard also supports pull-to-refresh

## Supabase Setup

Run the SQL in [supabase/schema_tourist_spots.sql](/Users/npngaurav/Desktop/ExploreNepal/supabase/schema_tourist_spots.sql) first, then seed data from [supabase/seed_tourist_spots.sql](/Users/npngaurav/Desktop/ExploreNepal/supabase/seed_tourist_spots.sql).

The schema file now sets up:

- `public.tourist_spots`
- `public.admin_users`
- row-level security policies
- the public `spot-images` storage bucket
- admin moderation permissions

Detailed setup notes are in [docs/SUPABASE_SETUP.md](/Users/npngaurav/Desktop/ExploreNepal/docs/SUPABASE_SETUP.md).

## Import GeoNames Places

To import normalized place data from GeoNames for Nepal:

```bash
dart run tool/import_geonames.dart
```

This downloads the latest GeoNames dump for `NP`, keeps provinces, districts,
and populated places, and writes a JSON dataset to
`server/geonames_places_np.json`.

Useful variants:

```bash
dart run tool/import_geonames.dart --min-population=1000
dart run tool/import_geonames.dart --skip-download
dart run tool/import_geonames.dart --output=server/nepal_places_search.json
```

The generated JSON is intentionally separate from `TouristSpot` data so raw
GeoNames rows can be used for search, pickers, or later Supabase imports
without forcing them into the curated tourism schema.
