# SwiftDependencyInjection

![Swift](https://img.shields.io/badge/Swift-6-orange.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![Tests](https://github.com/squeaky-nose/SwiftDependencyInjection/actions/workflows/tests.yml/badge.svg)
![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)
![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)
![tvOS](https://img.shields.io/badge/tvOS-15%2B-blue.svg)
![watchOS](https://img.shields.io/badge/watchOS-8%2B-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A lightweight, type-safe dependency injection container for Swift.

> Designed to be simple, fast, and predictable — with minimal API surface and no external dependencies.

## 🚀 Quick Example

```swift
import SwiftDependencyInjection

let container = DependencyContainer()

container.register(Analytics.self, registration: .singleton) {
    AnalyticsImpl()
}

let analytics: Analytics = container.resolveRequired()
```

## 🤔 Why SwiftDependencyInjection?

Most dependency injection frameworks for Swift are either:
- overly complex
- rely on runtime magic
- or introduce unnecessary abstractions

SwiftDependencyInjection focuses on:
- explicit registration
- predictable lifecycles
- zero hidden behavior

It’s designed for developers who want simple, maintainable dependency injection without the overhead.

---

## ✨ Features

- 🧠 Type-safe resolution using Swift generics
- 🔁 Lazy singletons (created once, cached forever)
- 🏭 Factory registrations (new instance every time)
- 🏷 Named registrations for multiple implementations
- ⚡ Zero dependencies
- 🧪 Test-friendly with injectable failure handling

---

## 📦 Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/squeaky-nose/SwiftDependencyInjection", from: "0.1.0")
```

## 🚀 Getting Started

### 1. Create a container

```swift
import SwiftDependencyInjection

let container = DependencyContainer()
```

### 2. Register dependencies

#### Singleton (lazy)
```swift
container.register(Networking.self, registration: .singleton) {
    LiveNetworking()
}
```

- Created on first resolve
- Cached for all future resolves

#### Factory

```swift
container.register(DateFormatter.self, registration: .factory) {
    DateFormatter()
}
```

- New instance every time

### 3. Resolve dependencies

#### Optional resolve

```swift
let networking: Networking? = container.resolve()
```

#### Required resolve

```swift
let networking: Networking = container.resolveRequired()
```

- Crashes if missing (use for required dependencies)

## 🧩 Advanced Usage

### 🏷️ Named Registrations

Register multiple implementations of the same type:

```swift
container.register(APIClient.self, name: "prod", registration: .singleton) {
    ProductionAPIClient()
}

container.register(APIClient.self, name: "mock", registration: .singleton) {
    MockAPIClient()
}
```

Resolve:

```swift
let client = container.resolve(APIClient.self, name: "prod")
```

### 🧪 Testing

You can inject a custom failure handler to intercept missing dependencies during tests:

```swift
let container = DependencyContainer { serviceType, name in
    assertionFailure("Missing dependency: \(serviceType)")
    fatalError() // still required (Never-returning)
}
```

## 🧠 Design Goals

The philosophy of this library is that simple dependency injection is better than clever dependency injection.

This library intentionally avoids:
- ❌ Reflection
- ❌ Magic / hidden injection
- ❌ Global state
- ❌ Complex scopes

Instead, it focuses on:
- ✅ Explicit registration
- ✅ Predictable behavior
- ✅ Minimal API
- ✅ Performance

## ⚠️ Thread Safety

The current version of DependencyContainer is not thread-safe.

It is intended to be:
- Configured during app startup
- Used from a single execution context (e.g. main thread)

Lazy singletons are not guaranteed to be created only once under concurrent access.

## 💡 Usage in SwiftUI

Inject your container via environment:

```swift
.environment(\.resolver, container)
```

Then access it:

```swift
@Environment(\.resolver) private var resolver
```

## 📐 Example

```swift
protocol Analytics {
    func track(event: String)
}

final class AnalyticsImpl: Analytics {
    func track(event: String) {
        print("Tracked:", event)
    }
}

let container = DependencyContainer()

container.register(Analytics.self, registration: .singleton) {
    AnalyticsImpl()
}

let analytics: Analytics = container.resolveRequired()
analytics.track(event: "app_open")
```

## 📄 License

This project is licensed under the MIT License.

## 🙌 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
