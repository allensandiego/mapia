# Mapia — yet another rest api client for Desktop

Mapia is a modern, cross-platform REST API client built with **Flutter**, designed for professional developers who need a powerful yet lightweight tool for testing and debugging APIs.

## 🚀 Features
...
- **Dynamic Themes**: Sleek dark and light modes using Material 3.

## 📥 Downloads & Installation

To use Mapia on your desktop, visit the **[Latest Releases](https://github.com/allensandiego/mapia/releases)** page on GitHub and download the package for your operating system.

### 🪟 Windows
1. Download the `mapia-windows-x64.zip`.
2. Extract the content to a folder of your choice.
3. Run `mapia.exe` to launch the application.

### 🍎 macOS
1. Download the `Mapia.dmg`.
2. Open the disk image and drag **Mapia.app** to your **Applications** folder.
3. If prompted by macOS Gatekeeper, you may need to right-click open the app for the first time.

### 🐧 Linux
1. Download the `mapia-linux-x64.tar.gz`.
2. Extract the archive: `tar -xzf mapia-linux-x64.tar.gz`.
3. Run the executable: `./mapia`.

## 🛠️ Tech Stack

- **Framework**: [Flutter 3.x](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio)
- **Local Storage**: JSON-based persistence via `path_provider`
- **Syntax Highlighting**: `flutter_highlight`
- **Window Management**: `window_manager`

## 🏗️ Architecture

Mapia follows **Clean Architecture** principles to ensure maintainability and testability:
- **Presentation Layer**: UI widgets and Riverpod providers.
- **Domain Layer**: Business logic entities and repository interfaces.
- **Data Layer**: Repository implementations and external services (HTTP Service).

## 🚦 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.3.0)
- Desktop-specific dependencies (depending on your OS).

### Running Locally
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run -d <your-os-linux/windows/macos>
   ```

## 🗺️ Roadmap
- [ ] Collection Import/Export (JSON/Postman v2.1).
- [ ] Environment Import/Export.
- [ ] Drag-and-drop reordering in Collection Tree.

## 📄 License
This project is licensed under the GNU Affero General Public License v3.0. Refer to the `LICENSE` file for details.
