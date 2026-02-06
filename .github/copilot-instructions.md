# AI Coding Agent Instructions for my_library

## Project Overview
This is a Flutter app called "Autumn Library" - a book discovery and management application. It features user authentication, book search via Open Library API, bookmarking, and categorized browsing.

## Architecture
- **Feature-based structure**: Code organized under `lib/features/` with each feature (auth, home, bookmarks, etc.) containing its own pages and logic
- **Data layer**: `lib/data/` contains models, services, and fake_db for in-memory storage
- **Core utilities**: `lib/core/` holds shared theme, routes, and utilities
- **UI components**: `lib/layout/` for main app structure, `lib/widgets/` for reusable components
- **State management**: Simple setState-based, no complex state management libraries

## Key Data Flows
- **Authentication**: Uses `AuthStore` (in-memory) for login/register with `UserModel`
- **Book search**: `OpenLibraryService` fetches from Open Library API, returns `BookModel` list
- **Bookmarks**: Stored per user in `AuthStore.bookmarks` map
- **Navigation**: Named routes in `main.dart`, bottom navigation in `MainLayout`

## Developer Workflows
- **Run app**: `flutter run`
- **Build**: `flutter build apk` or `flutter build ios`
- **Test**: `flutter test` (single test file in `test/`)
- **Lint**: `flutter analyze` (uses `flutter_lints` from `analysis_options.yaml`)
- **Dependencies**: `flutter pub get` / `flutter pub upgrade`

## Project-Specific Conventions
- **Theming**: Custom `AppTheme` with autumn color palette (cream, brown, autumn colors)
- **Error messages**: Indonesian language for user-facing validation (e.g., "Email tidak boleh kosong")
- **API integration**: HTTP requests with `http` package, JSON parsing in model factories
- **Animations**: Use `AnimationController` with `TickerProviderStateMixin` for fade-in effects
- **Form validation**: Regex for email, minimum length for passwords
- **Pagination**: Manual page-based loading with cache in `HomePage`

## Common Patterns
- **Widget structure**: Stateful widgets with controllers, form keys, and loading states
- **API calls**: Static methods in service classes, async/await with error handling
- **Navigation**: `Navigator.pushReplacementNamed` for auth flow, index-based for main tabs
- **Models**: Simple classes with `copyWith` for immutability, `fromJson` factories for API data
- **Fake data**: In-memory lists/maps in `AuthStore` for development without backend

## External Dependencies
- `http: ^1.6.0` - For Open Library API calls
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^5.0.0` - Code quality linting

## Key Files to Reference
- `lib/main.dart` - App entry and routing setup
- `lib/core/theme/app_theme.dart` - Color scheme and theme configuration
- `lib/data/services/openlibrary_service.dart` - Book search API integration
- `lib/features/auth/login_page.dart` - Auth UI with animations and validation
- `lib/layout/main_layout.dart` - Main app navigation structure</content>
<parameter name="filePath">d:\Learn Coding\Dart\my_library\.github\copilot-instructions.md