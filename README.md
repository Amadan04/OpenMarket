# OpenMarket

A local peer-to-peer marketplace iOS app built with SwiftUI, enabling users to buy and sell items in their community.

## Features

- **Browse & Search** — Discover listings with keyword search, category filters, condition filters, and price range
- **Map View** — Explore nearby products on an interactive map with price pin annotations
- **Post Listings** — Create listings with images, description, price, category, condition, and location
- **Direct Messaging** — Real-time chat between buyers and sellers
- **Favorites** — Save products to revisit later
- **Reviews & Ratings** — Rate sellers and view reputation scores
- **User Profiles** — Manage your listings, view transaction history, and edit personal info
- **Report & Block** — Report suspicious listings and block users

## Tech Stack

- **SwiftUI** — Declarative UI
- **MapKit** — Location-based discovery
- **Combine** — Reactive state management
- **URLSession + Async/Await** — Networking
- **Keychain** — Secure token storage
- **MVVM Architecture** — Clean separation of concerns

## Project Structure

```
OpenMarket/
├── Models/          # Codable data structures (Product, User, Message, Review, ...)
├── Views/
│   ├── Auth/        # Login & registration
│   ├── Home/        # Browse feed with search and filters
│   ├── Map/         # Map-based product discovery
│   ├── Product/     # Detail, add, edit, report views
│   ├── Messaging/   # Conversations and chat
│   ├── Favorites/   # Saved listings
│   ├── Profile/     # User profile, settings, my listings
│   └── Components/  # Reusable UI components (OMButton, OMField, OMChip, ...)
├── ViewModels/      # Business logic per screen
├── Services/        # API abstraction (Auth, Product, Message, Favorite, Review, Location)
└── Utilities/       # Theme, constants, AppState, KeychainHelper
```

## Product Categories

Vehicles · Property · Mobile · Electronics · Furniture · Fashion · Sports · Books · Other

## Getting Started

### Requirements

- Xcode 15+
- iOS 17+
- A running backend at `http://localhost:8080`

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/your-username/OpenMarket.git
   ```

2. Open `OpenMarket.xcodeproj` in Xcode.

3. Start the backend server on port `8080`.

4. Build and run on a simulator or device.

## Architecture

The app follows **MVVM** with a service layer:

- **Views** handle presentation only
- **ViewModels** own `@Published` state and coordinate with services
- **Services** abstract REST API calls via a shared `APIClient` singleton
- **AppState** provides global state (auth, tab visibility) via `@EnvironmentObject`

Authentication uses JWT bearer tokens stored in the system Keychain. Chat polling refreshes every 5 seconds while a conversation is open.

## Design System

A custom theme (`Theme.swift`) defines a consistent visual language:

- **Palette** — Clay, stone, and sage tones
- **Typography** — Serif display font + Inter body font
- **Components** — `OMButton`, `OMField`, `OMChip`, custom tab bar

## License

MIT
