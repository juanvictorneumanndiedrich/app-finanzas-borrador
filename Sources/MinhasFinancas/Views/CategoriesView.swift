import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showingAddCategory = false

    private var expenseCategories: [Category] {
        store.categories.filter { $0.kind == .expense }
    }

    private var incomeCategories: [Category] {
        store.categories.filter { $0.kind == .income }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(store.t("categories.expenses")) {
                    ForEach(expenseCategories) { category in
                        CategoryRow(category: category)
                    }
                    .onDelete { offsets in
                        store.deleteCategories(at: offsets, from: expenseCategories)
                    }
                }
                Section(store.t("categories.income")) {
                    ForEach(incomeCategories) { category in
                        CategoryRow(category: category)
                    }
                    .onDelete { offsets in
                        store.deleteCategories(at: offsets, from: incomeCategories)
                    }
                }
            }
            .navigationTitle(store.t("categories.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
        }
    }
}

private struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundStyle(Color(hex: category.colorHex))
                .frame(width: 28)
            Text(category.name)
        }
    }
}

struct AddCategoryView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var kind: TransactionKind = .expense
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColorHex: String = "#4A90D9"

    private let icons = [
        "tag.fill", "fork.knife", "car.fill", "house.fill", "gamecontroller.fill",
        "heart.fill", "banknote.fill", "cart.fill", "bolt.fill", "book.fill",
        "gift.fill", "pawprint.fill", "airplane", "wrench.fill"
    ]

    private let colors = [
        "#4A90D9", "#E67E22", "#3498DB", "#9B59B6", "#1ABC9C",
        "#E74C3C", "#27AE60", "#F1C40F", "#34495E"
    ]

    private let columns = [GridItem(.adaptive(minimum: 44))]

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("category.name"), text: $name)

                Picker(store.t("transaction.type"), selection: $kind) {
                    Text(store.t("transaction.expense")).tag(TransactionKind.expense)
                    Text(store.t("transaction.income")).tag(TransactionKind.income)
                }
                .pickerStyle(.segmented)

                Section(store.t("category.icon")) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                }

                Section(store.t("category.color")) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(colors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().stroke(Color.primary, lineWidth: selectedColorHex == hex ? 2 : 0)
                                )
                                .onTapGesture { selectedColorHex = hex }
                        }
                    }
                }
            }
            .navigationTitle(store.t("category.newTitle"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.t("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.t("common.save")) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let category = Category(name: name, icon: selectedIcon, colorHex: selectedColorHex, kind: kind)
        store.addCategory(category)
        dismiss()
    }
}
