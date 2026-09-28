# DevHub Showcase

A cross-platform mobile application built with **Flutter & Dart** as part of the Semester VI Mobile Application Development curriculum. DevHub lets you log, organise, and showcase your development projects — with live GitHub integration, analytics, and a clean Material 3 UI.

---

## Screens & Features

### Splash Screen

* Animated logo with scale + fade transition
* Auto-navigates based on onboarding state

### Onboarding Screen

* 3-page swipeable intro for first-time users
* Dot indicator, skip button
* State persisted via `shared_preferences`

### Projects Feed

* View all logged projects as cards
* **Search** by name, tech stack, or author
* **Filter** by category (AI/ML, Web Dev, Mobile App, Data Science, DevOps)
* Colour-coded category strips and status badges
* Star/unstar projects
* Tap any card to open full detail view

### Add Project

* Form with validation to log a new project
* Fields: title, author, category, status, tech stack, GitHub URL, description
* Auto-saves to local storage

### Project Detail

* Hero gradient header with category colour
* Tech stack rendered as individual chips
* Open GitHub repo in browser via `url_launcher`
* Delete project with confirmation dialog
* Copy tech stack to clipboard

### Analytics

* Total projects, total stars, completed, in-progress counts
* Completion rate progress bar
* Category breakdown bar chart
* Status breakdown bar chart
* Top starred projects list

### GitHub Integration

* Search any GitHub username
* Fetches live profile — avatar, bio, followers, repo count
* Lists all public repos with language colour dot, stars, fork badge
* **Import** any repo directly into your local projects feed
* Auto-detects category from repo language

### Profile

* Editable profile — name, bio, email, GitHub
* Dark / Light mode toggle (persisted)
* Project count stat
* App version info

---

## Tech Stack

| Layer            | Technology                              |
| ---------------- | --------------------------------------- |
| Framework        | Flutter 3.x                             |
| Language         | Dart 3.x                                |
| State Management | `setState` + `StatefulWidget`           |
| Local Storage    | `shared_preferences`                    |
| HTTP / API       | `http` package — GitHub REST API v3     |
| Navigation       | Flutter Navigator 2.0                   |
| Fonts            | `google_fonts` — Inter                  |
| URL Handling     | `url_launcher`                          |
| Date Formatting  | `intl`                                  |
| Theming          | Material 3 with full dark/light support |

---

## Project Structure

```text
lib/

├── main.dart                  # App entry point, theme setup
├── theme/
│   └── app_theme.dart         # Light & dark Material 3 themes
├── models/
│   └── project.dart           # Project model, enums, copyWith
├── services/
│   ├── storage_service.dart   # SharedPreferences CRUD + seed data
│   └── github_service.dart    # GitHub REST API calls
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── main_shell.dart        # Bottom nav shell
│   ├── feed_screen.dart       # Projects list + search/filter
│   ├── add_project_screen.dart
│   ├── detail_screen.dart
│   ├── analytics_screen.dart
│   ├── github_screen.dart     # Live GitHub repo browser
│   └── profile_screen.dart
└── widgets/
    └── project_card.dart      # Reusable project card widget
```

---

## Installation & Setup

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or above)
* [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
* [Git](https://git-scm.com)
* A browser (for web) or Android emulator / physical device

### Steps

**1. Clone the repository**

```bash
git clone https://github.com/Pulkit/devhub-flutter.git
cd devhub-flutter
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Run on Chrome (web)**

```bash
flutter run -d chrome
```

**4. Run on Android emulator**

```bash
flutter emulators --launch <emulator_id>
flutter run
```

**5. Run on a physical Android device**

* Enable Developer Options and USB Debugging on your phone
* Connect via USB

```bash
flutter devices
flutter run -d <device_id>
```

**6. Build a release APK**

```bash
flutter build apk --release
```

APK will be at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.3.2
  google_fonts: ^6.2.1
  url_launcher: ^6.3.0
  http: ^1.2.0
  intl: ^0.19.0
```

---

## GitHub API

This app uses the **GitHub REST API v3** (public, no auth required):

| Endpoint                      | Usage                     |
| ----------------------------- | ------------------------- |
| `GET /users/{username}`       | Fetch user profile        |
| `GET /users/{username}/repos` | Fetch public repositories |

> Note: Unauthenticated requests are limited to **60 requests/hour** per IP by GitHub.

---
