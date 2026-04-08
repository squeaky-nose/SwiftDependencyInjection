//
//  DependencyContainer.swift
//  SwiftDependencyInjection
//
//  Created by Sushant Verma on 7/4/2026.
//

import Foundation

/// A lightweight dependency injection container.
///
/// Supports:
/// - Lazy singletons, created on first resolve and cached for future resolves
/// - Factories, which create a new instance each time they are resolved
/// - Named registrations for multiple implementations of the same type
///
/// Services are identified by their type and an optional name.
///
/// - Note:
///   `DependencyContainer` is not thread-safe. Registrations and resolutions are
///   expected to occur from a single execution context, such as during app startup
///   or on the main thread.
public final class DependencyContainer {

    /// The handler invoked when `resolveRequired` cannot find a matching registration.
    ///
    /// The default implementation terminates execution with `fatalError`, but a custom
    /// handler can be provided to support alternative behavior in tests or other environments.
    private let onMissingRequiredDependency: (Any.Type, String?) -> Never

    /// Internal storage for registered services.
    private var registeredServices: [Qualifier: StoredRegistration] = [:]

    /// Creates a new empty dependency container.
    ///
    /// - Parameter onMissingRequiredDependency:
    ///   The handler invoked when a required dependency cannot be resolved.
    ///   Defaults to `DependencyContainer.defaultMissingDependencyHandler`.
    public init(
        onMissingRequiredDependency: @escaping (Any.Type, String?) -> Never = DependencyContainer.defaultMissingDependencyHandler
    ) {
        self.onMissingRequiredDependency = onMissingRequiredDependency
    }

    /// The default handler used when `resolveRequired` fails to find a matching registration.
    ///
    /// - Parameters:
    ///   - serviceType: The type that was requested.
    ///   - name: The optional registration name used during lookup.
    ///
    /// - Important:
    ///   This method always terminates execution with `fatalError`.
    public static func defaultMissingDependencyHandler(
        serviceType: Any.Type,
        name: String?
    ) -> Never {
        fatalError("DependencyContainer: Missing registration for \(serviceType) (name: \(name ?? "nil"))")
    }

    /// Registers a service with the container.
    ///
    /// - Parameters:
    ///   - serviceType: The type that will be used to resolve the service, typically a protocol or abstraction.
    ///   - name: An optional identifier used to distinguish multiple registrations of the same type.
    ///   - registration: The lifecycle of the service.
    ///   - resolve: A closure that creates the service instance.
    ///
    /// - Behavior:
    ///   - `.single`: The closure is stored and executed once on first resolve. The resulting instance is then cached.
    ///   - `.factory`: The closure is executed every time the service is resolved.
    public func register<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        registration: Registration,
        resolve: @escaping () -> Service
    ) {
        let qualifier = Qualifier(serviceType: serviceType, name: name)

        switch registration {
        case .singleton:
            registeredServices[qualifier] = .singletonBuilder(resolve)
        case .factory:
            registeredServices[qualifier] = .factory(resolve)
        }
    }

    /// Resolves a service from the container.
    ///
    /// - Parameters:
    ///   - serviceType: The type of service to resolve.
    ///   - name: An optional identifier used during registration.
    ///
    /// - Returns:
    ///   The resolved service instance, or `nil` if no matching registration exists.
    ///
    /// - Behavior:
    ///   - `.single`: The instance is created once, cached, and reused for future resolves.
    ///   - `.factory`: A new instance is created on every resolve.
    public func resolve<Service>(
        _ serviceType: Service.Type,
        name: String? = nil
    ) -> Service? {
        let qualifier = Qualifier(serviceType: serviceType, name: name)

        guard let registration = registeredServices[qualifier] else {
            return nil
        }

        switch registration {
        case let .singletonInstance(instance):
            return instance as? Service

        case let .singletonBuilder(builder):
            let instance = builder()
            registeredServices[qualifier] = .singletonInstance(instance)
            return instance as? Service

        case .factory(let builder):
            return builder() as? Service
        }
    }

    /// Resolves a service using type inference.
    ///
    /// - Parameter name: An optional identifier used during registration.
    ///
    /// - Returns:
    ///   The resolved service instance, or `nil` if no matching registration exists.
    ///
    /// - Note:
    ///   The expected return type must be known at the call site.
    ///
    ///   ```swift
    ///   let service: MyService? = container.resolve()
    ///   ```
    public func resolve<Service>(name: String? = nil) -> Service? {
        resolve(Service.self, name: name)
    }

    /// Resolves a required service from the container.
    ///
    /// - Parameters:
    ///   - serviceType: The type of service to resolve.
    ///   - name: An optional identifier used during registration.
    ///
    /// - Returns:
    ///   The resolved service instance.
    ///
    /// - Important:
    ///   If no matching registration exists, `onMissingRequiredDependency` is invoked.
    ///   By default, this terminates execution with `fatalError`.
    public func resolveRequired<Service>(
        _ serviceType: Service.Type,
        name: String? = nil
    ) -> Service {
        guard let service: Service = resolve(serviceType, name: name) else {
            onMissingRequiredDependency(serviceType, name)
        }
        return service
    }

    /// Resolves a required service using type inference.
    ///
    /// - Parameter name: An optional identifier used during registration.
    ///
    /// - Returns:
    ///   The resolved service instance.
    ///
    /// - Important:
    ///   If no matching registration exists, `onMissingRequiredDependency` is invoked.
    ///   By default, this terminates execution with `fatalError`.
    ///
    /// - Note:
    ///   The expected return type must be known at the call site.
    ///
    ///   ```swift
    ///   let service: MyService = container.resolveRequired()
    ///   ```
    public func resolveRequired<Service>(name: String? = nil) -> Service {
        guard let service: Service = resolve(name: name) else {
            onMissingRequiredDependency(Service.self, name)
        }
        return service
    }
}
