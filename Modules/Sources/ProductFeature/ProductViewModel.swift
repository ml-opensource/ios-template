import Model
import SwiftUI

public class ProductViewModel: Identifiable, ObservableObject {

    public var id: Product.ID { self.product.id }
    @Published var product: Product
    @Published var route: Route?

    public init(
        product: Product,
        route: Route? = nil
    ) {
        self.product = product
        self.route = route
    }
    
    func setDetailNavigation(isActive: Bool) {
        self.route = isActive ? .detail : nil
    }
}

extension ProductViewModel: Hashable {
    public static func == (lhs: ProductViewModel, rhs: ProductViewModel) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(product.id)
        hasher.combine(product.name)
    }
}

//MARK: - Route
extension ProductViewModel {
    public enum Route: Equatable {
       case detail
        // case deleteAlert
        // case duplicate(Product)
        // case edit(Product)
    }
}
