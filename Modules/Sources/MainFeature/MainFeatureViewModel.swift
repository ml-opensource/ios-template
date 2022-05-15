import CombineSchedulers
import IdentifiedCollections
import Model
import ProductFeature
import SwiftUI

public class MainFeatureViewModel: ObservableObject {

    let environment: MainFeatureEnvironment
    @Published var products: [ProductViewModel]
    @Published var route: Route?

    public init(
        environment: MainFeatureEnvironment,
        products: [ProductViewModel] = [],
        route: Route? = nil
    ) {
        self.environment = environment
        self.products = products
        self.route = route
    }
}

public struct MainFeatureEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }
}

//MARK: - Route
extension MainFeatureViewModel {
    public enum Route: Equatable {
        case alert
    }
}

//MARK: - Actions
extension MainFeatureViewModel {
    func addButtonTapped() {
        withAnimation {
            self.products.append(.init(product: .mock))
        }
    }

    func childEventReceived() {
        self.route = .alert
    }

    func deleteButtonTapped(indexSet: IndexSet) {
        self.products.remove(atOffsets: indexSet)
    }
}

//MARK: - ViewModel binding
extension MainFeatureViewModel {
    // private func bind(childUIModel: ChildUIModel) {
    //     childUIModel.onChildEvent = { [weak self] in
    //         self?.childEventReceived()
    //     }
    // }
}
