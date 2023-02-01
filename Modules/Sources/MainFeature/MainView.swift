import SwiftUI

public struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    public init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Text("Main")
    }
}

#if DEBUG
    struct MainView_Previews: PreviewProvider {
        static var previews: some View {
            MainView(
                viewModel: .init()
            )
        }
    }
#endif
