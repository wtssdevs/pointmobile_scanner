# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Toolchain

This project uses FVM to pin Flutter `3.22.2`. Always prefix commands with `fvm`:

```sh
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter test test/path/to/test.dart
fvm flutter analyze lib/path/to/file.dart
fvm dart format lib/path/to/file.dart
```

Use `stacked generate` (or `fvm flutter pub run build_runner build --delete-conflicting-outputs`) after any change to `lib/app/app.dart`, route registrations, service DI, bottom sheets, dialogs, or mock specs.

## Build and Release

```sh
# Full clean build (required before release)
fvm flutter clean && fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build appbundle        # Play Store
fvm flutter build apk --release    # APK

# ADB reverse for local API dev
adb reverse tcp:44311 tcp:44311    # XAC
adb reverse tcp:6636 tcp:6636      # CMS
```

## Architecture

**Stacked MVVM** — `stacked` + `stacked_services` with code generation.

- `lib/app/app.dart` — single source for routes, DI registrations, bottom sheets, and dialogs. Edit here; then regenerate.
- `lib/core/services/` — all services. Never instantiate services directly; use `locator<T>()`.
- `lib/ui/views/` — views (thin, stateless) and their paired ViewModels.
- `lib/ui/bottom_sheets/` — registered Stacked bottom sheets.
- `lib/ui/dialogs/` — registered Stacked dialogs.
- `lib/core/models/` — data models with `json_annotation` / `json_serializable`.

## Dual-Portal Architecture

The app authenticates against two independent backends:

| Portal | API Manager | Token Repo | Auth Service |
|---|---|---|---|
| XAC (gate-pass) | `ApiManager` | `AccessTokenRepo` | `AuthenticationService` |
| CMS (inspections) | `CmsApiManager` | `CmsAccessTokenRepo` | `CmsAuthenticationService` |

**Never cross the seams.** CMS work must use `CmsApiManager` and CMS-specific services. Do not use the XAC `ApiManager` or XAC auth/session for CMS calls.

`AuthSessionCoordinator` manages startup routing between portals; `LocalStorageService` persists session state keyed by `AppConst` string constants.

## CMS Feature Layer

CMS-specific services live under `lib/core/services/services/cms/`:

- `CmsSessionService` / `CmsSessionRepository` — session state and local persistence.
- `CmsMasterFilesRepository` / `CmsMasterFilesSyncService` — offline-first sync of lookup/master data into Sembast.
- `CmsMobileInspectionsService` — container inspection CRUD and local caching.
- `CmsMobileSurveyService` — survey workflows.
- `CmsInspectionLinePhotoQueueService` / `CmsMediaUploadQueueService` — offline media upload queuing.

If lookup data is already synced locally, read it from Sembast — do not add live remote lookup calls.

## Local Persistence

- **Sembast** (`AppDatabase`) is the primary local store. DB store names are defined in `AppConst` (`DB_*` constants).
- **SharedPreferences** via `LocalStorageService` for scalar session/config values.
- Isolate Sembast store names per test to avoid cross-test leakage.

## Background and File Transfer

- `WorkerQueManager` — queued background work that survives app restarts.
- `SyncManager` — coordinates background sync tasks.
- `FileStoreManager` / `FileStoreRepository` — file metadata, uploads, isolate-based transfer.
- Keep expensive uploads and sync tasks off the UI thread.

## Service Lifecycle

Use `@InitializableSingleton()` for services that require async `init()` (e.g. `ApiManager`, `CmsApiManager`, `AppDatabase`, `LocalStorageService`). Use `@LazySingleton()` for everything else.

## Testing

Tests live in `test/`. Structure mirrors the source tree:

- `test/services/` — service/parser tests.
- `test/viewmodels/` — ViewModel behavior tests.
- `test/helpers/test_helpers.dart` — shared mock setup (Mockito). Run codegen after adding new `MockSpec<T>` entries.

Run a single test file:
```sh
fvm flutter test test/viewmodels/cms_container_inspections_list_viewmodel_test.dart
```

Assert state, navigation decisions, and parsing outcomes — not layout details.

## Environment

Four `.env_*` files are bundled as assets: `.env_dev`, `.env_local_proxy_dev`, `.env_qa`, `.env_prod`. `EnvironmentService` reads `API_Base_Url_Key` / `CMS_API_Base_Url_Key` from the active env file.

## UI Conventions

- Backgrounds: `Colors.grey[50]`; cards: `Colors.white` with soft shadow, `16` outer margin, `20` inner padding.
- Primary accent: `kcPrimaryColor`.
- `CustomScrollView` + `SliverAppBar` for content-heavy screens.
- Validation errors come from the ViewModel's `Map<String, String>` — never local widget state.
- For large searchable lookups, use `searchable_paginated_dropdown` or `DropdownSearch` with server-side paging.
- **Keyboard dismiss on scroll (design requirement):** every scrollable that hosts or sits beneath a text input — `SingleChildScrollView`, `ListView`, `PagedListView`, `CustomScrollView` — MUST set `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` so dragging the content closes the keyboard. This is mandatory across all CMS input views and bottom sheets.
- **Bottom sheets with text inputs:** lift above the keyboard with `Padding`/`AnimatedPadding` using `MediaQuery.viewInsetsOf(context).bottom`. When using a `FractionallySizedBox` for height, expand to the full remaining height while the keyboard is open (`heightFactor: viewInsets.bottom > 0 ? 1.0 : 0.92`) — a centred fractional box otherwise squashes the scroll body and hides the focused field. Keep the body scrollable and give focused fields a bottom `scrollPadding` clearing any pinned footer.

## Stacked CLI Scaffold

```sh
stacked create view my_view
stacked create service my_service
stacked create bottom_sheet my_sheet
stacked create dialog my_dialog
```
