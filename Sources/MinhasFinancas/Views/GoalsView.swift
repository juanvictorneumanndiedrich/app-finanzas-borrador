import SwiftUI

struct GoalsView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showingAddGoal = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.goals) { goal in
                    GoalRow(goal: goal)
                }
                .onDelete { offsets in
                    store.deleteGoals(at: offsets, from: store.goals)
                }
            }
            .navigationTitle("Metas")
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
        }
    }
}

private struct GoalRow: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(goal.name)
                .font(.headline)
            ProgressView(value: goal.progress)
            HStack {
                Text("\(CurrencyFormatter.string(from: goal.currentAmount)) de \(CurrencyFormatter.string(from: goal.targetAmount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Sugestão: \(CurrencyFormatter.string(from: goal.suggestedMonthlyAmount))/mês")
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

    @State private var name: String = ""
    @State private var targetAmountText: String = ""
    @State private var months: Int = 6

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome da meta", text: $name)
                TextField("Valor alvo", text: $targetAmountText)
                    .keyboardType(.decimalPad)
                Stepper("Prazo: \(months) meses", value: $months, in: 1...60)
            }
            .navigationTitle("Nova Meta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Decimal(string: targetAmountText) == nil)
                }
            }
        }
    }

    private func save() {
        guard let target = Decimal(string: targetAmountText) else { return }
        let goal = Goal(name: name, targetAmount: target, deadlineMonths: months)
        store.addGoal(goal)
        dismiss()
    }
}
