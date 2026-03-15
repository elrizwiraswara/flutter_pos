# CLAUDE.md - Flutter Project Conventions

## Architecture

**Clean Architecture** with three layers:

```
lib/
├── core/          # Shared utilities, services, themes, constants, extensions
├── data/          # Datasources (local/remote), models, repository implementations
├── domain/        # Entities, abstract repositories, usecases
├── presentation/  # Providers (state), screens (UI), widgets (reusable)
└── app/           # App root, DI, routing
```

**Data flow:** Presentation (Notifiers) → Domain (Usecases) → Domain (Repositories - abstract) → Data (Repositories - concrete) → Data (Datasources)

## State Management

**Riverpod** with Notifier/State pattern:

- `NotifierProvider<T, S>` for global state
- `AutoDisposeNotifier` for ephemeral state (forms, dialogs) that should clean up automatically
- State classes in separate files (`*_state.dart`) alongside notifiers (`*_notifier.dart`)
- Screens use `ConsumerWidget` or `ConsumerStatefulWidget`

## Routing

**GoRouter** with nested navigation via `ShellRoute`. Auth-aware redirects using `refreshListenable`. Navigate with `context.push()`, `context.go()`, `context.pop()`.

## Data Layer

- Repository pattern: abstract interface in `domain/`, concrete implementation in `data/`
- Datasource interfaces in `data/datasources/interfaces/`, implementations in `local/` and `remote/`
- Models (`*_model.dart`) are JSON-serializable with `toJson()`/`fromJson()`, plus `toEntity()`/`fromEntity()` mappers
- Entities (`*_entity.dart`) represent domain-level business objects

## Naming Conventions

### Files (snake_case)

| Type                  | Pattern                                  | Example                              |
| --------------------- | ---------------------------------------- | ------------------------------------ |
| Screens               | `*_screen.dart`                          | `home_screen.dart`                   |
| Notifiers             | `*_notifier.dart`                        | `products_notifier.dart`             |
| States                | `*_state.dart`                           | `products_state.dart`                |
| Models                | `*_model.dart`                           | `product_model.dart`                 |
| Entities              | `*_entity.dart`                          | `product_entity.dart`                |
| Datasource interfaces | `*_datasource.dart`                      | `auth_datasource.dart`               |
| Datasource impls      | `*_[local\|remote]_datasource_impl.dart` | `product_local_datasource_impl.dart` |
| Repository interfaces | `*_repository.dart`                      | `product_repository.dart`            |
| Repository impls      | `*_repository_impl.dart`                 | `product_repository_impl.dart`       |
| Usecases              | `*_usecases.dart`                        | `product_usecases.dart`              |
| Reusable widgets      | `app_*.dart`                             | `app_button.dart`                    |
| Screen components     | `components/*.dart`                      | `components/cart_panel_body.dart`    |

### Classes (PascalCase)

- Notifiers: `ProductsNotifier`, `AuthNotifier`
- States: `ProductsState`, `AuthState`
- Usecases: `GetProductsUsecase`, `CreateProductUsecase`
- Private sub-widgets: `_SearchField`, `_ItemCard` (prefixed with underscore)

### Variables (camelCase)

- Private fields: `_databaseService`, `_primaryColor`
- Provider declarations: `authNotifierProvider`, `productsNotifierProvider`

## Code Style

### Imports (ordered)

1. `dart:*`
2. `package:flutter/*`
3. Third-party packages (alphabetical)
4. Local project imports (relative paths)

### Formatting

- Line length: **120** characters
- Trailing commas: **preserve**
- Lints: `package:flutter_lints/flutter.yaml`
- Exclude generated files from analysis: `*.g.dart`, `*.mocks.dart`, `*.freezed.dart`
- After modifying any `.dart` file, run `dart format --line-length=120` on it before considering the edit done. This ensures consistent formatting that matches the project's style and avoids noisy diffs when the IDE auto-formats on save.

### Readability Rules

- No unnecessary comments, no decorative lines. Only important comments.
- Prioritize human readability — clean spacing, clear structure, no visual clutter.
- Always add an empty line to separate `if`, `return`, `for`, function definitions, and other logical blocks.

### Patterns

- **Result type**: `Result<T>` wrapper (Success/Failure) for error handling — not exceptions
- **Usecase pattern**: Abstract `Usecase<Result, Params>` class, one class per operation
- **Composition over inheritance**: Screens split into private `_Widget` sub-components
- **Equatable**: Used for value equality on entities and models

## Reference Docs

- `UI.md` — UI reference (layouts, components, design specs)
- `DATABASE.md` — Database schema reference (tables, columns, queries)
- `WORKFLOW.md` — Git workflow (commits, branches, PRs)

These docs may not exist yet. If provided, follow them.

## Quick Commands

```bash
flutter run                                              # run app
flutter analyze                                          # lint
dart format lib/ test/ --line-length=120                 # format
flutter test                                             # tests
flutter gen-l10n                                         # regenerate l10n
dart run build_runner build --delete-conflicting-outputs # codegen
```

## Testing

- Unit tests with `mockito` for mocking
- Fake/mock implementations for external services (Firebase, databases, etc.)
- Dedicated test initialization methods (e.g., `initTestDatabase()`) for isolated tests
