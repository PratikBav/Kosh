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
├── app/
│   ├── router/
│   │   ├── app_router.dart
│   │   └── navigation_shell.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── kosh_app.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── route_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_handler.dart
│   ├── services/
│   │   ├── analytics_calculator_service.dart
│   │   ├── backup_service.dart
│   │   ├── biometric_service.dart
│   │   ├── finance_calculator_service.dart
│   │   ├── gamification_service.dart
│   │   ├── goal_calculator_service.dart
│   │   ├── key_value_store.dart
│   │   ├── notification_service.dart
│   │   ├── pin_service.dart
│   │   ├── screen_security_service.dart
│   │   ├── secure_storage_service.dart
│   │   └── security_service.dart
│   └── utils/
│       ├── change_debouncer.dart
│       └── currency_utils.dart
├── database/
│   ├── collections/
│   │   ├── achievement_collection.dart
│   │   ├── app_settings_collection.dart
│   │   ├── contribution_collection.dart
│   │   ├── goal_collection.dart
│   │   ├── security_settings_collection.dart
│   │   ├── streak_collection.dart
│   │   ├── transaction_collection.dart
│   │   ├── user_progress_collection.dart
│   │   ├── vision_item_collection.dart
│   │   └── xp_record_collection.dart
│   ├── repositories/
│   │   ├── goals_repository.dart
│   │   └── transaction_repository.dart
│   └── isar_service.dart
├── features/
│   ├── analytics/
│   │   ├── models/
│   │   │   ├── analytics_summary.dart
│   │   │   ├── category_summary.dart
│   │   │   ├── goal_analytics.dart
│   │   │   └── monthly_summary.dart
│   │   ├── repository/
│   │   │   └── analytics_repository.dart
│   │   ├── view/
│   │   │   └── analytics_screen.dart
│   │   ├── viewmodel/
│   │   │   ├── analytics_state.dart
│   │   │   └── analytics_viewmodel.dart
│   │   └── widgets/
│   │       ├── analytics_summary_card.dart
│   │       ├── category_breakdown_tile.dart
│   │       ├── pie_chart_card.dart
│   │       └── trend_chart_card.dart
│   ├── dashboard/
│   │   ├── models/
│   │   │   └── dashboard_summary.dart
│   │   ├── repository/
│   │   │   └── dashboard_repository.dart
│   │   ├── view/
│   │   │   └── dashboard_screen.dart
│   │   ├── viewmodel/
│   │   │   ├── dashboard_state.dart
│   │   │   └── dashboard_viewmodel.dart
│   │   └── widgets/
│   │       ├── activity_feed.dart
│   │       ├── daily_motivation_card.dart
│   │       ├── dashboard_hero_header.dart
│   │       ├── goal_spotlight_card.dart
│   │       ├── quick_actions_row.dart
│   │       ├── section_header.dart
│   │       ├── streak_progress_card.dart
│   │       └── wealth_health_ring.dart
│   ├── gamification/
│   │   ├── models/
│   │   ├── repository/
│   │   │   └── gamification_repository.dart
│   │   ├── view/
│   │   │   ├── achievements_screen.dart
│   │   │   └── profile_progress_screen.dart
│   │   ├── viewmodel/
│   │   │   ├── gamification_state.dart
│   │   │   └── gamification_viewmodel.dart
│   │   └── widgets/
│   │       ├── achievement_card.dart
│   │       └── xp_progress_bar.dart
│   ├── goals/
│   │   ├── models/
│   │   │   ├── goal_category.dart
│   │   │   └── goal_priority.dart
│   │   ├── view/
│   │   │   ├── add_contribution_screen.dart
│   │   │   ├── add_goal_screen.dart
│   │   │   ├── goal_details_screen.dart
│   │   │   └── goals_view.dart
│   │   ├── viewmodel/
│   │   │   ├── goal_details_state.dart
│   │   │   ├── goal_details_viewmodel.dart
│   │   │   ├── goals_state.dart
│   │   │   └── goals_viewmodel.dart
│   │   └── widgets/
│   │       ├── contribution_tile.dart
│   │       ├── goal_card.dart
│   │       ├── goal_progress_ring.dart
│   │       └── goal_summary_card.dart
│   ├── onboarding/
│   │   └── view/
│   │       └── onboarding_screen.dart
│   ├── security/
│   │   ├── repository/
│   │   │   └── security_repository.dart
│   │   ├── view/
│   │   │   ├── app_lock_screen.dart
│   │   │   ├── backup_screen.dart
│   │   │   ├── pin_prompt_screen.dart
│   │   │   ├── pin_setup_screen.dart
│   │   │   ├── privacy_settings_screen.dart
│   │   │   └── security_settings_screen.dart
│   │   ├── viewmodel/
│   │   │   ├── security_state.dart
│   │   │   └── security_viewmodel.dart
│   │   └── widgets/
│   │       └── pin_pad.dart
│   ├── settings/
│   │   ├── models/
│   │   ├── view/
│   │   │   ├── appearance_settings_screen.dart
│   │   │   └── settings_view.dart
│   │   ├── viewmodel/
│   │   │   └── theme_viewmodel.dart
│   │   └── widgets/
│   ├── transactions/
│   │   ├── models/
│   │   │   ├── transaction_category.dart
│   │   │   └── transaction_type.dart
│   │   ├── view/
│   │   │   ├── add_transaction_screen.dart
│   │   │   ├── transaction_details_screen.dart
│   │   │   └── transactions_view.dart
│   │   ├── viewmodel/
│   │   │   ├── transaction_state.dart
│   │   │   └── transaction_viewmodel.dart
│   │   └── widgets/
│   │       ├── filter_sheet.dart
│   │       └── transaction_card.dart
│   └── vision_board/
│       ├── models/
│       ├── repository/
│       │   └── vision_board_repository.dart
│       ├── view/
│       │   ├── create_vision_item_screen.dart
│       │   ├── vision_board_screen.dart
│       │   └── vision_item_detail_screen.dart
│       ├── viewmodel/
│       │   ├── motivation_viewmodel.dart
│       │   ├── vision_board_state.dart
│       │   └── vision_board_viewmodel.dart
│       └── widgets/
│           ├── quote_card.dart
│           └── vision_card.dart
├── providers/
│   ├── database_providers.dart
│   ├── repository_providers.dart
│   ├── router_provider.dart
│   ├── service_providers.dart
│   └── theme_provider.dart
├── shared/
│   ├── animations/
│   ├── cards/
│   │   └── kosh_card.dart
│   ├── dialogs/
│   └── widgets/
│       ├── empty_state.dart
│       ├── kosh_button.dart
│       ├── kosh_textfield.dart
│       └── loading_indicator.dart
└── main.dart
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
| **Gamification** | Achievement badges, streaks, financial health score |
| **Vision Board** | Visual goal board with images and milestones |
| **Security** | PIN lock, biometric unlock, auto-lock, backup and restore |
| **Settings** | Appearance, accent colour, data export |

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
- `service_providers.dart` — Notification, PIN, screen security, secure storage providers

### `core/errors/`
- `app_exception.dart` — `AppException` and its typed subclasses (`DatabaseException`,
  `ValidationException`, `StorageException`, …), thrown by services and unwrapped
  by the UI so users see `message` rather than the type and code
- `error_handler.dart` — Global `FlutterError.onError` and zone-guarded error
  catching, installed in `main()`

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
| Files | `snake_case` | `dashboard_screen.dart` |
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
