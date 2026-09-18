import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var amount: Decimal
    var date: Date = .now
    var kind: TransactionKind
    var note: String?
    var isFromRecurring: Bool = false
    var categoryID: UUID?
}
