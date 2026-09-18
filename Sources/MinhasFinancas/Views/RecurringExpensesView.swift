import SwiftUI

struct RecurringExpensesView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showingAddExpense = false
    @State private var editingExpense: RecurringExpense?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.recurringExpenses) { expense in
                    RecurringRow(expense: expense, onTap: { editingExpense = expense })
                }
                .onDelete { offsets in
                    store.deleteRecurringExpenses(at: offsets, from: store.recurringExpenses)
                }
            }
            .navigationTitle(store.t("recurring.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddRecurringExpenseView()
            }
            .sheet(item: $editingExpense) { expense in
                AddRecurringExpenseView(existing: expense)
            }
        }
    }
}

private struct RecurringRow: View {
    @EnvironmentObject private var store: FinanceStore
    let expense: RecurringExpense
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.name)
                    .font(.body)
                Text(String(format: store.t("recurring.rowFormat"), expense.dueDay, CurrencyFormatter.string(from: expense.amount)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
            Spacer()
            Toggle("", isOn: Binding(
                get: { !expense.isPaused },
                set: { _ in store.toggleRecurringPause(expense) }
            ))
            .labelsHidden()
        }
    }
}

struct AddRecurringExpenseView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    let existing: RecurringExpense?

    @State private var name: String
    @State private var amountText: String
    @State private var dueDay: Int
    @State private var selectedCategoryID: UUID?

    init(existing: RecurringExpense? = nil) {
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _amountText = State(initialValue: existing.map { NSDecimalNumber(decimal: $0.amount).stringValue } ?? "")
        _dueDay = State(initialValue: existing?.dueDay ?? 1)
        _selectedCategoryID = State(initialValue: existing?.categoryID)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("recurring.name"), text: $name)
                TextField(store.t("recurring.amount"), text: $amountText)
                    .keyboardType(.decimalPad)
                Stepper(String(format: store.t("recurring.dueDayFormat"), dueDay), value: $dueDay, in: 1...28)

                Picker(store.t("transaction.category"), selection: $selectedCategoryID) {
                    Text(store.t("transaction.categoryNone")).tag(UUID?.none)
                    ForEach(store.categories.filter { $0.kind == .expense }) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }
            }
            .navigationTitle(existing == nil ? store.t("recurring.newTitle") : store.t("recurring.editTitle"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.t("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.t("common.save")) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: amountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        if let existing {
            var updated = existing
            updated.name = name
            updated.amount = amount
            updated.dueDay = dueDay
            updated.categoryID = selectedCategoryID
            store.updateRecurringExpense(updated)
        } else {
            let expense = RecurringExpense(name: name, amount: amount, dueDay: dueDay, categoryID: selectedCategoryID)
            store.addRecurringExpense(expense)
        }
        dismiss()
    }
}
