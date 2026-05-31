# Settings Feature

## Purpose
Application configuration — currency, appearance, security (biometric/PIN), notifications, and data management.

## Models
- `UserSettings` — currency, locale, biometricEnabled, pinEnabled, reminderTime, theme

## Screens
- `SettingsView` — grouped settings list
- `CurrencyPickerView` — currency selection
- `SecuritySettingsView` — biometric toggle, PIN setup
- `NotificationSettingsView` — reminder configuration

## ViewModels
- `SettingsViewModel` — load/save settings, toggle features

## Future Tasks
- [ ] Currency selection with symbol preview
- [ ] Biometric toggle with auth confirmation
- [ ] App PIN setup/change/remove
- [ ] Notification reminder time picker
- [ ] Data export (CSV/PDF)
- [ ] Data import
- [ ] Clear all data with confirmation dialog
- [ ] About / version info
