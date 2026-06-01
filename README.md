# Kosh

**Kosh** is an offline-first, futuristic finance tracking app built with Flutter.

## Features

- **Offline First**: All data is stored locally on the device using Isar. No cloud sync, no tracking, complete privacy.
- **Transactions Management**: Track your income and expenses effortlessly.
- **Financial Goals**: Set custom targets, track deadlines, and monitor your progress using dedicated contributions.
- **Dynamic Theming**: Enjoy a beautiful, glassmorphic dark-mode design system.

## Architecture

Kosh follows a clean, offline-first MVVM architecture using Riverpod for state management:

- **UI / Views**: Presentation layer using standard Flutter widgets combined with custom dynamic Kosh components.
- **ViewModels (Riverpod)**: Encapsulate business logic, bridge the UI and Repository layers.
- **Repositories**: Handle Data CRUD operations ensuring transaction boundaries.
- **Models / Database (Isar)**: Optimized NoSQL schemas for incredibly fast local-first read/writes.

### Current Modules:
- **Transactions**: Add, edit, remove, and list transactions by category.
- **Goals**: Create goals, see target completion rings, make contributions to goals, track statistics (Monthly req, completion dates).

## Getting Started

1. Clone the repository.
2. Run `flutter pub get`.
3. Generate Isar models using `dart run build_runner build -d`.
4. Run the app on an emulator or physical device.

## Technologies Used
- Flutter (UI Toolkit)
- Isar (Local Database)
- Riverpod (State Management)
- GoRouter (Navigation)
