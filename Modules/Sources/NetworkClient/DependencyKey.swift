import Dependencies
import Foundation

extension NetworkClient: TestDependencyKey {
    
    public static var testValue: NetworkClient {
        .failing
    }
}

public extension DependencyValues {
    var networkClient: NetworkClient {
        get { self[NetworkClient.self] }
        set { self[NetworkClient.self] = newValue }
    }
}
