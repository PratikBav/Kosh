# Kosh 🚀

> A futuristic, dark-theme personal finance and financial goal tracking application built for speed, privacy, and absolute control.

Kosh is designed to be **100% offline-first**. No backends. No cloud sync. No AI features. No social integrations. Your data never leaves your device. 

## ✨ Key Features (Roadmap)

*   [x] **Transactions Module:** Full local CRUD operations for income and expenses with dynamic filtering and advanced search.
*   [ ] **Dashboard:** A bird's-eye view of your financial health, recent transactions, and goal progress.
*   [ ] **Financial Goals:** Create custom savings goals, track contributions, and visually monitor your progress.
*   [ ] **Advanced Analytics:** Interactive charts and graphs powered by `fl_chart` to visualize spending trends over time.
*   [ ] **Biometric Security:** Secure your data locally using fingerprint or Face ID via `local_auth`.
*   [ ] **Gamification & Achievements:** Earn badges and level up your financial discipline.

## 🛠 Tech Stack & Architecture

Kosh is built on a highly scalable, modular foundation:

*   **Framework:** Flutter (Material 3)
*   **Architecture:** MVVM (Model-View-ViewModel) with a Feature-First folder structure.
*   **State Management & DI:** Riverpod (`flutter_riverpod`)
*   **Routing:** GoRouter (`go_router`) with `StatefulShellRoute` for persistent bottom navigation.
*   **Local Database:** Isar Database (`isar`) for lightning-fast, fully local NoSQL storage.
*   **Security:** `flutter_secure_storage` & `local_auth`.
*   **Animations:** `flutter_animate` & `lottie` for dynamic, buttery-smooth UI interactions.

## 📁 Project Structure

```text
lib/
 ├── app/              # App shell, routing (GoRouter), and global theming
 ├── core/             # App-wide constants, global services, utility extensions, error handling
 ├── database/         # Isar collections, repository implementations, and database initialization
 ├── features/         # Feature-first modules (dashboard, transactions, goals, analytics, settings)
 │    └── [feature]/
 │         ├── models/
 │         ├── view/
 │         ├── viewmodel/
 │         └── widgets/
 ├── providers/        # Global Riverpod providers (database_providers, repository_providers)
 ├── shared/           # Cross-feature reusable UI components (KoshCard, KoshButton, etc.)
 └── main.dart         # Entry point and dependency injection bootstrap
```

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (v3.19 or higher recommended)
*   Android Studio / Xcode for emulators

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/PratikBav/Kosh.git
    cd Kosh
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

3.  Generate Isar Database schemas and routing code:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  Run the app:
    ```bash
    flutter run
    ```

## 🎨 Design Philosophy
Kosh strictly adheres to a **premium, dark futuristic aesthetic**. 
*   **Background:** `#0B0F1A`
*   **Surfaces:** `#131A2A`
*   **Primary Accent:** `#7B61FF` (Neon Purple)
*   **Secondary Accent:** `#00C2FF` (Cyan)

Animations and micro-interactions are treated as first-class citizens to ensure the app feels "alive" and responsive.

---
*Built with ❤️ using Flutter.*
