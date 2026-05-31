# Analytics Feature

## Purpose
Visualize spending patterns, income trends, and category breakdowns using interactive charts (fl_chart).

## Models
- `SpendingData` — period-grouped spending amounts
- `CategoryBreakdown` — category name, total, percentage
- `TrendData` — time-series data points for line charts

## Screens
- `AnalyticsView` — main analytics dashboard with multiple chart sections
- `CategoryDetailView` — deep dive into a specific category

## ViewModels
- `AnalyticsViewModel` — aggregates data by period, computes breakdowns

## Future Tasks
- [ ] Bar chart — income vs expenses by month
- [ ] Pie/donut chart — spending by category
- [ ] Line chart — balance trend over time
- [ ] Period selector (week/month/quarter/year)
- [ ] Top spending categories ranking
- [ ] Comparison with previous period
- [ ] Export chart as image
