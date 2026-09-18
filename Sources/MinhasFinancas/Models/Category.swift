import Foundation

enum TransactionKind: String, Codable, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }
}

struct Category: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String = "tag.fill"
    var colorHex: String = "#4A90D9"
    var kind: TransactionKind = .expense
    var createdAt: Date = .now
}
