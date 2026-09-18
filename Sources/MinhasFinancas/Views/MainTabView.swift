import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: FinanceStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(store.t("tab.home"), systemImage: "house.fill")
                }

            SummaryView()
                .tabItem {
                    Label(store.t("tab.summary"), systemImage: "chart.pie.fill")
                }

            GoalsView()
                .tabItem {
                    Label(store.t("tab.goals"), systemImage: "target")
                }

            RecurringExpensesView()
                .tabItem {
                    Label(store.t("tab.recurring"), systemImage: "arrow.triangle.2.circlepath")
                }

            CategoriesView()
                .tabItem {
                    Label(store.t("tab.categories"), systemImage: "tag.fill")
                }

            SettingsView()
                .tabItem {
                    Label(store.t("tab.settings"), systemImage: "gearshape.fill")
                }
        }
    }
}
