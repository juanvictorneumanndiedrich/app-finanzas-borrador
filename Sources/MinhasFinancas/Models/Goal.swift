import Foundation

struct Goal: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var targetAmount: Decimal
    var currentAmount: Decimal = 0
    var deadlineMonths: Int
    var createdAt: Date = .now

    var monthsRemaining: Int {
        let calendar = Calendar.current
        let deadlineDate = calendar.date(byAdding: .month, value: deadlineMonths, to: createdAt) ?? .now
        let components = calendar.dateComponents([.month], from: .now, to: deadlineDate)
        return max(components.month ?? 0, 1)
    }

    var suggestedMonthlyAmount: Decimal {
        let remaining = targetAmount - currentAmount
        guard remaining > 0 else { return 0 }
        return remaining / Decimal(monthsRemaining)
    }

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        let value = (currentAmount / targetAmount) as NSDecimalNumber
        return min(max(value.doubleValue, 0), 1)
    }
}
