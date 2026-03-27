# Implementation Plan: Integrate Businesses into Featured Screen

## Goal Description
The user wants businesses (Hotels, Dining, etc.) to be showcased within the "Featured" screen rather than a separate tab. This will help promote local businesses alongside tourist attractions.

## Proposed Changes

### 1. Navigation Cleanup
#### [MODIFY] `lib/features/navigation/presentation/main_shell_screen.dart`
- Remove `BusinessDirectoryScreen` from the `tabs` list.
- Remove the "Directory" `NavigationDestination` and `NavigationRailDestination`.

### 2. Featured Screen Integration
#### [MODIFY] `lib/features/destinations/presentation/featured_destinations_screen.dart`
- Watch `businessesProvider` in addition to `spotsProvider`.
- Combine featured `TouristSpot` items with approved `Business` items.
- Update the UI to handle both `TouristSpot` and `Business` objects (possibly by creating a shared interface or a wrapper).
- Implement sections or filters to browse through different types (Hotels, Dining, etc.) within the Featured screen.

### 3. Cleanup
#### [DELETE] `lib/features/businesses/presentation/business_directory_screen.dart` (Optional, or keep as a private widget)

## Verification Plan
### Manual Verification
1. Open the app and verify the "Directory" tab is gone.
2. Go to the "Featured" screen.
3. Verify that both featured tourist spots and businesses (Hotels, Restaurants) are visible.
4. Test pull-to-refresh to ensure both data sources are updated.
