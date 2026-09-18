import SwiftUI
import Charts

struct SummaryView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var editingCategoryID: UUID?
    @State private var newLimitText: String = ""

    private var currentMonthExpenses: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return store.transactions.filter {
            $0.kind == .expense && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
    }

    private struct CategorySpending: Identifiable {
        let id: UUID
        let name: String
        let colorHex: String
        let total: Decimal
    }

    private var spendingByCategory: [CategorySpending] {
        var totals: [UUID: Decimal] = [:]
        for transaction in currentMonthExpenses {
            guard let categoryID = transaction.categoryID else { continue }
            totals[categoryID, default: 0] += transaction.amount
        }
        var result: [CategorySpending] = []
        for (categoryID, total) in totals {
            guard let category = store.category(for: categoryID) else { continue }
            result.append(CategorySpending(id: categoryID, name: category.name, colorHex: category.colorHex, total: total))
        }
        return result.sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            List {
                if !spendingByCategory.isEmpty {
                    Section("Gastos por categoria") {
                        Chart(spendingByCategory) { item in
                            SectorMark(
                                angle: .value("Total", NSDecimalNumber(decimal: item.total).doubleValue),
                                innerRadius: .ratio(0.55)
                            )
                            .foregroundStyle(Color(hex: item.colorHex))
                        }
                        .frame(height: 220)
                    }
                }

                Section("Orçamentos") {
                    ForEach(store.categories.filter { $0.kind == .expense }) { category in
                        budgetRow(for: category)
                    }
                }
            }
            .navigationTitle("Resumo")
            .alert("Definir orçamento", isPresented: Binding(
                get: { editingCategoryID != nil },
                set: { isPresented in
                    if !isPresented { editingCategoryID = nil }
                }
            )) {
                TextField("Valor mensal", text: $newLimitText)
                    .keyboardType(.decimalPad)
                Button("Cancelar", role: .cancel) { editingCategoryID = nil }
                Button("Salvar") { saveBudget() }
            }
        }
    }

    private func budgetRow(for category: Category) -> some View {
        let spent = spentAmount(for: category.id)
        let budget = store.budget(for: category.id)
        return BudgetRow(category: category, spent: spent, budget: budget)
            .contentShape(Rectangle())
            .onTapGesture {
                editingCategoryID = category.id
                newLimitText = budget.map { NSDecimalNumber(decimal: $0.monthlyLimit).stringValue } ?? ""
            }
    }

    private func spentAmount(for categoryID: UUID) -> Decimal {
        var total = Decimal(0)
        for transaction in currentMonthExpenses where transaction.categoryID == categoryID {
            total += transaction.amount
        }
        return total
    }

    private func saveBudget() {
        guard let categoryID = editingCategoryID, let limit = Decimal(string: newLimitText) else {
            editingCategoryID = nil
            return
        }
        store.setBudget(monthlyLimit: limit, for: categoryID)
        editingCategoryID = nil
    }
}

private struct BudgetRow: View {
    let category: Category
    let spent: Decimal
    let budget: CategoryBudget?

    private var limit: Decimal {
        budget?.monthlyLimit ?? 0
    }

    private var isNearLimit: Bool {
        guard limit > 0 else { return false }
        return spent >= limit * Decimal(0.8)
    }

    private var isOverLimit: Bool {
        guard limit > 0 else { return false }
        return spent > limit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.colorHex))
                Text(category.name)
                Spacer()
                if isOverLimit {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                } else if isNearLimit {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
            HStack {
                Text(CurrencyFormatter.string(from: spent))
                    .font(.caption)
                if limit > 0 {
                    Text("de \(CurrencyFormatter.string(from: limit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("sem orçamento definido")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
