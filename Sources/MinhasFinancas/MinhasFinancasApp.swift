import SwiftUI

struct RootView: View {
    @StateObject private var store = FinanceStore()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            MainTabView()
                .environmentObject(store)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeOut(duration: 0.4)) {
                showSplash = false
            }
        }
    }
}

@main
struct MinhasFinancasApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
