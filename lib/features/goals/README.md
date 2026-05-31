# Goals Feature

## Purpose
Create and track financial goals with progress visualization. Contribute funds toward goals and celebrate milestones.

## Models
- `Goal` — id, name, targetAmount, savedAmount, deadline, icon, color, status
- `GoalContribution` — id, goalId, amount, date, note

## Screens
- `GoalsView` — list of active/completed goals
- `GoalDetailView` — single goal with progress chart and contribution history
- `AddGoalView` — create/edit goal form
- `ContributeView` — add funds to a goal

## ViewModels
- `GoalsViewModel` — list, filter active/completed, sort
- `GoalDetailViewModel` — load goal, contributions, progress calculation
- `GoalFormViewModel` — validation, save/update

## Future Tasks
- [ ] Circular progress indicator per goal
- [ ] Goal contribution history
- [ ] Deadline countdown
- [ ] Milestone celebrations (25%, 50%, 75%, 100%)
- [ ] Goal categories/icons
- [ ] Archiving completed goals
- [ ] Motivational quotes on goal cards
