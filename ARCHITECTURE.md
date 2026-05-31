# 🏦 KOSH — Architecture & Project Structure

> **Kosh** — A futuristic, dark-theme personal finance and financial goal tracking application.
> Offline-first. No backend. No cloud. Pure local power.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
- [Tech Stack & Dependencies](#tech-stack--dependencies)
- [Theme System](#theme-system)
- [Feature Modules](#feature-modules)
- [Data Flow](#data-flow)
- [File Responsibilities](#file-responsibilities)
- [Development Guidelines](#development-guidelines)

---

## Overview

**Kosh** is a privacy-first, offline-only personal finance application built with Flutter. It provides:

- 💰 Transaction tracking (income, expenses, transfers)
- 🎯 Financial goal setting and progress tracking
- 📊 Analytics with rich interactive charts
- 📈 Investment portfolio tracking
- 🏆 Gamification to reward healthy financial habits
- 🌟 Vision board for dream visualization
- 🔐 Biometric authentication for security
- 🔔 Local notification reminders

### Core Principles

| Principle | Description |
|---|---|
| **Offline First** | All data stored locally via Isar Database |
| **No Backend** | Zero server dependencies |
| **No Firebase** | No Google cloud services |
| **No Cloud Sync** | Data never leaves the device |
| **No AI Features** | No ML/AI integrations |
| **No Social Features** | No sharing, feeds, or social login |

---

## Architecture

### Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────┐
│                    VIEW                      │
│         (Widgets / Screens / Pages)          │
│                                              │
│  Observes state via Riverpod providers       │
│  Dispatches user actions to ViewModel        │
├──────────────────────────────────────────────┤
│                 VIEWMODEL                    │
│          (StateNotifier / Notifier)           │
│                                              │
│  Business logic & state management           │
│  Calls Repository methods                    │
│  Exposes state via Riverpod providers        │
├──────────────────────────────────────────────┤
│                REPOSITORY                    │
│           (Data Access Layer)                │
│                                              │
│  Abstracts data source operations            │
│  Interacts with Isar collections             │
├──────────────────────────────────────────────┤
│                  MODEL                       │
│          (Data Classes / Entities)            │
│                                              │
│  Isar collections & plain Dart models        │
│  Serialization / deserialization              │
└──────────────────────────────────────────────┘
```

### State Management: Riverpod

- All dependency injection through Riverpod providers
- ViewModels exposed as `StateNotifierProvider` / `NotifierProvider`
- Repositories and services injected via `Provider`
- Database instance provided at app startup via `ProviderScope` overrides

### Navigation: GoRouter

- Declarative routing with `GoRouter`
- `ShellRoute` for bottom navigation scaffold
- Named routes for type-safe navigation
- Route constants centralized in `core/constants/route_constants.dart`

---

## Folder Structure

```
lib/
│
├── main.dart                              # App entry point
│
├── app/                                   # App-level configuration
│   ├── kosh_app.dart                      # Root MaterialApp widget
│   ├── router/
│   │   └── app_router.dart                # GoRouter configuration
│   └── theme/
│       ├── app_theme.dart                 # Material 3 ThemeData
│       ├── app_colors.dart                # Color palette constants
│       └── app_text_styles.dart           # Typography system
│
├── core/                                  # Shared utilities & infrastructure
│   ├── constants/
│   │   ├── app_constants.dart             # App-wide constants
│   │   ├── storage_constants.dart         # DB & storage key constants
│   │   └── route_constants.dart           # Named route path strings
│   ├── utils/
│   │   ├── date_utils.dart                # Date formatting helpers
│   │   ├── currency_utils.dart            # Currency formatting helpers
│   │   └── validators.dart                # Input validation logic
│   ├── services/
│   │   ├── notification_service.dart      # Flutter Local Notifications
│   │   ├── auth_service.dart              # Local Auth / Biometrics
│   │   └── secure_storage_service.dart    # Flutter Secure Storage
│   ├── widgets/
│   │   ├── kosh_scaffold.dart             # Reusable scaffold with nav
│   │   ├── kosh_button.dart               # Styled button component
│   │   ├── kosh_text_field.dart           # Styled input field
│   │   └── kosh_loading_indicator.dart    # Loading state widget
│   ├── extensions/
│   │   ├── string_extensions.dart         # String helper extensions
│   │   ├── date_time_extensions.dart      # DateTime helper extensions
│   │   ├── number_extensions.dart         # Number helper extensions
│   │   └── context_extensions.dart        # BuildContext extensions
│   └── errors/
│       ├── app_exception.dart             # Base exception class
│       ├── error_handler.dart             # Global error handling
│       └── failures.dart                  # Failure type definitions
│
├── database/                              # Data persistence layer
│   ├── isar_service.dart                  # Isar DB init & management
│   ├── collections/
│   │   ├── transaction_collection.dart    # Transaction Isar schema
│   │   ├── goal_collection.dart           # Goal Isar schema
│   │   ├── investment_collection.dart     # Investment Isar schema
│   │   └── category_collection.dart       # Category Isar schema
│   └── repositories/
│       ├── transaction_repository.dart    # Transaction data access
│       ├── goal_repository.dart           # Goal data access
│       ├── investment_repository.dart     # Investment data access
│       └── category_repository.dart       # Category data access
│
├── models/                                # Shared data models
│   ├── transaction_model.dart             # Transaction entity
│   ├── goal_model.dart                    # Financial goal entity
│   ├── investment_model.dart              # Investment entity
│   ├── category_model.dart                # Category entity
│   └── user_settings_model.dart           # User preferences
│
├── providers/                             # Riverpod dependency injection
│   ├── database_providers.dart            # Isar service providers
│   ├── repository_providers.dart          # Repository providers
│   └── service_providers.dart             # Service providers
│
├── features/                              # Feature modules (MVVM)
│   │
│   ├── dashboard/
│   │   ├── view/
│   │   │   └── dashboard_view.dart        # Dashboard screen
│   │   ├── viewmodel/
│   │   │   └── dashboard_viewmodel.dart   # Dashboard state & logic
│   │   ├── widgets/                       # Dashboard-specific widgets
│   │   └── models/                        # Dashboard-specific models
│   │
│   ├── transactions/
│   │   ├── view/
│   │   │   └── transactions_view.dart     # Transactions list screen
│   │   ├── viewmodel/
│   │   │   └── transactions_viewmodel.dart # Transactions state & logic
│   │   ├── widgets/                       # Transaction-specific widgets
│   │   └── models/                        # Transaction-specific models
│   │
│   ├── goals/
│   │   ├── view/
│   │   │   └── goals_view.dart            # Goals tracking screen
│   │   ├── viewmodel/
│   │   │   └── goals_viewmodel.dart       # Goals state & logic
│   │   ├── widgets/                       # Goal-specific widgets
│   │   └── models/                        # Goal-specific models
│   │
│   ├── analytics/
│   │   ├── view/
│   │   │   └── analytics_view.dart        # Analytics & charts screen
│   │   ├── viewmodel/
│   │   │   └── analytics_viewmodel.dart   # Analytics state & logic
│   │   ├── widgets/                       # Chart widgets (fl_chart)
│   │   └── models/                        # Analytics-specific models
│   │
│   ├── investments/
│   │   ├── view/
│   │   │   └── investments_view.dart      # Investment portfolio screen
│   │   ├── viewmodel/
│   │   │   └── investments_viewmodel.dart # Investment state & logic
│   │   ├── widgets/                       # Investment-specific widgets
│   │   └── models/                        # Investment-specific models
│   │
│   ├── gamification/
│   │   ├── view/
│   │   │   └── gamification_view.dart     # Achievements & rewards screen
│   │   ├── viewmodel/
│   │   │   └── gamification_viewmodel.dart # Gamification state & logic
│   │   ├── widgets/                       # Badge/streak widgets
│   │   └── models/                        # Gamification models
│   │
│   ├── vision_board/
│   │   ├── view/
│   │   │   └── vision_board_view.dart     # Vision board screen
│   │   ├── viewmodel/
│   │   │   └── vision_board_viewmodel.dart # Vision board state & logic
│   │   ├── widgets/                       # Vision board widgets
│   │   └── models/                        # Vision board models
│   │
│   └── settings/
│       ├── view/
│       │   └── settings_view.dart         # Settings screen
│       ├── viewmodel/
│       │   └── settings_viewmodel.dart    # Settings state & logic
│       ├── widgets/                       # Settings-specific widgets
│       └── models/                        # Settings-specific models
│
└── shared/                                # Cross-feature shared UI
    ├── widgets/                           # Reusable UI components
    ├── animations/                        # flutter_animate presets
    ├── dialogs/                           # Common dialog templates
    └── cards/                             # Reusable card components
```

---

## Tech Stack & Dependencies

### Core Framework

| Package | Purpose |
|---|---|
| `flutter` | UI framework |
| `dart` | Programming language |

### State Management & DI

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management & dependency injection |
| `riverpod_annotation` | Code generation for Riverpod |

### Navigation

| Package | Purpose |
|---|---|
| `go_router` | Declarative routing with ShellRoute |

### Database & Storage

| Package | Purpose |
|---|---|
| `isar` | NoSQL local database (offline-first) |
| `isar_flutter_libs` | Isar platform bindings |
| `flutter_secure_storage` | Encrypted key-value storage for sensitive data |

### Authentication

| Package | Purpose |
|---|---|
| `local_auth` | Biometric authentication (fingerprint, face) |

### Notifications

| Package | Purpose |
|---|---|
| `flutter_local_notifications` | Scheduled local reminders |

### UI & Animations

| Package | Purpose |
|---|---|
| `fl_chart` | Interactive charts (pie, bar, line) |
| `flutter_animate` | Declarative animations |

### Code Generation (dev)

| Package | Purpose |
|---|---|
| `isar_generator` | Isar collection schema generation |
| `build_runner` | Code generation runner |
| `riverpod_generator` | Riverpod provider code generation |

---

## Theme System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| **Background** | `#0B0F1A` | Scaffold & main background |
| **Surface** | `#131A2A` | Cards, sheets, dialogs |
| **Primary Accent** | `#7B61FF` | Buttons, highlights, active states |
| **Secondary Accent** | `#00C2FF` | Charts, links, secondary indicators |

### Material 3 Configuration

- `useMaterial3: true`
- Dark theme only (no light mode toggle)
- Custom `ColorScheme.dark()` with Kosh palette
- Typography uses `GoogleFonts` or system fonts
- All surfaces use the dark palette for a futuristic aesthetic

### Files

| File | Responsibility |
|---|---|
| `app_colors.dart` | Static color constants (`Color` values) |
| `app_theme.dart` | `ThemeData` construction with Material 3 |
| `app_text_styles.dart` | `TextStyle` definitions (headings, body, captions) |

---

## Feature Modules

Each feature follows the identical MVVM sub-structure:

```
feature_name/
├── view/              # Screen / Page widgets
├── viewmodel/         # StateNotifier / Notifier classes
├── widgets/           # Feature-local reusable widgets
└── models/            # Feature-local data models / DTOs
```

### Module Overview

| Module | Description |
|---|---|
| **Dashboard** | Home screen with balance summary, recent transactions, goal progress |
| **Transactions** | Full transaction list with filters, search, add/edit/delete |
| **Goals** | Financial goal creation, tracking, progress visualization |
| **Analytics** | Spending breakdown, income vs expenses, trends (fl_chart) |
| **Investments** | Portfolio overview, individual holdings, gain/loss tracking |
| **Gamification** | Achievement badges, streaks, financial health score |
| **Vision Board** | Visual goal board with images and milestones |
| **Settings** | Currency, notifications, biometric toggle, data export |

---

## Data Flow

```
User Interaction
       │
       ▼
   ┌───────┐
   │ View  │  ── reads state from ──▶  Riverpod Provider
   └───┬───┘                                  │
       │ calls method                         │ exposes
       ▼                                      │
 ┌───────────┐                          ┌─────────────┐
 │ ViewModel │ ◀── state notifier ────▶ │  Provider    │
 └─────┬─────┘                          └─────────────┘
       │ calls
       ▼
 ┌──────────────┐
 │  Repository  │
 └──────┬───────┘
        │ CRUD
        ▼
 ┌─────────────┐
 │ Isar Database│
 └─────────────┘
```

### Sensitive Data Flow

```
PIN / Biometric Config
       │
       ▼
 ┌──────────────────────┐
 │ Secure Storage Service│  (Flutter Secure Storage)
 └──────────────────────┘
       │
       ▼
 ┌──────────────────┐
 │ Auth Service      │  (Local Auth)
 └──────────────────┘
```

---

## File Responsibilities

### `main.dart`
- App entry point
- Isar database initialization
- `ProviderScope` setup with overrides
- `runApp(const KoshApp())`

### `app/kosh_app.dart`
- Root `MaterialApp.router` widget
- Applies `AppTheme.darkTheme`
- Injects `GoRouter` configuration

### `app/router/app_router.dart`
- `GoRouter` instance with all route definitions
- `ShellRoute` wrapping bottom navigation
- Route guards (e.g., biometric check on launch)

### `database/isar_service.dart`
- Opens Isar instance with all collection schemas
- Provides singleton access to the database
- Handles migration logic

### `providers/`
- `database_providers.dart` — Isar instance provider
- `repository_providers.dart` — All repository providers (depend on DB)
- `service_providers.dart` — Notification, auth, secure storage providers

### `core/errors/`
- `app_exception.dart` — Base `AppException` class
- `failures.dart` — Typed failure classes (DatabaseFailure, ValidationFailure, etc.)
- `error_handler.dart` — Global `FlutterError.onError` and zone-guarded error catching

---

## Development Guidelines

### Adding a New Feature

1. Create folder under `lib/features/<feature_name>/`
2. Add `view/`, `viewmodel/`, `widgets/`, `models/` subdirectories
3. Create the view (screen widget)
4. Create the viewmodel (extends `StateNotifier` or uses `@riverpod`)
5. If new data is needed, add Isar collection in `database/collections/`
6. Add repository in `database/repositories/`
7. Register providers in `providers/`
8. Add route in `app/router/app_router.dart`

### Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | `snake_case` | `dashboard_view.dart` |
| Classes | `PascalCase` | `DashboardViewModel` |
| Variables | `camelCase` | `totalBalance` |
| Constants | `camelCase` | `primaryAccent` |
| Providers | `camelCase` + `Provider` suffix | `dashboardViewModelProvider` |
| Routes | `camelCase` | `dashboardRoute` |

### Code Generation

```bash
# Run build_runner for Isar & Riverpod codegen
dart run build_runner build --delete-conflicting-outputs
```

### Key Rules

- ✅ All state through Riverpod — no `setState()` except for local widget state
- ✅ All navigation through GoRouter — no `Navigator.push()`
- ✅ All persistence through Isar — no SharedPreferences for data
- ✅ All sensitive storage through Flutter Secure Storage
- ✅ Feature folders are self-contained — no cross-feature imports between views
- ❌ No network calls — this is an offline-only app
- ❌ No Firebase — no analytics, no crashlytics, no auth
- ❌ No backend API — all data is local

---

## File Count Summary

| Directory | Files | Purpose |
|---|---|---|
| `app/` | 4 | App shell, router, theme |
| `core/constants/` | 3 | App-wide constants |
| `core/utils/` | 3 | Utility functions |
| `core/services/` | 3 | Platform services |
| `core/widgets/` | 4 | Reusable UI components |
| `core/extensions/` | 4 | Dart extension methods |
| `core/errors/` | 3 | Error handling |
| `database/` | 9 | Isar DB, collections, repositories |
| `models/` | 5 | Shared data models |
| `providers/` | 3 | Riverpod DI providers |
| `features/` | 16+ | 8 feature modules (view + viewmodel each) |
| `shared/` | 4 dirs | Cross-feature shared UI components |
| **Total** | **~60+** | **Foundation scaffold** |

---

> 🚀 **Status**: Project structure scaffolded. All files are empty placeholders ready for implementation.
