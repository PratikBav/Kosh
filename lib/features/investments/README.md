# Investments Feature

## Purpose
Track investment portfolio — stocks, mutual funds, crypto, gold, etc. Monitor gains/losses and allocation.

## Models
- `Investment` — id, name, type, buyPrice, currentPrice, quantity, date, notes
- `InvestmentType` — enum (stocks, mutualFunds, crypto, gold, fixedDeposit, other)

## Screens
- `InvestmentsView` — portfolio overview with total value and allocation
- `InvestmentDetailView` — single investment with price history
- `AddInvestmentView` — create/edit investment

## ViewModels
- `InvestmentsViewModel` — portfolio summary, gain/loss calculation
- `InvestmentFormViewModel` — form validation, save/update

## Future Tasks
- [ ] Portfolio value card with total gain/loss
- [ ] Allocation pie chart by investment type
- [ ] Individual investment cards with gain/loss indicators
- [ ] Manual price update
- [ ] Investment history timeline
- [ ] SIP tracking support
