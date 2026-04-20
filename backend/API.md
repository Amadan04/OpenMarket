# OpenMarket Backend API

Base URL: `/`

Authentication: send JWT as `Authorization: Bearer <token>`.

## Error Format

All errors return:

```json
{
  "error": "human readable message"
}
```

Common status codes: `400`, `401`, `403`, `404`, `409`, `500`.

## Auth

## POST /auth/register

Create a new user account.

### Request
```json
{
  "name": "Ziyad",
  "email": "test@example.com",
  "password": "password123"
}
```

### Response
```json
{
  "id": 1,
  "email": "test@example.com",
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "name": "Ziyad",
    "email": "test@example.com",
    "created_at": "2026-04-20T10:00:00Z"
  }
}
```

### Auth Required
No

## POST /auth/login

Login and receive JWT token.

### Request
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

### Response
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "name": "Ziyad",
    "email": "test@example.com",
    "created_at": "2026-04-20T10:00:00Z"
  }
}
```

### Auth Required
No

## GET /auth/me

Get current authenticated user profile.

### Request Body
None

### Response
```json
{
  "id": 1,
  "name": "Ziyad",
  "email": "test@example.com",
  "created_at": "2026-04-20T10:00:00Z"
}
```

### Auth Required
Yes

## Products

## POST /products

Create a product.

### Request
```json
{
  "title": "iPhone 13",
  "description": "128GB, excellent condition",
  "price": 520,
  "category": "Electronics",
  "location": "Cairo",
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

### Response
```json
{
  "id": 12,
  "title": "iPhone 13",
  "description": "128GB, excellent condition",
  "price": 520,
  "category": "Electronics",
  "location": "Cairo",
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "latitude": 30.0444,
  "longitude": 31.2357,
  "user_id": 1,
  "created_at": "2026-04-20T10:00:00Z"
}
```

### Auth Required
Yes

## GET /products

Get all products with optional pagination and text search.

### Query Params
- `search` (optional): search in title/description
- `page` (optional, default `1`)
- `limit` (optional, default `20`, max `100`)

### Response
```json
[
  {
    "id": 12,
    "title": "iPhone 13",
    "description": "128GB, excellent condition",
    "price": 520,
    "category": "Electronics",
    "location": "Cairo",
    "images": ["https://example.com/image1.jpg"],
    "latitude": 30.0444,
    "longitude": 31.2357,
    "user_id": 1,
    "created_at": "2026-04-20T10:00:00Z"
  }
]
```

### Auth Required
Yes

## GET /products/:id

Get product by id.

### Request Body
None

### Response
```json
{
  "id": 12,
  "title": "iPhone 13",
  "description": "128GB, excellent condition",
  "price": 520,
  "category": "Electronics",
  "location": "Cairo",
  "images": ["https://example.com/image1.jpg"],
  "latitude": 30.0444,
  "longitude": 31.2357,
  "user_id": 1,
  "created_at": "2026-04-20T10:00:00Z"
}
```

### Auth Required
Yes

## PUT /products/:id

Update product owned by authenticated user.

### Request
```json
{
  "title": "iPhone 13 Pro",
  "description": "Updated description",
  "price": 600,
  "category": "Electronics",
  "location": "Giza",
  "images": ["https://example.com/new.jpg"],
  "latitude": 29.987,
  "longitude": 31.211
}
```

### Response
```json
{
  "id": 12,
  "title": "iPhone 13 Pro",
  "description": "Updated description",
  "price": 600,
  "category": "Electronics",
  "location": "Giza",
  "images": ["https://example.com/new.jpg"],
  "latitude": 29.987,
  "longitude": 31.211,
  "user_id": 1,
  "created_at": "2026-04-20T10:00:00Z"
}
```

### Auth Required
Yes

## DELETE /products/:id

Delete product owned by authenticated user.

### Request Body
None

### Response
```json
{
  "message": "Deleted"
}
```

### Auth Required
Yes

## GET /products/search

Search products by category, price range, and text query.

### Query Params
- `category` (optional)
- `min_price` (optional)
- `max_price` (optional)
- `q` (optional text in title/description)

### Response
```json
[
  {
    "id": 12,
    "title": "iPhone 13",
    "price": 520,
    "category": "Electronics",
    "location": "Cairo",
    "images": ["https://example.com/image1.jpg"],
    "latitude": 30.0444,
    "longitude": 31.2357,
    "user_id": 1,
    "created_at": "2026-04-20T10:00:00Z"
  }
]
```

### Auth Required
Yes

## GET /products/nearby

Find products near a latitude/longitude within radius.

### Query Params
- `lat` (required)
- `lng` (required)
- `radius_km` (optional, default `10`)

### Response
```json
[
  {
    "id": 12,
    "title": "iPhone 13",
    "price": 520,
    "category": "Electronics",
    "location": "Cairo",
    "images": ["https://example.com/image1.jpg"],
    "latitude": 30.0444,
    "longitude": 31.2357,
    "user_id": 1,
    "created_at": "2026-04-20T10:00:00Z"
  }
]
```

### Auth Required
Yes

## Favorites

## POST /favorites/:productId

Add product to favorites.

### Request Body
None

### Response
```json
{
  "id": 3,
  "user_id": 1,
  "listing_id": 12
}
```

### Auth Required
Yes

## DELETE /favorites/:productId

Remove product from favorites.

### Request Body
None

### Response
```json
{
  "message": "Deleted"
}
```

### Auth Required
Yes

## GET /favorites

Get current user favorites.

### Request Body
None

### Response
```json
[
  {
    "id": 3,
    "user_id": 1,
    "product": {
      "id": 12,
      "title": "iPhone 13",
      "price": 520,
      "category": "Electronics",
      "location": "Cairo",
      "images": ["https://example.com/image1.jpg"],
      "latitude": 30.0444,
      "longitude": 31.2357,
      "user_id": 2,
      "created_at": "2026-04-20T10:00:00Z"
    }
  }
]
```

### Auth Required
Yes

## Messaging

## POST /messages

Send message to another user.

### Request
```json
{
  "receiver_id": 2,
  "content": "Is this still available?"
}
```

### Response
```json
{
  "id": 10,
  "sender_id": 1,
  "receiver_id": 2,
  "content": "Is this still available?",
  "timestamp": "2026-04-20T10:00:00Z"
}
```

### Auth Required
Yes

## GET /conversations

Get current user conversations.

### Request Body
None

### Response
```json
[
  {
    "id": 2,
    "participant": {
      "id": 2,
      "name": "Seller User",
      "email": "seller@example.com",
      "created_at": "2026-04-19T10:00:00Z"
    },
    "last_message": {
      "id": 10,
      "sender_id": 1,
      "receiver_id": 2,
      "content": "Is this still available?",
      "timestamp": "2026-04-20T10:00:00Z"
    }
  }
]
```

### Auth Required
Yes

## GET /conversations/:id/messages

Get messages between current user and conversation participant `:id`.

### Request Body
None

### Response
```json
[
  {
    "id": 9,
    "sender_id": 2,
    "receiver_id": 1,
    "content": "Yes, it is available.",
    "timestamp": "2026-04-20T09:55:00Z"
  },
  {
    "id": 10,
    "sender_id": 1,
    "receiver_id": 2,
    "content": "Is this still available?",
    "timestamp": "2026-04-20T10:00:00Z"
  }
]
```

### Auth Required
Yes

## Reviews

## POST /reviews

Add review for seller.

### Request
```json
{
  "seller_id": 2,
  "rating": 5,
  "comment": "Great seller!"
}
```

### Response
```json
{
  "id": 15,
  "rating": 5,
  "comment": "Great seller!",
  "seller_id": 2,
  "reviewer_id": 1,
  "created_at": "2026-04-20T10:00:00Z"
}
```

### Auth Required
Yes

## GET /users/:id/reviews

Get seller reviews and average rating.

### Request Body
None

### Response
```json
{
  "seller_id": 2,
  "average_rating": 4.5,
  "reviews_count": 2,
  "reviews": [
    {
      "id": 15,
      "rating": 5,
      "comment": "Great seller!",
      "seller_id": 2,
      "reviewer_id": 1,
      "created_at": "2026-04-20T10:00:00Z"
    },
    {
      "id": 16,
      "rating": 4,
      "comment": "Smooth transaction.",
      "seller_id": 2,
      "reviewer_id": 3,
      "created_at": "2026-04-20T11:00:00Z"
    }
  ]
}
```

### Auth Required
Yes
