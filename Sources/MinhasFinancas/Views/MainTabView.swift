import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }

            SummaryView()
                .tabItem {
                    Label("Resumo", systemImage: "chart.pie.fill")
                }

            GoalsView()
                .tabItem {
                    Label("Metas", systemImage: "target")
                }

            RecurringExpensesView()
                .tabItem {
                    Label("Fixos", systemImage: "arrow.triangle.2.circlepath")
                }

            CategoriesView()
                .tabItem {
                    Label("Categorias", systemImage: "tag.fill")
                }
        }
    }
}
