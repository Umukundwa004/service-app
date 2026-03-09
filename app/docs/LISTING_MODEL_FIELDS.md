# Listing Model Field Guide

This document maps `ListingModel` fields to their UI and service usage.

## Identity and Ownership

- `id`: Firestore document ID used for update/delete.
- `userId`: owner UID used by My Listings filtering.
- `ownerId`: compatibility write for legacy records.

## Core Content

- `name`, `description`, `category`: displayed on cards/detail pages.
- `address`, `phone`, `email`: shown on detail and contact sections.

## Media and Location

- `imageUrl`: thumbnail/hero image source.
- `latitude`, `longitude`: map marker location.

## Lifecycle and Quality

- `createdAt`, `updatedAt`: sorting and change tracking.
- `rating`, `reviewCount`: quality indicators.
- `openingHours`, `amenities`: extra listing metadata.

## Compatibility behavior

- Read path: `userId ?? ownerId`.
- Write path: writes both `userId` and `ownerId`.
