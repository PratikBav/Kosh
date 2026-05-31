# Transactions Feature

## Purpose
Track all income and expenses. Full CRUD with filtering, searching, and categorization.

## Models
- `Transaction` — id, amount, type (income/expense), category, note, date, isRecurring
- `TransactionFilter` — date range, category, type, amount range

## Screens
- `TransactionsView` — paginated list with filters
- `TransactionDetailView` — single transaction detail
- `AddTransactionView` — create/edit form

## ViewModels
- `TransactionsViewModel` — list, filter, search, pagination
- `TransactionFormViewModel` — form validation, save/update

## Future Tasks
- [ ] Transaction list with infinite scroll
- [ ] Filter drawer (date, category, type)
- [ ] Search functionality
- [ ] Swipe-to-delete
- [ ] Recurring transaction support
- [ ] Category auto-suggestion
- [ ] Transaction edit flow
- [ ] Batch delete
