import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?

    private var sortedTransactions: [Transaction] {
        store.transactions.sorted { $0.date > $1.date }
    }

    private var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return sortedTransactions.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
    }

    private var monthlyBalance: Decimal {
        currentMonthTransactions.reduce(Decimal(0)) { partial, transaction in
            switch transaction.kind {
            case .income: return partial + transaction.amount
            case .expense: return partial - transaction.amount
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                balanceCard
                List {
                    ForEach(sortedTransactions) { transaction in
                        TransactionRow(transaction: transaction, category: store.category(for: transaction.categoryID))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingTransaction = transaction
                            }
                    }
                    .onDelete { offsets in
                        store.deleteTransactions(at: offsets, from: sortedTransactions)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(store.t("home.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(existing: transaction)
            }
            .task {
                RecurringEngine.processDueExpenses(store: store)
            }
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text(store.t("home.balance"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.string(from: monthlyBalance))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(monthlyBalance >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.12))
    }
}

private struct TransactionRow: View {
    @EnvironmentObject private var store: FinanceStore
    let transaction: Transaction
    let category: Category?

    var body: some View {
        HStack {
            Image(systemName: category?.icon ?? "questionmark.circle")
                .foregroundStyle(Color(hex: category?.colorHex ?? "#999999"))
                .frame(width: 32)
            VStack(alignment: .leading) {
                Text(category?.name ?? store.t("home.noCategory"))
                    .font(.body)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(CurrencyFormatter.string(from: transaction.amount))
                .foregroundStyle(transaction.kind == .income ? .green : .primary)
        }
    }
}
