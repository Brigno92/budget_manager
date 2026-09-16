---
name: flutter-development
description: Develop and refactor Flutter/Dart applications using the project's existing architecture, state management, dependency injection, navigation, networking, persistence, and testing conventions. Use for Flutter feature implementation, refactoring, bug fixes, models, services, repositories, and application logic.
---

# Flutter Development

## Workflow

1. Inspect:
   - `pubspec.yaml`
   - `analysis_options.yaml`
   - `lib/`
   - `test/`
   - relevant platform/configuration files
2. Identify:
   - Flutter/Dart version
   - architecture
   - state-management library
   - dependency-injection approach
   - routing solution
   - API/client layer
   - persistence solution
   - serialization/code-generation tools
3. Check `git status`.
4. Find the smallest set of files that should change.
5. Implement the feature following existing conventions.
6. Format and analyze.
7. Run focused tests and then broader relevant tests.
8. Inspect `git diff`.

## Architecture

Respect the architecture already present. If the project has no clear structure, prefer a feature-oriented organization such as:

```text
lib/
  core/
  features/
    <feature>/
      data/
      domain/
      presentation/
```

Do not introduce Clean Architecture, BLoC, Riverpod, Provider, etc. merely because it is theoretically preferred. Match the project's current conventions first.

## Dart Models

- Prefer typed classes.
- Keep serialization concerns explicit.
- Reuse existing generated serialization if present (`json_serializable`, `freezed`, etc.).
- Avoid leaking raw JSON maps through application/business logic.
- Handle nullable and missing API fields deliberately.

## Async Code

- Use `Future`/`Stream` idiomatically.
- Represent loading, success, empty, and error states explicitly when the UI needs them.
- Avoid unbounded subscriptions.
- Cancel/dispose resources owned by the component.
- Do not silently catch exceptions.

## State Management

Use the state-management solution already used by the project.

When modifying state:
- identify the source of truth;
- keep mutations localized;
- avoid duplicated derived state;
- prevent unnecessary rebuilds;
- preserve existing lifecycle semantics.

## Networking and Repositories

Keep HTTP/client-specific code out of Widgets.

A typical flow is:

```text
Widget
  -> state/controller/notifier
  -> repository/service
  -> API client
```

Adapt this to the project's actual architecture.

## Error Handling

Distinguish:
- validation errors;
- expected business errors;
- authentication/authorization failures;
- network failures;
- unexpected programming errors.

Do not convert every exception into a generic success/failure boolean.

## Dependency Changes

Before adding a package:
1. Check whether the Dart/Flutter SDK already supports the requirement.
2. Check existing dependencies.
3. Prefer a package already used by the project.
4. If a new dependency is necessary, explain why and use the version compatible with the project's SDK constraints.

## Validation

Use the project's commands. Common commands are:

```bash
dart format .
flutter analyze
flutter test
```

If generated code is involved, identify the project's generation command before running it.

## Output

At completion, report:
- what changed;
- tests/analyzer/formatting executed;
- any remaining issue;
- proposed Conventional Commit.
