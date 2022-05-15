import IdentifiedCollections
import ProductFeature
import SwiftUI
import SwiftUINavigation

public struct MainFeatureView: View {
    @ObservedObject var viewModel: MainFeatureViewModel

    public init(viewModel: MainFeatureViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(
                    self.viewModel.products,
                    content: ProductRowView.init(viewModel:)
                )
                .onDelete(perform: self.viewModel.deleteButtonTapped(indexSet:))
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem {
                    Button(
                        action: self.viewModel.addButtonTapped,
                        label: { Image(systemName: "plus.circle.fill") }
                    )
                }
            }
            .alert(
                title: { Text("⚠️ Alert") },
                unwrapping: self.$viewModel.route,
                case: /MainFeatureViewModel.Route.alert,
                actions: { Button("Cancel", role: .cancel) {} },
                message: { Text("Something going on...") }
            )
        }
    }
}

#if DEBUG
    import Model

    struct MainView_Previews: PreviewProvider {
        static let products = Product.mocks(amount: 7).map { ProductViewModel(product: $0) }

        static var previews: some View {
            MainFeatureView(
                viewModel: .init(
                    environment: .init(mainQueue: .immediate),
                    products: products
                )
            )
            .previewDisplayName("No Route")

            MainFeatureView(
                viewModel: .init(
                    environment: .init(mainQueue: .immediate),
                    products: [.init(product: .mock, route: .detail)]
                )
            )
            .previewDisplayName("Detail")

            MainFeatureView(
                viewModel: .init(
                    environment: .init(mainQueue: .immediate),
                    products: products,
                    route: .alert
                )
            )
            .previewDisplayName("Alert")
        }
    }
#endif
