import Foundation

enum AppLanguage: String, Codable, CaseIterable {
    case ptBR = "pt-BR"
    case es = "es"

    var displayName: String {
        switch self {
        case .ptBR: return "Português (Brasil)"
        case .es: return "Español"
        }
    }
}

enum L10n {
    private static let table: [String: [AppLanguage: String]] = [
        "tab.home": [.ptBR: "Início", .es: "Inicio"],
        "tab.summary": [.ptBR: "Resumo", .es: "Resumen"],
        "tab.goals": [.ptBR: "Metas", .es: "Metas"],
        "tab.recurring": [.ptBR: "Fixos", .es: "Fijos"],
        "tab.categories": [.ptBR: "Categorias", .es: "Categorías"],
        "tab.settings": [.ptBR: "Configurações", .es: "Configuración"],

        "home.title": [.ptBR: "Minhas Finanças", .es: "Mis Finanzas"],
        "home.balance": [.ptBR: "Saldo do mês", .es: "Saldo del mes"],
        "home.noCategory": [.ptBR: "Sem categoria", .es: "Sin categoría"],

        "transaction.newTitle": [.ptBR: "Nova Transação", .es: "Nueva Transacción"],
        "transaction.editTitle": [.ptBR: "Editar Transação", .es: "Editar Transacción"],
        "transaction.type": [.ptBR: "Tipo", .es: "Tipo"],
        "transaction.expense": [.ptBR: "Gasto", .es: "Gasto"],
        "transaction.income": [.ptBR: "Entrada", .es: "Ingreso"],
        "transaction.amount": [.ptBR: "Valor", .es: "Monto"],
        "transaction.category": [.ptBR: "Categoria", .es: "Categoría"],
        "transaction.categoryNone": [.ptBR: "Nenhuma", .es: "Ninguna"],
        "transaction.date": [.ptBR: "Data", .es: "Fecha"],
        "transaction.note": [.ptBR: "Nota (opcional)", .es: "Nota (opcional)"],

        "common.cancel": [.ptBR: "Cancelar", .es: "Cancelar"],
        "common.save": [.ptBR: "Salvar", .es: "Guardar"],

        "categories.title": [.ptBR: "Categorias", .es: "Categorías"],
        "categories.expenses": [.ptBR: "Gastos", .es: "Gastos"],
        "categories.income": [.ptBR: "Entradas", .es: "Ingresos"],
        "category.newTitle": [.ptBR: "Nova Categoria", .es: "Nueva Categoría"],
        "category.name": [.ptBR: "Nome", .es: "Nombre"],
        "category.icon": [.ptBR: "Ícone", .es: "Ícono"],
        "category.color": [.ptBR: "Cor", .es: "Color"],

        "goals.title": [.ptBR: "Metas", .es: "Metas"],
        "goal.newTitle": [.ptBR: "Nova Meta", .es: "Nueva Meta"],
        "goal.editTitle": [.ptBR: "Editar Meta", .es: "Editar Meta"],
        "goal.name": [.ptBR: "Nome da meta", .es: "Nombre de la meta"],
        "goal.targetAmount": [.ptBR: "Valor alvo", .es: "Monto objetivo"],
        "goal.deadlineFormat": [.ptBR: "Prazo: %d meses", .es: "Plazo: %d meses"],
        "goal.progressFormat": [.ptBR: "%@ de %@", .es: "%@ de %@"],
        "goal.suggestionFormat": [.ptBR: "Sugestão: %@/mês", .es: "Sugerencia: %@/mes"],

        "recurring.title": [.ptBR: "Gastos Fixos", .es: "Gastos Fijos"],
        "recurring.newTitle": [.ptBR: "Novo Gasto Fixo", .es: "Nuevo Gasto Fijo"],
        "recurring.editTitle": [.ptBR: "Editar Gasto Fixo", .es: "Editar Gasto Fijo"],
        "recurring.name": [.ptBR: "Nome", .es: "Nombre"],
        "recurring.amount": [.ptBR: "Valor", .es: "Monto"],
        "recurring.dueDayFormat": [.ptBR: "Dia do vencimento: %d", .es: "Día de vencimiento: %d"],
        "recurring.rowFormat": [.ptBR: "Todo dia %d · %@", .es: "Cada día %d · %@"],

        "summary.title": [.ptBR: "Resumo", .es: "Resumen"],
        "summary.spendingByCategory": [.ptBR: "Gastos por categoria", .es: "Gastos por categoría"],
        "summary.budgets": [.ptBR: "Orçamentos", .es: "Presupuestos"],
        "summary.setBudgetTitle": [.ptBR: "Definir orçamento", .es: "Definir presupuesto"],
        "summary.monthlyAmount": [.ptBR: "Valor mensal", .es: "Monto mensual"],
        "summary.ofFormat": [.ptBR: "de %@", .es: "de %@"],
        "summary.noBudget": [.ptBR: "sem orçamento definido", .es: "sin presupuesto definido"],

        "settings.title": [.ptBR: "Configurações", .es: "Configuración"],
        "settings.language": [.ptBR: "Idioma", .es: "Idioma"],
    ]

    static func t(_ key: String, _ language: AppLanguage) -> String {
        table[key]?[language] ?? key
    }
}
