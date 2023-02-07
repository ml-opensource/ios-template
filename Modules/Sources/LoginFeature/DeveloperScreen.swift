import APIClient
import Dependencies
import SwiftUI

struct DeveloperScreen: View {
    init(
    ) {
        self.selectedURL = apiClient.currentBaseURL()
    }

   
    @Dependency(\.apiClient) var apiClient
    @Environment(\.apiEnvironments) var apiEnvironments: [APIClient.APIEnvironment]
   
    @State var selectedURL: URL = URL(string: ":")!

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Toggle(
                    "Use mock api - Requires force quit",
                    isOn: Binding(
                        get: { UserDefaults.standard.bool(forKey: "USE_MOCK_API") },
                        set: { UserDefaults.standard.set($0, forKey: "USE_MOCK_API") })
                )

                Section(
                    content: {
                        Picker("", selection: $selectedURL) {
                            ForEach(apiEnvironments) { environment in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(environment.displayName).font(.headline)
                                        Text(environment.baseURL.absoluteString).font(.body)
                                    }
                                    Spacer()
                                }
                                .tag(environment.baseURL)
                            }
                        }
                        .labelsHidden()

                    },
                    header: { Text("API") }
                )
                .onChange(of: selectedURL) {
                    apiClient.setBaseURL($0)
                }
                .onAppear {
                    self.selectedURL =
                        apiEnvironments.first(where: { $0.baseURL == apiClient.currentBaseURL() })?
                        .baseURL ?? URL(string: ":")!
                }

            }
           

            .toolbar {
                HStack {
                    Spacer()
                    Button("OK") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
