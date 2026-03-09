# Map Behavior Notes

## Marker population
- Map tries to pin every listing.
- Listings with valid coordinates use their exact lat/lng.
- Listings with missing/invalid coordinates receive fallback marker points.

## Why fallback markers exist
- Prevents map from appearing empty for partially completed listing records.
- Keeps visibility between Home/My Listings and Map more consistent.

## Limitation
- Fallback points are approximate and should not be used for precise navigation.
