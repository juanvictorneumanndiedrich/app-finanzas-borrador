import Foundation

struct RecurringExpense: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var amount: Decimal
    var dueDay: Int
    var isPaused: Bool = false
    var createdAt: Date = .now
    var lastLaunchedMonth: Int = 0
    var lastLaunchedYear: Int = 0
    var categoryID: UUID?
}
