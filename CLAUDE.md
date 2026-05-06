# CLAUDE.md - Flutter Project Conventions

## Architecture

**Clean Architecture** with five layers:

```
lib/
├── app/               # App root, DI, routing
├── core/              # Shared utilities, services, themes, constants, extensions
├── data/              # Datasources (local/remote), models, repository implementations
├── domain/            # Entities, abstract repositories, usecases
└── presentation/      # Providers (state), screens (UI), widgets (reusable)
```

### Detailed Structure

```
data
- datasources
  - interfaces
    - user_datasource.dart                # Datasource interface (shared by local & remote)  # abstract class UserDatasource {}
    - ...
  - remote
    - user_remote_datasource_impl.dart    # Remote datasource implementation                 # class UserRemoteDatasourceImpl implements UserDatasource {}
    - ...
  - local
    - user_local_datasource_impl.dart     # Local datasource implementation                  # class UserLocalDatasourceImpl implements UserDatasource {}
    - ...
- models
  - user_model.dart                       # Data model                                       # class UserModel {}
  - ...
- repositories
  - user_repository_impl.dart             # Repository implementation                        # class UserRepositoryImpl implements UserRepository {}
  - ...
domain
- entities
  - user_entity.dart                      # Entity object                                    # class UserEntity extends Equatable {}
- repositories
  - user_repository.dart                  # Repository interface                             # abstract class UserRepository {}
- usecases
  - params
    - base_params.dart                    # Shared usecase param types                       # class BaseParams {}
    - no_param.dart                       # Empty param marker                               # class NoParam {}
  - user_usecases.dart                    # Multiple usecase classes per file                # class GetUserUsecase extends Usecase<...> {}
  - ...
presentation
- providers
  - user
    - user_notifier.dart                  # Notifier                                         # class UserNotifier extends Notifier<UserState> {}
    - user_state.dart                     # State                                            # class UserState {}
  - ...
- screens
  - user
    - components
      - user_card.dart                    # Scoped widget                                    # class UserCard {}
      - ...
    - user_screen.dart                    # Screen                                           # class UserScreen {}
  - ...
- widgets
  - app_button.dart                       # Shared & reusable widgets                        # class AppButton {}
  - ...
```

- Models transform data via `fromJson`/`toJson` and `fromEntity`/`toEntity`
- Datasource interfaces live in `data/datasources/interfaces/` and are shared by both local and remote impls
- Repositories may have local, remote, or both datasources
- Entities are business objects used in repositories, usecases, and presentation
- Usecases group related operations into one file per domain (e.g. `user_usecases.dart` contains `GetUserUsecase`, `CreateUserUsecase`, `UpdateUserUsecase`, `DeleteUserUsecase`)
- Usecase params live in `domain/usecases/params/`; use `NoParam` for parameterless usecases
- Notifiers hold UI logic separate from screens; State classes hold UI state managed by the Notifier
- Components are widgets scoped to a screen folder; Widgets (`app_*`) are shared across screens

### Data Flow

**Read (simple):** Notifier → Repository → Datasource → DB/Network
**Read (complex):** Notifier → Usecase → Repositories → Datasources → DB/Network
**Write (simple):** Notifier → Repository → Datasource → DB/Network
**Write (complex):** Notifier → Usecase → Repositories → Datasources → DB/Network

### Implementation Approach

