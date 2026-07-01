# Al-Walla Medical Team - File Documentation

## Project Overview
- **Name:** al_walla_team
- **Description:** فريق الولاء الطبي (Al-Walaa Medical Team) - Internal Management Platform
- **Architecture:** Clean Architecture with feature-based structure
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Local DB:** Isar
- **Localization:** AR/EN (Arabic/English)

---

## Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/bootstrap.dart` | App bootstrap / initialization |
| `lib/app.dart` | MaterialApp configuration |

---

## Core Layer (`lib/core/`)

### Auth
| File | Purpose |
|------|---------|
| `lib/core/auth/permission_checker.dart` | Permission checking logic |
| `lib/core/auth/session_watcher.dart` | Session monitoring |

### Constants
| File | Purpose |
|------|---------|
| `lib/core/constants/app_colors.dart` | App color palette |
| `lib/core/constants/app_enums.dart` | Enum definitions |
| `lib/core/constants/app_sizes.dart` | Spacing/sizing constants |
| `lib/core/constants/app_strings.dart` | Static string constants |
| `lib/core/constants/permission_constants.dart` | Permission key constants |

### Error
| File | Purpose |
|------|---------|
| `lib/core/error/app_exception.dart` | Custom exception classes |
| `lib/core/error/failure.dart` | Failure types |

### Local DB
| File | Purpose |
|------|---------|
| `lib/core/local_db/isar_initializer.dart` | Isar database initialization |

### Localization
| File | Purpose |
|------|---------|
| `lib/core/localization/locale_controller.dart` | Locale switching logic |

### Routing
| File | Purpose |
|------|---------|
| `lib/core/routing/app_router.dart` | GoRouter configuration and route definitions |
| `lib/core/routing/route_names.dart` | Route name constants |

### Theme
| File | Purpose |
|------|---------|
| `lib/core/theme/app_theme.dart` | App theme configuration |
| `lib/core/theme/app_text_theme.dart` | Text theme styles |
| `lib/core/theme/app_input_theme.dart` | Input decoration theme |

### Utils
| File | Purpose |
|------|---------|
| `lib/core/utils/clipboard_utils.dart` | Clipboard operations |
| `lib/core/utils/credential_generator.dart` | Credential generation (passwords, etc.) |
| `lib/core/utils/date_formatters.dart` | Date formatting utilities |
| `lib/core/utils/extensions.dart` | Dart extension methods |
| `lib/core/utils/result.dart` | Result type (Success/Failure) |
| `lib/core/utils/validators.dart` | Form input validators |

### Widgets
| File | Purpose |
|------|---------|
| `lib/core/widgets/app_app_bar.dart` | Reusable app bar widget |
| `lib/core/widgets/app_card.dart` | Reusable card widget |

---

## Features (`lib/features/`)

### Admin Management
| File | Purpose |
|------|---------|
| `lib/features/admin_management/presentation/pages/admin_list_page.dart` | Admin users list |
| `lib/features/admin_management/presentation/pages/admin_edit_page.dart` | Admin edit/create form |

### Applications
| File | Purpose |
|------|---------|
| `lib/features/applications/presentation/pages/application_list_page.dart` | Volunteer applications list |
| `lib/features/applications/presentation/pages/application_form_page.dart` | Application form |

### Auth
| File | Purpose |
|------|---------|
| `lib/features/auth/presentation/pages/login_page.dart` | Login screen |
| `lib/features/auth/presentation/widgets/session_expired_screen.dart` | Session expired dialog |

### CMS
| File | Purpose |
|------|---------|
| `lib/features/cms/presentation/pages/cms_list_page.dart` | CMS sections list |
| `lib/features/cms/presentation/pages/cms_form_page.dart` | CMS section create/edit form |
| `lib/features/cms/presentation/pages/dynamic_fields_page.dart` | Dynamic field management |

### Detachment
| File | Purpose |
|------|---------|
| `lib/features/detachment/presentation/pages/detachment_list_page.dart` | Detachments list |
| `lib/features/detachment/presentation/pages/detachment_form_page.dart` | Detachment create/edit form |
| `lib/features/detachment/presentation/pages/detachment_stats_page.dart` | Detachment statistics |
| `lib/features/detachment/presentation/pages/detachment_history_page.dart` | Detachment history |
| `lib/features/detachment/presentation/pages/detachment_day_detail_page.dart` | Detachment day detail |

### Home
| File | Purpose |
|------|---------|
| `lib/features/home/presentation/pages/home_dashboard_page.dart` | Main dashboard |

### Language
| File | Purpose |
|------|---------|
| `lib/features/language/presentation/pages/language_selection_page.dart` | Language picker |

### Notifications
| File | Purpose |
|------|---------|
| `lib/features/notifications/presentation/pages/notifications_page.dart` | Notifications list |

