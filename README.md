# Rick & Morty Characters

A Flutter application that fetches characters from the [Rick and Morty API](https://rickandmortyapi.com/documentation/), allows adding characters to favourites, and provides full offline access via local caching.

---

## Features

- **Character list** — infinite-scroll list of all characters with image, name, status (colour-coded dot), species, gender, origin and location.
- **Favourites** — dedicated screen for saved characters; add/remove with an animated star button.
- **Offline mode** — every loaded page is cached in SharedPreferences; the app works without internet using the cached data.
- **Error handling** — user-friendly error messages with a Retry button on network failure.
- **Search** — fuzzy search across loaded characters (client-side).
- **Sorting** — sort by name A→Z / Z→A or filter by status (Alive / Dead).
- **Theme switching** — toggle between light and dark themes via the AppBar icon.
- **Animations** — animated scale transition on the star button when toggling a favourite.

---

## Getting Started

### Prerequisites

- Flutter SDK **≥ 3.10** (Dart **≥ 3.0**)
- Android / iOS simulator or a physical device

### Run

```bash
git clone <repo-url>
cd rick_and_morty
flutter pub get
flutter run
```

The app builds and runs on Android, iOS, Windows, macOS, Linux and Web without any additional configuration.

---

## Architecture

The project follows **Clean Architecture** with three layers:

```
lib/
├── core/               # Shared: DI, network, theme, constants, exceptions
└── features/
    └── characters/
        ├── data/       # Models, remote & local data sources, repository impl
        ├── domain/     # Entities, repository interface, use cases
        └── presentation/  # Provider-based state management, pages, widgets
```

### Separation of Concerns

| Layer | Responsibility |
|-------|---------------|
| `domain` | Business logic — pure Dart, no Flutter/platform dependencies |
| `data` | API calls (Dio), local cache (SharedPreferences), repository wiring |
| `presentation` | UI widgets, `ChangeNotifier` providers, navigation |

---

## Technologies & Packages

| Purpose | Package |
|---------|---------|
| HTTP client | [`dio`](https://pub.dev/packages/dio) |
| Local storage (cache + favourites) | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| State management | [`provider`](https://pub.dev/packages/provider) |
| Dependency injection | [`get_it`](https://pub.dev/packages/get_it) |
| Image caching | [`cached_network_image`](https://pub.dev/packages/cached_network_image) |
| Connectivity check | [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) |
