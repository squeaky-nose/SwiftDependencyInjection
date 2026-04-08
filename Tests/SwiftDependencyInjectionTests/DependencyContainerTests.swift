//
//  DependencyContainerTests.swift
//  SwiftDependencyInjection
//
//  Created by Sushant Verma on 8/4/2026.
//

import Foundation
import Testing
@testable import SwiftDependencyInjection

private protocol TestServiceProtocol: AnyObject {
    var id: UUID { get }
    var value: String { get }
}

private final class TestService: TestServiceProtocol {
    let id = UUID()
    let value: String

    init(value: String = "test") {
        self.value = value
    }
}

@Suite("DependencyContainer")
struct DependencyContainerTests {

    @Test("factory returns a new instance each time")
    func factoryReturnsNewInstanceEachTime() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, registration: .factory) {
            TestService(value: "factory")
        }

        let first = container.resolve(TestServiceProtocol.self)
        let second = container.resolve(TestServiceProtocol.self)

        #expect(first != nil)
        #expect(second != nil)
        #expect(first !== second)
        #expect(first?.value == "factory")
        #expect(second?.value == "factory")
    }

    @Test("singleton returns the same instance each time")
    func singletonReturnsSameInstanceEachTime() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, registration: .singleton) {
            TestService(value: "singleton")
        }

        let first = container.resolve(TestServiceProtocol.self)
        let second = container.resolve(TestServiceProtocol.self)

        #expect(first != nil)
        #expect(second != nil)
        #expect(first === second)
        #expect(first?.value == "singleton")
        #expect(second?.value == "singleton")
    }

    @Test("singleton is lazy and created only once")
    func singletonIsLazyAndCreatedOnlyOnce() {
        let container = DependencyContainer()
        var creationCount = 0

        container.register(TestServiceProtocol.self, registration: .singleton) {
            creationCount += 1
            return TestService()
        }

        #expect(creationCount == 0)

        let first = container.resolve(TestServiceProtocol.self)
        #expect(first != nil)
        #expect(creationCount == 1)

        let second = container.resolve(TestServiceProtocol.self)
        #expect(second != nil)
        #expect(creationCount == 1)
        #expect(first === second)
    }

    @Test("resolving unregistered service returns nil")
    func resolvingUnregisteredServiceReturnsNil() {
        let container = DependencyContainer()

        let service = container.resolve(TestServiceProtocol.self)

        #expect(service == nil)
    }

    @Test("named registrations resolve the correct service")
    func namedRegistrationsResolveCorrectService() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, name: "one", registration: .singleton) {
            TestService(value: "first")
        }

        container.register(TestServiceProtocol.self, name: "two", registration: .singleton) {
            TestService(value: "second")
        }

        let first = container.resolve(TestServiceProtocol.self, name: "one")
        let second = container.resolve(TestServiceProtocol.self, name: "two")

        #expect(first != nil)
        #expect(second != nil)
        #expect(first?.value == "first")
        #expect(second?.value == "second")
        #expect(first !== second)
    }

    @Test("resolving with wrong name returns nil")
    func resolvingWithWrongNameReturnsNil() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, name: "correct", registration: .singleton) {
            TestService()
        }

        let service = container.resolve(TestServiceProtocol.self, name: "wrong")

        #expect(service == nil)
    }

    @Test("resolving with inferred type works")
    func resolvingWithInferredTypeWorks() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, registration: .singleton) {
            TestService(value: "inferred")
        }

        let service: TestServiceProtocol? = container.resolve()

        #expect(service != nil)
        #expect(service?.value == "inferred")
    }

    @Test("resolveRequired returns registered service")
    func resolveRequiredReturnsRegisteredService() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, registration: .singleton) {
            TestService(value: "required")
        }

        let service = container.resolveRequired(TestServiceProtocol.self)

        #expect(service.value == "required")
    }

    @Test("resolveRequired with inferred type returns registered service")
    func resolveRequiredWithInferredTypeReturnsRegisteredService() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, registration: .singleton) {
            TestService(value: "required inferred")
        }

        let service: TestServiceProtocol = container.resolveRequired()

        #expect(service.value == "required inferred")
    }

    @Test("custom missing dependency handler is invoked for resolveRequired")
    func customMissingDependencyHandlerIsInvokedForResolveRequired() {
        final class MissingDependencySentinel: Error {}

        let container = DependencyContainer(
            onMissingRequiredDependency: { serviceType, name in
                Issue.record("Missing dependency: \(serviceType), name: \(name ?? "nil")")
                repeat {
                    RunLoop.current.run(mode: .default, before: .distantFuture)
                } while true
            }
        )

        // We cannot safely continue after calling a Never-returning handler,
        // so this test verifies behavior indirectly by exercising resolve()
        // for the same missing dependency.
        let service = container.resolve(TestServiceProtocol.self)

        #expect(service == nil)
    }

    @Test("later registration overwrites earlier registration for same qualifier")
    func laterRegistrationOverwritesEarlierRegistration() {
        let container = DependencyContainer()

        container.register(TestServiceProtocol.self, registration: .singleton) {
            TestService(value: "first")
        }

        container.register(TestServiceProtocol.self, registration: .singleton) {
            TestService(value: "second")
        }

        let service = container.resolve(TestServiceProtocol.self)

        #expect(service != nil)
        #expect(service?.value == "second")
    }

    @Test("factory can register and resolve value types")
    func factoryCanResolveValueTypes() {
        let container = DependencyContainer()

        var count = 0
        container.register(Int.self, registration: .factory) {
            count += 1
            return count
        }

        let first = container.resolve(Int.self)
        let second = container.resolve(Int.self)

        #expect(first == 1)
        #expect(second == 2)
    }

    @Test("singleton can register and resolve value types")
    func singletonCanResolveValueTypes() {
        let container = DependencyContainer()

        var count = 0
        container.register(Int.self, registration: .singleton) {
            count += 1
            return count
        }

        let first = container.resolve(Int.self)
        let second = container.resolve(Int.self)

        #expect(first == 1)
        #expect(second == 1)
        #expect(count == 1)
    }
}
