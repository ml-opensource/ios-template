import SwiftUINavigation

public struct ProductRowView: View {
    @ObservedObject var viewModel: ProductViewModel

    public init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationLink(
            unwrapping: self.$viewModel.route,
            case: /ProductViewModel.Route.detail
        ) { _ in
            //TODO: implement detail view
            HStack {
                Text(viewModel.product.name)
                Text(viewModel.product.price, format: .currency(code: "EUR"))
            }
        } onNavigate: { isActive in
            self.viewModel.setDetailNavigation(isActive: isActive)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.product.id.description)
                    Text(viewModel.product.name)
                    Divider()
                    Text(viewModel.product.price, format: .currency(code: "EUR"))
                }
                Text(viewModel.product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

public struct ProductView: View {
    @ObservedObject var viewModel: ProductViewModel

    public init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Text(viewModel.product.description)
    }
}

#if DEBUG
    struct ProductRowView_Previews: PreviewProvider {
        static var previews: some View {

            ProductRowView(viewModel: .init(product: .mock))
                .previewLayout(.fixed(width: 450, height: 88))
            
            ProductRowView(viewModel: .init(product: .mock))
                .previewLayout(.fixed(width: 450, height: 88))
                .preferredColorScheme(.dark)

            NavigationView {
                List {
                    ProductRowView(viewModel: .init(product: .mock))
                }
            }

            NavigationView {
                List {
                    ProductRowView(viewModel: .init(product: .mock))
                }
                .listStyle(.plain)
            }

            NavigationView {
                List {
                    ProductRowView(viewModel: .init(product: .mock))
                }
                .listStyle(.sidebar)
            }
            .previewInterfaceOrientation(.landscapeLeft)
        }
    }

    struct ProductView_Previews: PreviewProvider {
        static var previews: some View {
            ProductView(viewModel: .init(product: .mock))
        }
    }
#endif
