import CombineSchedulers

public class MainViewModel: ObservableObject {
    public struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>

        public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
            self.mainQueue = mainQueue
        }
    }

    let environment: Environment

    public init(environment: Environment) {
        self.environment = environment
    }
}
