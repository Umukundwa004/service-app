# Firestore Schema

## Collections

### users/{uid}

- id: string (doc id)
- email: string
- displayName: string
- photoUrl: string
- createdAt: timestamp
- notificationsEnabled: bool (optional)

### listings/{listingId}

- name: string
- description: string
- category: string
- address: string
- phone: string
- email: string
- imageUrl: string
- latitude: number
- longitude: number
- userId: string
- ownerId: string (legacy compatibility)
- createdAt: timestamp
- updatedAt: timestamp
- rating: number
- reviewCount: number
- openingHours: string
- amenities: string[]

## Notes

- `userId` is the primary ownership key.
- `ownerId` remains for backward compatibility while migrating older records.
- Listing IDs are deterministic and created by the app for stable updates/deletes.
