# Mapia — yet another rest api client for Desktop

Mapia is a modern, cross-platform REST API client built with **Flutter**, designed for professional developers who need a powerful yet lightweight tool for testing and debugging APIs.

## 🚀 Features
...
- **Dynamic Themes**: Sleek dark and light modes using Material 3.

## 📥 Downloads & Installation

Download version **v1.0.44** of Mapia for your operating system:

| Platform | Installer / Archive |
| --- | --- |
| **🪟 Windows** | [**Download .exe**](https://github.com/allensandiego/mapia/releases/download/v1.0.44/mapia-windows-x64.exe) \| [**Download .msix**](https://github.com/allensandiego/mapia/releases/download/v1.0.44/mapia-windows-x64.msix) |
| **🍎 macOS** | [**Download .dmg**](https://github.com/allensandiego/mapia/releases/download/v1.0.44/mapia-1.0.41+1-macos.dmg) |
| **🐧 Linux** | [**Download .AppImage**](https://github.com/allensandiego/mapia/releases/download/v1.0.44/mapia-1.0.41+1-linux.AppImage) \| [**Download .deb**](https://github.com/allensandiego/mapia/releases/download/v1.0.44/mapia-1.0.41+1-linux.deb) \| [**Download .rpm**](https://github.com/allensandiego/mapia/releases/download/v1.0.44/mapia-1.0.41+1-1.x86_64.rpm) |

For all other versions, visit the **[Latest Releases](https://github.com/allensandiego/mapia/releases)** page on GitHub.

### 🪟 Windows
1. Download the `mapia-windows-x64.exe` or `msix`.
2. For `.exe`, run it to launch the application.
3. For `.msix`, double-click to install.

### 🍎 macOS
1. Download the `mapia-macos.dmg`.
2. Open the disk image and drag **Mapia.app** to your **Applications** folder.
3. If prompted by macOS Gatekeeper, you may need to right-click open the app for the first time.

### 🐧 Linux
1. Download the `.AppImage`, `.deb`, or `.rpm`.
2. For **AppImage**: `chmod +x mapia-linux-x86_64.AppImage` and run it.
3. For **DEB**: `sudo dpkg -i mapia-linux-amd64.deb`
4. For **RPM**: `sudo rpm -i mapia-linux-x86_64.rpm`

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
