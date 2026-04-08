//
//  Qualifier.swift
//  SwiftDependencyInjection
//
//  Created by Sushant Verma on 7/4/2026.
//

import Foundation

/// A unique key used to identify a registered service within the container.
///
/// A `Qualifier` combines the service type with an optional name, allowing
/// multiple registrations of the same type to coexist under different identifiers.
///
/// - Note:
///   Two qualifiers are considered equal when both their `serviceType` and `name` match.
internal struct Qualifier {
    /// The type used to resolve the service.
    internal let serviceType: Any.Type

    /// An optional identifier used to distinguish multiple registrations
    /// of the same service type.
    internal let name: String?
}

extension Qualifier: Hashable {

    /// Computes a hash value for the qualifier.
    ///
    /// The hash is derived from the identity of the service type and the optional name.
    ///
    /// - Note:
    ///   `ObjectIdentifier` is used to uniquely identify the metatype (`Any.Type`),
    ///   since metatypes do not conform to `Hashable` directly.
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(serviceType).hash(into: &hasher)
        name?.hash(into: &hasher)
    }

    /// Determines equality between two qualifiers.
    ///
    /// Two qualifiers are equal if:
    /// - They reference the same `serviceType`
    /// - They have the same `name` (including both being `nil`)
    public static func == (lhs: Qualifier, rhs: Qualifier) -> Bool {
        lhs.serviceType == rhs.serviceType && lhs.name == rhs.name
    }
}
