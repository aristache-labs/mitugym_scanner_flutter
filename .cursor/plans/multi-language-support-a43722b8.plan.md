<!-- a43722b8-8653-49f5-9ab3-fdfa2868f8dd b5fd1277-72ed-48cd-a5fb-99d77fefc88c -->
# Multi-Language Support Implementation

## Overview

Add English and Romanian language support to the app with a dropdown selector in Settings, storing preference locally in SharedPreferences.

## Implementation Steps

### 1. Update Dependencies

Add internationalization dependencies to `pubspec.yaml`:

- Add `flutter_localizations` SDK dependency
- Enable `generate: true` flag for ARB file generation

### 2. Configure Flutter Gen L10n

Create `l10n.yaml` in project root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 3. Create Translation Files

Create `lib/l10n/` directory with ARB files:

- `app_en.arb` - English translations (base/template)
- `app_ro.arb` - Romanian translations

Include all app strings covering:

- Navigation items (Dashboard, QR Scanner, Check-ins, History, Members, Settings)
- Dashboard content (Today's Activity, Total Scans, Check-ins, Check-outs, Denied, etc.)
- Settings tabs and options
- Form labels, buttons, error messages, dialogs
- Table headers (Member, Checked In, Checked Out, Duration, Plan, Expires, Status)
- Status badges (Active Session, Still in GYM, Plan Expired, Access Denied)
- Action buttons (Save, Cancel, Export, Search, etc.)

### 4. Update Main App Configuration

Modify `lib/main.dart`:

- Import `flutter_localizations` and generated `AppLocalizations`
- Add `localizationsDelegates` to MaterialApp
- Add `supportedLocales` (en, ro)
- Configure `localeResolutionCallback` for fallback to English

### 5. Create Language Provider

Create `lib/providers/language_provider.dart`:

- StateNotifier to manage current locale
- Load saved locale from SharedPreferences on init
- Method to change language and persist to SharedPreferences
- Use key `app_locale` for storage

### 6. Add Language Dropdown to Settings

Update `lib/screens/settings_screen.dart`:

- Add new "Language" section in General tab (or create new Preferences tab)
- Add dropdown with English/Romanian options
- Use `Consumer` to watch language provider
- Update UI when language changes

### 7. Replace Hardcoded Strings

Update all screens and widgets to use `AppLocalizations.of(context)`:

- `lib/screens/dashboard_screen.dart` - title, stats labels, table headers
- `lib/screens/stats_screen.dart` - title, table headers
- `lib/screens/history_screen.dart` - title, table headers
- `lib/screens/search_screen.dart` - search placeholder, table headers
- `lib/screens/settings_screen.dart` - all settings labels and descriptions
- `lib/screens/login_screen.dart` - form labels and buttons
- `lib/screens/scanner_screen.dart` - status messages
- `lib/widgets/modern_sidebar_widget.dart` - navigation menu items
- `lib/widgets/unified_activity_table.dart` - status badges
- `lib/widgets/unified_member_table.dart` - status labels
- `lib/widgets/member_details_modal.dart` - labels and buttons
- `lib/services/api_service.dart` - error messages (if user-facing)

### 8. Handle Dynamic Text

For text with placeholders (e.g., "Today's Activity (12 entries)"):

- Use ARB placeholder syntax: `"{count} entries"`
- Define placeholder types in ARB metadata
- Pass values when calling localization: `AppLocalizations.of(context)!.entriesCount(12)`

### 9. Testing

- Test language switching in Settings
- Verify persistence across app restarts
- Check all screens for missing translations
- Ensure UI layout handles longer Romanian text without overflow

## Files to Create

- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ro.arb`
- `lib/providers/language_provider.dart`

## Files to Modify

- `pubspec.yaml`
- `lib/main.dart`
- `lib/screens/settings_screen.dart`
- All screens (dashboard, stats, history, search, login, scanner)
- All widgets with user-facing text
- Services with user-facing error messages

## Key Considerations

- Generated localization files will be in `.dart_tool/flutter_gen/gen_l10n/`
- Run `flutter pub get` after pubspec changes to trigger code generation
- Use `!` operator carefully: `AppLocalizations.of(context)!.key`
- For widgets without direct context, pass localizations as parameter or use Builder
- Romanian text may be 20-30% longer than English - test UI layouts

### To-dos

- [ ] Add flutter_localizations dependency and configure l10n.yaml for ARB file generation
- [ ] Create lib/l10n/ directory with app_en.arb and app_ro.arb translation files for all app strings
- [ ] Update lib/main.dart with localization delegates, supported locales, and locale resolution
- [ ] Create lib/providers/language_provider.dart to manage locale state and SharedPreferences persistence
- [ ] Add language dropdown selector in Settings screen (lib/screens/settings_screen.dart)
- [ ] Replace hardcoded strings with AppLocalizations in all screens (dashboard, stats, history, search, login, scanner, settings)
- [ ] Replace hardcoded strings with AppLocalizations in all widgets (sidebar, tables, modals)
- [ ] Test language switching, verify persistence, check for missing translations and UI overflow issues