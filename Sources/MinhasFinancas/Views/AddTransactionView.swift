import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    let existing: Transaction?

    @State private var kind: TransactionKind
    @State private var amountText: String
    @State private var selectedCategoryID: UUID?
    @State private var date: Date
    @State private var note: String

    init(existing: Transaction? = nil) {
        self.existing = existing
        _kind = State(initialValue: existing?.kind ?? .expense)
        _amountText = State(initialValue: existing.map { NSDecimalNumber(decimal: $0.amount).stringValue } ?? "")
        _selectedCategoryID = State(initialValue: existing?.categoryID)
        _date = State(initialValue: existing?.date ?? .now)
        _note = State(initialValue: existing?.note ?? "")
    }

    private var filteredCategories: [Category] {
        store.categories.filter { $0.kind == kind }
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker(store.t("transaction.type"), selection: $kind) {
                    Text(store.t("transaction.expense")).tag(TransactionKind.expense)
                    Text(store.t("transaction.income")).tag(TransactionKind.income)
                }
                .pickerStyle(.segmented)

                TextField(store.t("transaction.amount"), text: $amountText)
                    .keyboardType(.decimalPad)

                Picker(store.t("transaction.category"), selection: $selectedCategoryID) {
                    Text(store.t("transaction.categoryNone")).tag(UUID?.none)
                    ForEach(filteredCategories) { category in
                        Text(category.name).tag(Optional(category.id))
                    }
                }

                DatePicker(store.t("transaction.date"), selection: $date, displayedComponents: .date)

                TextField(store.t("transaction.note"), text: $note)
            }
            .navigationTitle(existing == nil ? store.t("transaction.newTitle") : store.t("transaction.editTitle"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.t("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.t("common.save")) { save() }
                        .disabled(Decimal(string: amountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountText) else { return }
        if let existing {
            var updated = existing
            updated.amount = amount
            updated.kind = kind
            updated.date = date
            updated.note = note.isEmpty ? nil : note
            updated.categoryID = selectedCategoryID
            store.updateTransaction(updated)
        } else {
            let transaction = Transaction(
                amount: amount,
                date: date,
                kind: kind,
                note: note.isEmpty ? nil : note,
                isFromRecurring: false,
                categoryID: selectedCategoryID
            )
            store.addTransaction(transaction)
        }
        dismiss()
    }
}