- **Never use the simplest approach** — always use the correct, well-structured approach that follows the existing codebase patterns.
- **Before implementing any task**, search the codebase for a similar existing pattern and follow it exactly. If a screen, notifier, or service already does something similar, replicate its structure.
- **Never access repositories or datasources directly from UI (screens/widgets)**. Always go through a Notifier. Even for simple reads, create a notifier if one doesn't exist.
- **Every screen that loads data** should have a corresponding notifier+state. No inline `ref.read(repoProvider)` from screens.
- **Follow existing naming conventions** — match verb patterns already used in the codebase (e.g. if existing notifiers use `loadX`, don't introduce `fetchX`).

### Usecase Rules

- Usecases are grouped by domain in a single `*_usecases.dart` file (e.g. `user_usecases.dart`, `auth_usecases.dart`).
- Each operation is its own class extending `Usecase<Result, Params>`.
- Use `NoParam` from `lib/domain/usecases/params/no_param.dart` for parameterless calls.
- Notifiers instantiate usecases on-demand: `await GetUserUsecase(repo).call(id)`.

## State Management

**Riverpod** with Notifier/State pattern:

- `NotifierProvider<T, S>` for global state
- `AutoDisposeNotifier` for ephemeral state (forms, dialogs) that should clean up automatically
- State classes in separate files (`*_state.dart`) alongside notifiers (`*_notifier.dart`)
- Screens use `ConsumerWidget` or `ConsumerStatefulWidget`
- Cache `ref.read(provider)` in a local variable before passing to constructors or methods. Never call `ref.read(someProvider)` repeatedly or inline in parameters.

## Routing

**GoRouter** with nested navigation via `ShellRoute`. Auth-aware redirects using `refreshListenable`. Navigate with `context.push()`, `context.go()`, `context.pop()`.

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
| Usecases (grouped)    | `*_usecases.dart`                        | `product_usecases.dart`              |
| Usecase params        | `*_param.dart` / `*_params.dart`         | `base_params.dart`, `no_param.dart`  |
| Reusable widgets      | `app_*.dart`                             | `app_button.dart`                    |
| Screen components     | `components/*.dart`                      | `components/cart_panel_body.dart`    |

### Classes (PascalCase)

- Datasources: `UserDatasource`, `UserRemoteDatasourceImpl`, `UserLocalDatasourceImpl`
- Repositories: `UserRepository`, `UserRepositoryImpl`
- Usecases: `GetUserUsecase`, `CreateProductUsecase` (one word — `Usecase`, not `UseCase`)
- Notifiers: `ProductsNotifier`, `AuthNotifier`
- States: `ProductsState`, `AuthState`
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
- **Skip `flutter analyze`** for small changes (few files). Only run it for large changes (new features, refactors across many files). Even targeted analyze is slow. Rely on IDE diagnostics and `dart format` for small edits.

### Readability Rules

- No unnecessary comments, no decorative or separator lines. Only important comments.
- Prioritize human readability — clean spacing, clear structure, no visual clutter.
- Always add an empty line to separate `if`, `return`, `for`, function definitions, logical groups of variables, and other logical blocks.
- No unnecessary empty lines or separators between child/children widgets in UI.
- Never use `Widget _foo()` builder methods — create dedicated `_FooWidget` classes instead.
- Never use `setState((){})` except for small leaf widgets where state management is overkill.
- Always use `AppSizes` constants for spacing instead of hardcoded numbers.

### Patterns

- **Result type**: `Result<T>` wrapper (Success/Failure) for error handling — not exceptions
- **Usecase pattern**: Abstract `Usecase<Result, Params>` class, grouped by domain in `*_usecases.dart` files, one class per operation
- **Composition over inheritance**: Screens split into private `_Widget` sub-components
- **Equatable**: Used for value equality on entities and states
- **Form screens**: Track initial field values, detect changes with `_hasChanges`, use `PopScope` with confirm-discard dialog
- **Detail screens**: Load data via notifier by ID (not passed as entity param), reload after edit/delete
- **List screens**: Use scroll pagination (`NotificationListener<ScrollNotification>`) with `loadMore()`, search field with `onSearchChanged()`
- **Shared dialogs**: Static class with private constructor and static `show()` method
- **Service classes**: Static class with private constructor for utilities (e.g. `PrinterService`, `DeviceInfoService`)

## Reference Docs

- `UI.md` — UI reference (layouts, components, design specs)
- `DATABASE.md` — Database schema reference (tables, columns, queries)
- `WORKFLOW.md` — Git workflow (commits, branches, PRs)

These docs may not exist yet. If provided, follow them.

## Quick Commands

```bash
flutter run                                                 # run app
flutter analyze                                             # lint
dart fix --apply                                            # quick fixes
dart format lib/ test/ --line-length=120                    # format
flutter test                                                # tests
flutter gen-l10n                                            # regenerate l10n
dart run build_runner build --delete-conflicting-outputs    # codegen
```

## Testing

- Unit tests with `mockito` for mocking
- Fake/mock implementations for external services (Firebase, databases, etc.)
- Dedicated test initialization methods (e.g., `initTestDatabase()`) for isolated tests
