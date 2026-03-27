# Task: Refine Tourist Spots Data and App Features

- [x] Update Wikidata SPARQL query and dart seed script to correctly classify spots into categories (mountains -> mountain, lakes -> sceneries, etc.).
- [x] Optimize image loading in the app (e.g., using `cached_network_image` and optimizing URLs if possible).
- [x] Fix the "Post new spot" form to ensure business categories (Hotels, Tourist agents, tickets, guides, dining) are handled correctly or removed from spot creation.
- [x] Fix the AI insights feature to correctly populate the description, location, and address for a place.
- [x] Update map markers to use distinct icons/logos based on the destination category.
- [x] Implement pull-to-refresh functionality on data-driven pages.
- [x] Fix the "Post Business" form to only show business-related categories.
- [x] Clear database and repopulate with refined categories based on spot name analysis.
    - [x] Update `scrape_wikidata.dart` with refined keyword-based categorization logic.
    - [x] Update `scrape_wikidata.dart` to use optimized Wikimedia thumbnail URLs.
    - [x] Add `TRUNCATE` or `DELETE` to SQL seed file.
    - [x] Regenerate and apply seed data.

- [x] Implement dedicated Business Directory and Data.
    - [x] Create `tool/scrape_businesses.dart` to fetch hotels and restaurants from Wikidata.
    - [x] Create `supabase/migrations/20260323_create_businesses.sql` for the new table.
    - [x] Update `generate_wikidata_seed.dart` (or create a new one) to handle business data.
    - [x] Update Flutter app models and services to support the new `businesses` table.
    - [x] Implement UI for exploring businesses.

- [x] Integrate Businesses into Featured Screen.
    - [x] Remove separate "Directory" tab from `MainShellScreen`.
    - [x] Update `FeaturedDestinationsScreen` to fetch and display businesses from `businessesProvider`.
    - [x] Combine featured spots and businesses in the Featured list.
    - [x] Add category filter or horizontal sections for different business types in Featured screen.
