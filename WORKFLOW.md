# WORKFLOW.md - Git Workflow

## Commit Messages

Follow **Conventional Commits** format:

```
<type>: <description>
```

| Type       | Usage                                |
| ---------- | ------------------------------------ |
| `feat`     | New feature                          |
| `fix`      | Bug fix                              |
| `refactor` | Code refactoring (no behavior change)|
| `chore`    | Maintenance, dependency updates      |
| `docs`     | Documentation changes                |
| `test`     | Adding or updating tests             |
| `style`    | Formatting, code style changes       |

## Branch Naming

```
<type>/<description>
```

| Type       | Example                        |
| ---------- | ------------------------------ |
| `feature/` | `feature/thermal-print`        |
| `fix/`     | `fix/firestore-query`          |
| `refactor/`| `refactor/riverpod-migration`  |
| `chore/`   | `chore/flutter-upgrade`        |

Use lowercase with hyphens for description.

## Workflow

1. Create a branch from `main` using the naming convention above
2. Make changes and commit with conventional commit messages
3. Push branch and create a pull request to `main`
4. Merge via merge commit (preserve full history)
