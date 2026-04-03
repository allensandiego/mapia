# Mapia — REST API client for Desktop

Mapia is a modern, cross-platform REST API client built with **Flutter**, designed for professional developers who need a powerful yet lightweight tool for testing and debugging APIs.

## 🚀 Features

- **Full HTTP Method Support**: GET, POST, PUT, DELETE, PATCH, HEAD, and OPTIONS.
- **Advanced Request Editor**:
    - **Header & Parameter Management**: Tab-based editors with autocompletion.
    - **Authorization**: Comprehensive support for Basic Auth, Bearer Tokens, API Keys, and **OAuth2** (Client Credentials, Auth Code, Password, Implicit) with auto-refresh.
    - **Multi-type Body Support**: JSON, XML, HTML, Form-data, x-www-form-urlencoded, and Binary payloads.
- **Environment Management**:
    - Manage multiple environments and switch seamlessly.
    - Resolve variables using `{{variable}}` syntax in URLs, headers, and bodies.
    - Hover over variables to see resolved values instantly.
- **Powerful Response Viewer**:
    - **Pretty View**: Syntax highlighting for JSON, XML, and HTML (using atom-one-dark theme).
    - **Rendered View**: Preview HTML responses directly.
    - **Metadata Tracking**: Detailed status codes, response time, and payload size.
- **Organization & History**:
    - **Collections & Folders**: Organize requests into logical groupings.
    - **History Tracking**: Search and filter past requests by method or status code range.
- **Developer Productivity**:
    - **Code Snippets**: Generate snippets for cURL, Python (Requests), JavaScript (Fetch/Axios), and Dart (Dio).
    - **Keyboard Shortcuts**: Power-user shortcuts for sending, saving, and tab management.
    - **Dynamic Themes**: Sleek dark and light modes using Material 3.

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
This project is for internal use/demonstration purposes. Refer to the `LICENSE` file (if available) for more details.
