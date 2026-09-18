import SwiftUI

struct GoalsView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showingAddGoal = false
    @State private var editingGoal: Goal?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.goals) { goal in
                    GoalRow(goal: goal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingGoal = goal
                        }
                }
                .onDelete { offsets in
                    store.deleteGoals(at: offsets, from: store.goals)
                }
            }
            .navigationTitle(store.t("goals.title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .sheet(item: $editingGoal) { goal in
                AddGoalView(existing: goal)
            }
        }
    }
}

private struct GoalRow: View {
    @EnvironmentObject private var store: FinanceStore
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(goal.name)
                .font(.headline)
            ProgressView(value: goal.progress)
            HStack {
                Text(String(
                    format: store.t("goal.progressFormat"),
                    CurrencyFormatter.string(from: goal.currentAmount),
                    CurrencyFormatter.string(from: goal.targetAmount)
                ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: store.t("goal.suggestionFormat"), CurrencyFormatter.string(from: goal.suggestedMonthlyAmount)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddGoalView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    let existing: Goal?

    @State private var name: String
    @State private var targetAmountText: String
    @State private var currentAmountText: String
    @State private var months: Int

    init(existing: Goal? = nil) {
        self.existing = existing
        _name = State(initialValue: existing?.name ?? "")
        _targetAmountText = State(initialValue: existing.map { NSDecimalNumber(decimal: $0.targetAmount).stringValue } ?? "")
        _currentAmountText = State(initialValue: existing.map { NSDecimalNumber(decimal: $0.currentAmount).stringValue } ?? "0")
        _months = State(initialValue: existing?.deadlineMonths ?? 6)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("goal.name"), text: $name)
                TextField(store.t("goal.targetAmount"), text: $targetAmountText)
                    .keyboardType(.decimalPad)
                if existing != nil {
                    TextField(store.t("transaction.amount"), text: $currentAmountText)
                        .keyboardType(.decimalPad)
                }
                Stepper(String(format: store.t("goal.deadlineFormat"), months), value: $months, in: 1...60)
            }
            .navigationTitle(existing == nil ? store.t("goal.newTitle") : store.t("goal.editTitle"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.t("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.t("common.save")) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: targetAmountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let target = Decimal(string: targetAmountText) else { return }
        if let existing {
            var updated = existing
            updated.name = name
            updated.targetAmount = target
            updated.currentAmount = Decimal(string: currentAmountText) ?? existing.currentAmount
            updated.deadlineMonths = months
            store.updateGoal(updated)
        } else {
            let goal = Goal(name: name, targetAmount: target, deadlineMonths: months)
            store.addGoal(goal)
        }
        dismiss()
    }
}
