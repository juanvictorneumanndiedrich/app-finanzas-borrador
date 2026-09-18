import SwiftUI

@main
struct MinhasFinancasApp: App {
    @StateObject private var store = FinanceStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
