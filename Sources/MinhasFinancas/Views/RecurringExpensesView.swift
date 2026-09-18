import SwiftUI

struct RecurringExpensesView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.recurringExpenses) { expense in
                    RecurringRow(expense: expense)
                }
                .onDelete { offsets in
                    store.deleteRecurringExpenses(at: offsets, from: store.recurringExpenses)
                }
            }
            .navigationTitle("Gastos Fixos")
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
        }
    }
}

private struct RecurringRow: View {
    @EnvironmentObject private var store: FinanceStore
    let expense: RecurringExpense

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.name)
                    .font(.body)
                Text("Todo dia \(expense.dueDay) · \(CurrencyFormatter.string(from: expense.amount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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

    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var dueDay: Int = 1
    @State private var selectedCategoryID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome", text: $name)
                TextField("Valor", text: $amountText)
                    .keyboardType(.decimalPad)
                Stepper("Dia do vencimento: \(dueDay)", value: $dueDay, in: 1...28)

                Picker("Categoria", selection: $selectedCategoryID) {
                    Text("Nenhuma").tag(UUID?.none)
                    ForEach(store.categories.filter { $0.kind == .expense }) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }
            }
            .navigationTitle("Novo Gasto Fixo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: amountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        let expense = RecurringExpense(name: name, amount: amount, dueDay: dueDay, categoryID: selectedCategoryID)
        store.addRecurringExpense(expense)
        dismiss()
    }
}
