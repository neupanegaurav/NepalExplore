# Server Feed

`spots.json` is the current remote sync feed used by the app.

This feed is also a good bridge format until Supabase becomes the primary backend.

The app syncs from:

- `SPOTS_FEED_URL` if you pass it with `--dart-define`
- otherwise `https://raw.githubusercontent.com/neupanegaurav/NepalExplore/main/server/spots.json`

To update the live feed:

1. Regenerate `server/spots.json` locally if needed
2. Commit the updated file
3. Push it to the branch that serves your production feed

Each entry in `spots.json` is a serialized `TouristSpot` document that includes:

- core place metadata
- coordinates
- category
- remote image URLs
- approval status
- optional business fields

For future Supabase integration, keep the same logical fields but use SQL-friendly
snake_case column names such as:

- `image_url`
- `user_images`
- `price_range`
- `contact_phone`
- `contact_email`
- `promotional_message`
- `is_featured`
