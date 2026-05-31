# Dashboard Feature

## Purpose
The home screen of Kosh. Provides a financial overview at a glance — total balance, income vs expenses, recent transactions, and quick actions.

## Models
- `DashboardSummary` — aggregated balance, income, expense totals
- `RecentTransaction` — lightweight transaction preview

## Screens
- `DashboardView` — main dashboard with balance card, quick actions, recent transactions

## ViewModels
- `DashboardViewModel` — loads summary data, recent transactions, handles refresh

## Future Tasks
- [ ] Balance card with real data from Isar
- [ ] Income vs Expense summary chips
- [ ] Recent transactions list (last 5)
- [ ] Quick action buttons wired to navigation
- [ ] Greeting based on time of day
- [ ] Pull-to-refresh
- [ ] Animated balance counter
