# Gamification Feature

## Purpose
Reward healthy financial habits with achievements, badges, streaks, and a financial health score. Motivate consistent tracking.

## Models
- `Achievement` — id, name, description, icon, unlockedAt, category
- `Streak` — type, currentCount, longestCount, lastActiveDate
- `FinancialHealthScore` — score (0-100), breakdown factors

## Screens
- `GamificationView` — achievements gallery, streaks, health score
- `AchievementDetailView` — single achievement with unlock criteria

## ViewModels
- `GamificationViewModel` — check unlock conditions, compute streaks, health score

## Future Tasks
- [ ] Achievement badge grid
- [ ] Streak tracker (daily logging, savings, budget adherence)
- [ ] Financial health score gauge
- [ ] Unlock animations (Lottie)
- [ ] Achievement notification triggers
- [ ] Leaderboard against own past performance
