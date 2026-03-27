# Supabase Sync Strategy

## Goal

ExploreNepal uses a local SQLite database for fast app startup and offline-friendly reads, but the source of truth can be Supabase.

The intended model is:

- Supabase is the remote source of truth for approved content
- the app syncs remote rows into the local database
- the UI always reads from the local database
- local pending submissions can be preserved until the server accepts them

## Current Local Architecture

- Local storage uses a generic JSON document table
- `tourist_spots` is the current synced collection
- the app loads spots from the local database on startup
- sync replaces approved remote rows and keeps local non-approved rows that are not yet on the server

## Recommended Supabase Table

Recommended table:

- schema: `public`
- table: `tourist_spots`

Recommended columns:

- `id text primary key`
- `name text not null`
- `description text not null`
- `latitude double precision not null`
- `longitude double precision not null`
- `category text not null`
- `image_url text not null`
- `user_images jsonb default '[]'::jsonb`
- `status text not null default 'approved'`
- `price_range text null`
- `contact_phone text null`
- `contact_email text null`
- `promotional_message text null`
- `is_featured boolean not null default false`
- `updated_at timestamptz not null default now()`
- `deleted_at timestamptz null`

## Local Mapping Rules

The app already accepts both camelCase and snake_case remote keys for spot rows.

Examples:

- `imageUrl` or `image_url`
- `userImages` or `user_images`
- `priceRange` or `price_range`
- `contactPhone` or `contact_phone`
- `contactEmail` or `contact_email`
- `promotionalMessage` or `promotional_message`
- `isFeatured` or `is_featured`
- `status` or `approval_status`

This means your Supabase rows can stay in a normal SQL-friendly snake_case format.

## Resync Strategy

Recommended sync behavior:

1. Fetch rows from Supabase for the `tourist_spots` table
2. Ignore rows where `deleted_at` is not null
3. Normalize each row into the app spot model
4. Replace the approved local server-backed rows with the latest remote dataset
5. Preserve local rows that are still pending or rejected and not yet present remotely
6. Mark the local collection as synced with timestamp and source label

## Why This Works Well

- app startup stays fast because the UI reads local data
- sync can happen on demand or in the background
- Supabase remains the canonical backend
- local drafts or pending submissions are less likely to be lost

## Future Implementation Path

When you are ready to connect Supabase directly, the cleanest next step is:

1. add a Supabase-backed implementation of the remote source contract
2. fetch rows from `public.tourist_spots`
3. map Supabase rows into `TouristSpot`
4. reuse the existing repository sync logic

That means the local DB layer should not need a redesign when you move from JSON feed to Supabase.
