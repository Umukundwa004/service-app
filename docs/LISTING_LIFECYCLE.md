# Listing Lifecycle

## Create

- Listing is created with owner UID.
- Saved using deterministic document ID.
- Timestamp fields are stored for ordering.

## Read

- Home uses real-time stream of all listings.
- My Listings uses user-scoped stream and sort.

## Update

- Existing listing document is updated.
- `updatedAt` is refreshed.

## Delete

- Listing document is deleted by ID.

## Known trade-off

- My Listings uses resilient client-side filter/sort to avoid index dependency issues in early development.