### Posts
| File | Purpose |
|------|---------|
| `lib/features/posts/presentation/pages/posts_list_page.dart` | Posts list |
| `lib/features/posts/presentation/pages/post_detail_page.dart` | Post detail view |
| `lib/features/posts/presentation/pages/post_form_page.dart` | Post create/edit form |

### Profile
| File | Purpose |
|------|---------|
| `lib/features/profile/presentation/pages/profile_page.dart` | User profile view |
| `lib/features/profile/presentation/pages/profile_edit_page.dart` | Profile edit form |

### Settings
| File | Purpose |
|------|---------|
| `lib/features/settings/presentation/pages/settings_page.dart` | App settings |
| `lib/features/settings/presentation/pages/about_page.dart` | About page |

### Splash
| File | Purpose |
|------|---------|
| `lib/features/splash/presentation/pages/splash_page.dart` | Splash screen |

### Support
| File | Purpose |
|------|---------|
| `lib/features/support/presentation/pages/support_list_page.dart` | Support tickets list |
| `lib/features/support/presentation/pages/support_detail_page.dart` | Ticket detail view |
| `lib/features/support/presentation/pages/support_form_page.dart` | Ticket create/edit form |

### Team
| File | Purpose |
|------|---------|
| `lib/features/team/presentation/pages/team_page.dart` | Team members list |
| `lib/features/team/presentation/pages/team_leadership_page.dart` | Team leadership view |

### Workshops
| File | Purpose |
|------|---------|
| `lib/features/workshops/presentation/pages/workshops_list_page.dart` | Workshops list |
| `lib/features/workshops/presentation/pages/workshop_detail_page.dart` | Workshop detail view |
| `lib/features/workshops/presentation/pages/workshop_form_page.dart` | Workshop create/edit form |

---

## Shared Layer (`lib/shared/`)

### Models (Isar Schemas)

| Schema File | Generated File | Purpose |
|-------------|---------------|---------|
| `cms_section_schema.dart` | `.g.dart` | CMS section data model |
| `detachment_crew_schema.dart` | `.g.dart` | Detachment crew member |
| `detachment_day_schema.dart` | `.g.dart` | Detachment day |
| `detachment_shift_schema.dart` | `.g.dart` | Detachment shift |
| `detachment_stats_schema.dart` | `.g.dart` | Detachment statistics |
| `dynamic_field_schema.dart` | `.g.dart` | Dynamic form field |
| `notification_schema.dart` | `.g.dart` | Notification |
| `pending_application_schema.dart` | `.g.dart` | Pending application |
| `post_schema.dart` | `.g.dart` | Post / announcement |
| `support_ticket_schema.dart` | `.g.dart` | Support ticket |
| `team_info_section_schema.dart` | `.g.dart` | Team info section |
| `team_member_schema.dart` | `.g.dart` | Team member |
| `user_schema.dart` | `.g.dart` | User / admin account |
| `workshop_attendee_schema.dart` | `.g.dart` | Workshop attendee |
| `workshop_schema.dart` | `.g.dart` | Workshop |
| `workshop_staff_schema.dart` | `.g.dart` | Workshop staff |

### Repositories
| File | Purpose |
|------|---------|
| `application_repository.dart` | Application data operations |
| `auth_repository.dart` | Auth data operations |
| `cms_repository.dart` | CMS data operations |
| `detachment_repository.dart` | Detachment data operations |
| `dynamic_field_repository.dart` | Dynamic field data operations |
| `notification_repository.dart` | Notification data operations |
| `post_repository.dart` | Post data operations |
| `support_repository.dart` | Support ticket data operations |
| `team_info_repository.dart` | Team info data operations |
| `workshop_repository.dart` | Workshop data operations |

### Services
| File | Purpose |
|------|---------|
| `auth_service.dart` | Authentication service |
| `local_storage_service.dart` | Local storage (SharedPreferences) wrapper |

---

## Localization (`lib/l10n/`)

| File | Purpose |
|------|---------|
| `app_ar.arb` | Arabic translations |
| `app_en.arb` | English translations |
| `app_localizations.dart` | Generated localization delegate |
| `app_localizations_ar.dart` | Generated Arabic localizations |
| `app_localizations_en.dart` | Generated English localizations |

---

## Change Log

