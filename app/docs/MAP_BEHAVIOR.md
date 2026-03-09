# Map Behavior

## Data source

- Map consumes listings from the same `ListingBloc` stream used by the Home feed.
- This keeps map content aligned with real-time listing updates.

## Marker strategy

- Valid coordinates (`latitude`, `longitude`) are used directly.
- Missing/invalid coordinates are assigned fallback points near the default city center.

## User experience behavior

- Markers are tappable and highlight selected listing.
- The selected listing card opens detail view.
- Map auto-fits bounds when listing count changes.

## Trade-off

- Fallback positions improve visibility but are approximate.
- Accurate geo placement still depends on proper coordinates at listing creation time.
