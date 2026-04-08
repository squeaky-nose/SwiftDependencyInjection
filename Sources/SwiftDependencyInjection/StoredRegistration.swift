//
//  StoredRegistration.swift
//  SwiftDependencyInjection
//
//  Created by Sushant Verma on 8/4/2026.
//


/// Internal storage representation of a registration.
enum StoredRegistration {
    /// Lazy singleton builder (not yet created).
    case singletonBuilder(() -> Any)

    /// Cached singleton instance.
    case singletonInstance(Any)

    /// Factory builder (creates a new instance on every resolve).
    case factory(() -> Any)
}
