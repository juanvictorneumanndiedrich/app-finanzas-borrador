import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: FinanceStore

    var body: some View {
        NavigationStack {
            List {
                Section(store.t("settings.language")) {
                    ForEach(AppLanguage.allCases, id: \.self) { language in
                        HStack {
                            Text(language.displayName)
                            Spacer()
                            if store.language == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.setLanguage(language)
                        }
                    }
                }
            }
            .navigationTitle(store.t("settings.title"))
        }
    }
}
