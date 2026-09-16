# Flutter Development Rules

## Language
- Communicate with the user in Italian.
- Write code, identifiers, commit messages, and code comments in English.

## Project Detection
- Detect the Flutter/Dart ecosystem from `pubspec.yaml`, `analysis_options.yaml`, `lib/`, `test/`, and platform folders.
- Use the project's existing Flutter/Dart version and conventions.
- Do not introduce a framework, package, or architecture pattern that is not justified by the existing project.

## General Development Rules
- Inspect the existing implementation before modifying it.
- Check `git status` before making changes.
- Prefer small, focused, modular changes following Single Responsibility Principle.
- Do not rewrite entire files when a focused edit is sufficient.
- Preserve existing public APIs unless the task requires a breaking change.
- Never swallow exceptions. Handle, propagate, or log them intentionally.
- Prefer immutable data and `final` where practical.
- Keep business logic out of Widgets.
- Keep UI declarative and predictable.
- Avoid unnecessary rebuilds.
- Do not add dependencies without checking whether the SDK or an existing dependency already provides the required capability.

## Flutter/Dart
- Follow Dart formatting and effective Dart conventions.
- Use `const` constructors/widgets wherever possible.
- Prefer composition over inheritance for UI.
- Keep Widgets small and focused.
- Separate presentation, state/application logic, domain logic, and data access according to the project's existing architecture.
- Dispose controllers, streams, subscriptions, and other owned resources correctly.
- Use null safety properly; do not bypass it with unnecessary `!`.
- Prefer typed models over `Map<String, dynamic>` outside serialization boundaries.
- Keep JSON/API mapping isolated from domain models when the project architecture supports it.
- Respect the project's existing state-management solution. Do not introduce Provider, Riverpod, Bloc/Cubit, GetX, etc. unless required by the task or already used.

## Testing
- Run the project's existing formatter, analyzer, and tests after meaningful changes.
- Prefer focused tests first, then the relevant broader test suite.
- Add tests for non-trivial business logic and state transitions.
- For Widgets, test user-visible behavior rather than implementation details where practical.
- If a command fails after a change, investigate and repair the issue rather than leaving the project broken.

Typical commands, only when supported by the project:
- `dart format .`
- `flutter analyze`
- `flutter test`
- `flutter test test/path/to_test.dart`

## Assets and Generated Code
- Respect existing generated-code conventions.
- Do not manually edit generated files unless the project explicitly requires it.
- Check asset declarations in `pubspec.yaml` before adding or moving assets.
- Keep localization, assets, and configuration consistent with the existing project.

## Git
- Do not create commits unless explicitly requested.
- Before modifications, inspect `git status`.
- After a successful task, propose a Conventional Commit message.
- Do not modify unrelated user changes.

## Completion Checklist
Before reporting completion:
1. Verify the changed files.
2. Run relevant formatting/analyzer/tests.
3. Check `git diff`.
4. Confirm no unrelated files were changed.
5. Report commands executed and their outcome.
6. Propose a Conventional Commit message.