### 2026-07-01
- **Home Dashboard Redesign:** Replaced `SingleChildScrollView` + `Column` with `CustomScrollView` + `Slivers` (`SliverToBoxAdapter`, `SliverGrid`, `SliverPadding`):
  - Stat cards now use `SliverGrid` (2 columns, `childAspectRatio: 1.4`) with colored top accent borders (primary=أعضاء, adminPurple=مفرزات, success=ورش, goldBright=دعم)
  - `TweenAnimationBuilder<int>` for count-up animation (0 → value, 800ms)
  - Quick actions upgraded to `SliverGrid` (3 columns, `childAspectRatio: 0.95`)
  - Extracted reusable widgets: `_WelcomeCard`, `_SectionTitle`, `_StatCard`, `_QuickActionCard`, `_CmsSectionCard`
  - No `shrinkWrap` anti-patterns, no `GridView.count` — proper Sliver virtualization
  - Zero overflow issues at any screen size

- **Detachment Management Feature (NEW):**
  - **Models** (`lib/features/detachment/models/`):
    - `detachment_member_model.dart` — Type-safe model with `withConverter()` (uid, name, role, phone, isActive, createdAt)
    - `detachment_day_model.dart` — Day model (dayName, dayDate, weekDay, isActive, createdBy, createdAt)
    - `detachment_shift_model.dart` — Shift model (dayId, shiftName, startTime, endTime, durationHours, memberIds, memberCount, createdBy, createdAt)
  - **Repository** (`lib/features/detachment/repositories/detachment_repository.dart`):
    - Firestore CRUD with `.withConverter()` for type safety
    - `watchMembers()`, `addMember()`, `deleteMember()`
    - `watchDays()`, `createDay()`, `deleteDay()` (batch-deletes all nested shifts)
    - `watchShiftsForDay()`, `createShift()`, `updateShift()`, `updateShiftMembers()`, `deleteShift()`
  - **Controller** (`lib/features/detachment/controllers/detachment_controller.dart`):
    - `StateNotifier<DetachmentMemberSelectionState>` via Riverpod
    - Manages search query, selected member IDs, save state
    - Client-side member filtering (no Firestore calls for search)
  - **Pages** (`lib/features/detachment/presentation/pages/`):
    - `detachment_days_page.dart` — Days list with add/edit/delete, bottom sheet for new day (name dropdown + date picker)
    - `detachment_day_shifts_page.dart` — Shift list with add/edit/delete, bottom sheet with time pickers, auto-calculated duration
    - `shift_members_page.dart` — Member selection with debounced search, checkboxes, checked-at-top sorting, save with loading state
  - **Routes Added** (`lib/core/routing/`):
    - `/detachment/manage` → `DetachmentDaysPage`
    - `/detachment/manage/:dayId` → `DetachmentDayShiftsPage`
    - `/detachment/manage/:dayId/shifts/:shiftId` → `ShiftMembersPage`
  - **Provider** registered in `lib/app.dart` as `detachmentNewRepoProvider`
  - **Firestore Collections**: `detachment_members`, `detachment_days`, `detachment_shifts`
  - **APK built and installed** via `flutter run --release` (60.1MB)

- **Shift Edit Fix:** Added `updateShift()` method to repository + edit dialog in shifts page (edit icon alongside delete icon)

- **Member Creation:** Added "إضافة عضو" bottom sheet to ShiftMembersPage empty state (name, role dropdown, phone)

### 2026-06-29
- **APK installed** via `adb install -r build/app/outputs/flutter-apk/app-debug.apk`

- **Bug 1 (Stream Error):** Fixed "Bad state: Stream has already been listened to" by adding `.asBroadcastStream()` to `streamStaff()` and `streamAttendees()` in `workshop_repository.dart:83-190`. The root cause: `_buildStatsTab` and `_buildStaffTab` both listened to `repo.streamStaff(w.uid)`, and `_buildStatsTab` and `_buildAttendeesTab` both listened to `repo.streamAttendees(w.uid)`. With `TabBarView` building all tabs simultaneously, Isar's `watch()` single-subscription streams were listened to twice.

- **Bug 2 (Menu Icon):** Replaced `buildAppAppBar` (which had `onPressed: openDrawer()` with no drawer in Scaffold) with a custom `AppBar` containing a `PopupMenuButton` with workshop actions:
  - "إضافة عضو طاقم" → `_showAddStaffDialog()`
  - "إضافة طالب / ضيف" → `_showAddAttendeeDialog()`

- **Bug 3 (Overflow):** In `home_dashboard_page.dart`:
  - `_StatTile` GridView: `childAspectRatio` changed from `2.5` → `1.8`, padding reduced from `all(AppSizes.sm)` → `symmetric(horizontal: sm, vertical: 6)`, spacing `AppSizes.xs` → `2`
  - `_QuickActionCard` GridView: `childAspectRatio` changed from `1.8` → `1.4`, icon container reduced from `40x40` → `36x36`, label wrapped in `Flexible + FittedBox`, padding reduced from `all(AppSizes.sm)` → `symmetric(horizontal: sm, vertical: 6)`, `maxLines: 2` → `maxLines: 1`
