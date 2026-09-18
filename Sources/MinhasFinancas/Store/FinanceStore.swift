import Foundation

@MainActor
final class FinanceStore: ObservableObject {
    @Published var categories: [Category] = []
    @Published var transactions: [Transaction] = []
    @Published var recurringExpenses: [RecurringExpense] = []
    @Published var goals: [Goal] = []
    @Published var categoryBudgets: [CategoryBudget] = []

    private let fileManager = FileManager.default

    private var appSupportURL: URL {
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return url
    }

    private var storeURL: URL {
        appSupportURL.appendingPathComponent("MinhasFinancasData.json")
    }

    private struct StoredData: Codable {
        var categories: [Category]
        var transactions: [Transaction]
        var recurringExpenses: [RecurringExpense]
        var goals: [Goal]
        var categoryBudgets: [CategoryBudget]
    }

    init() {
        load()
        if categories.isEmpty {
            seedDefaultCategories()
        }
    }

    func category(for id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    // MARK: - Categories

    func addCategory(_ category: Category) {
        categories.append(category)
        save()
    }

    func deleteCategories(at offsets: IndexSet, from list: [Category]) {
        let idsToDelete = Set(offsets.map { list[$0].id })
        categories.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    // MARK: - Transactions

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        save()
    }

    func deleteTransactions(at offsets: IndexSet, from list: [Transaction]) {
        let idsToDelete = Set(offsets.map { list[$0].id })
        transactions.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    // MARK: - Recurring expenses

    func addRecurringExpense(_ expense: RecurringExpense) {
        recurringExpenses.append(expense)
        save()
    }

    func deleteRecurringExpenses(at offsets: IndexSet, from list: [RecurringExpense]) {
        let idsToDelete = Set(offsets.map { list[$0].id })
        recurringExpenses.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    func toggleRecurringPause(_ expense: RecurringExpense) {
        guard let index = recurringExpenses.firstIndex(where: { $0.id == expense.id }) else { return }
        recurringExpenses[index].isPaused.toggle()
        save()
    }

    func markLaunched(_ expense: RecurringExpense, month: Int, year: Int) {
        guard let index = recurringExpenses.firstIndex(where: { $0.id == expense.id }) else { return }
        recurringExpenses[index].lastLaunchedMonth = month
        recurringExpenses[index].lastLaunchedYear = year
        save()
    }

    // MARK: - Goals

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        save()
    }

    func deleteGoals(at offsets: IndexSet, from list: [Goal]) {
        let idsToDelete = Set(offsets.map { list[$0].id })
        goals.removeAll { idsToDelete.contains($0.id) }
        save()
    }

    // MARK: - Budgets

    func budget(for categoryID: UUID) -> CategoryBudget? {
        categoryBudgets.first { $0.categoryID == categoryID }
    }

    func setBudget(monthlyLimit: Decimal, for categoryID: UUID) {
        if let index = categoryBudgets.firstIndex(where: { $0.categoryID == categoryID }) {
            categoryBudgets[index].monthlyLimit = monthlyLimit
        } else {
            categoryBudgets.append(CategoryBudget(monthlyLimit: monthlyLimit, categoryID: categoryID))
        }
        save()
    }

    // MARK: - Persistence

    func load() {
        guard let data = try? Data(contentsOf: storeURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decoded = try? decoder.decode(StoredData.self, from: data) else { return }
        categories = decoded.categories
        transactions = decoded.transactions
        recurringExpenses = decoded.recurringExpenses
        goals = decoded.goals
        categoryBudgets = decoded.categoryBudgets
    }

    func save() {
        let data = StoredData(
            categories: categories,
            transactions: transactions,
            recurringExpenses: recurringExpenses,
            goals: goals,
            categoryBudgets: categoryBudgets
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted]
        guard let encoded = try? encoder.encode(data) else { return }
        try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        try? encoded.write(to: storeURL, options: .atomic)
    }

    private func seedDefaultCategories() {
        categories = [
            Category(name: "Alimentação", icon: "fork.knife", colorHex: "#E67E22", kind: .expense),
            Category(name: "Transporte", icon: "car.fill", colorHex: "#3498DB", kind: .expense),
            Category(name: "Moradia", icon: "house.fill", colorHex: "#9B59B6", kind: .expense),
            Category(name: "Lazer", icon: "gamecontroller.fill", colorHex: "#1ABC9C", kind: .expense),
            Category(name: "Saúde", icon: "heart.fill", colorHex: "#E74C3C", kind: .expense),
            Category(name: "Salário", icon: "banknote.fill", colorHex: "#27AE60", kind: .income),
        ]
        save()
    }
}
