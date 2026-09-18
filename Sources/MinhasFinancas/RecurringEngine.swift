import Foundation

enum RecurringEngine {
    @MainActor
    static func processDueExpenses(store: FinanceStore) {
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        for expense in store.recurringExpenses {
            guard !expense.isPaused else { continue }
            let alreadyLaunched = expense.lastLaunchedMonth == currentMonth && expense.lastLaunchedYear == currentYear
            guard !alreadyLaunched else { continue }
            guard currentDay >= expense.dueDay else { continue }

            let transaction = Transaction(
                amount: expense.amount,
                date: today,
                kind: .expense,
                note: expense.name,
                isFromRecurring: true,
                categoryID: expense.categoryID
            )
            store.addTransaction(transaction)
            store.markLaunched(expense, month: currentMonth, year: currentYear)
        }
    }
}
