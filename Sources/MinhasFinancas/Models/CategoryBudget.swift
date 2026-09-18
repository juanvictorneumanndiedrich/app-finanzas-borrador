import Foundation

struct CategoryBudget: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var monthlyLimit: Decimal
    var categoryID: UUID?
}
