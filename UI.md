# UI.md - UI Reference

## Reusable Widgets (`lib/presentation/widgets/`)

| Widget                     | Purpose                                      | Key Props                                                                 |
| -------------------------- | -------------------------------------------- | ------------------------------------------------------------------------- |
| `AppButton`                | Primary action button                        | text, onTap, buttonColor, textColor, borderColor, enabled, child          |
| `AppIconButton`            | Circular icon button                         | icon, onTap, iconSize, enabled, padding                                   |
| `AppTextField`             | Text input with variants                     | controller, hintText, labelText, type (general/search/currency), onChanged |
| `AppDropDown`              | Single or multi-select dropdown              | selectedValue, dropdownItems, onChanged, labelText                        |
| `AppDialog`                | Modal dialog (static: show, showError, showProgress) | title, text, child, leftButtonText, rightButtonText, dismissible  |
| `AppSnackBar`              | Snackbar (static: show, showError)           | message, context                                                          |
| `AppProgressIndicator`     | Centered loading spinner                     | message, showMessage                                                      |
| `AppLoadingMoreIndicator`  | Animated loading indicator for infinite scroll | isLoading, padding                                                       |
| `AppEmptyState`            | Empty state placeholder                      | title, subtitle, buttonText, onTapButton                                  |
| `AppErrorWidget`           | Error display (full or text-only)            | error, message, textOnly                                                  |

## Screen Structure

Screens follow a consistent pattern:

- `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod access
- `Scaffold` with custom `AppBar`
- `RefreshIndicator` for pull-to-refresh
- `CustomScrollView` with `SliverGrid` for list/grid layouts
- Infinite scroll via `ScrollController` listener
- Empty/loading/error states handled inline

### Grid Layout

```dart
SliverGrid(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,
    childAspectRatio: 1 / 1.5,
    crossAxisSpacing: AppSizes.padding / 2,
    mainAxisSpacing: AppSizes.padding / 2,
  ),
)
```

## Screen Components

Each screen can have a `components/` subfolder for private sub-widgets specific to that screen.

```
screens/
└── home/
    ├── home_screen.dart
    └── components/
        ├── cart_panel_header.dart
        ├── cart_panel_body.dart
        └── cart_panel_footer.dart
```

## Sizing & Spacing (`AppSizes`)

| Constant       | Value | Usage                          |
| -------------- | ----- | ------------------------------ |
| `padding`      | 18    | Standard padding/margin        |
| `margin`       | 18    | Standard margin                |
| `radius`       | 8     | Border radius                  |
| `padding / 2`  | 9     | Tight spacing                  |
| `padding / 4`  | 4.5   | Minimal spacing                |
| `padding * 2`  | 36    | Large spacing                  |

Responsive helpers: `screenWidth(context)`, `screenHeight(context)`, `viewPadding(context)`, `appBarHeight()`

## Color Usage

Always reference colors via `Theme.of(context).colorScheme`:

```dart
colorScheme.primary
colorScheme.surface
colorScheme.surfaceContainer
colorScheme.surfaceContainerLowest
colorScheme.onSurface
colorScheme.onSurfaceVariant
colorScheme.outline
colorScheme.error
colorScheme.tertiary
colorScheme.secondary
```

Text styles via `Theme.of(context).textTheme`: `bodySmall`, `bodyMedium`, `bodyLarge`, `labelSmall`, `labelLarge`, `titleMedium`, `titleLarge`.

## UI Patterns

- **Disabled state**: 0.5 opacity on buttons/cards
- **Out-of-stock overlay**: Semi-transparent white layer with badge
- **Dialogs/Snackbars**: Use `AppRoutes.rootNavigatorKey` for global context access
- **Animations**: `AnimatedContainer`, `AnimatedSwitcher` for state transitions
- **Performance**: `RepaintBoundary` on repeated list/grid items
