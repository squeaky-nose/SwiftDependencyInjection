//
//  Registration.swift
//  SwiftDependencyInjection
//
//  Created by Sushant Verma on 8/4/2026.
//


/// Describes how a service should be created and managed by the container.
public enum Registration {
    /// A lazily created singleton.
    /// The instance is created on first resolve and then cached for all future resolves.
    case singleton

    /// A factory registration.
    /// A new instance is created every time the service is resolved.
    case factory
}
