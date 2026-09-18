import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    @State private var kind: TransactionKind = .expense
    @State private var amountText: String = ""
    @State private var selectedCategoryID: UUID?
    @State private var date: Date = .now
    @State private var note: String = ""

    private var filteredCategories: [Category] {
        store.categories.filter { $0.kind == kind }
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Tipo", selection: $kind) {
                    Text("Gasto").tag(TransactionKind.expense)
                    Text("Entrada").tag(TransactionKind.income)
                }
                .pickerStyle(.segmented)

                TextField("Valor", text: $amountText)
                    .keyboardType(.decimalPad)

                Picker("Categoria", selection: $selectedCategoryID) {
                    Text("Nenhuma").tag(UUID?.none)
                    ForEach(filteredCategories) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }

                DatePicker("Data", selection: $date, displayedComponents: .date)

                TextField("Nota (opcional)", text: $note)
            }
            .navigationTitle("Nova Transação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(Decimal(string: amountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        let transaction = Transaction(
            amount: amount,
            date: date,
            kind: kind,
            note: note.isEmpty ? nil : note,
            isFromRecurring: false,
            categoryID: selectedCategoryID
        )
        store.addTransaction(transaction)
        dismiss()
    }
}
