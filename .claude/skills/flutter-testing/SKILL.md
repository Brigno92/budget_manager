---
name: flutter-testing
description: Create, update, and debug Flutter/Dart unit tests, widget tests, integration tests, mocks, fixtures, and test infrastructure. Use when testing behavior or repairing test failures.
---

# Flutter Testing

## Test Strategy

Choose the narrowest appropriate level:

- Unit test: pure business/domain logic.
- Widget test: UI behavior and interaction.
- Integration test: end-to-end flows involving multiple application layers/platform behavior.

Prefer behavior over implementation details.

## Before Writing Tests

Inspect:
- existing test structure;
- test naming conventions;
- mocking library;
- fixtures/factories;
- shared test helpers;
- existing golden-test conventions.

Do not introduce a second mocking/testing framework without a concrete reason.

## Unit Tests

Cover:
- normal behavior;
- boundary conditions;
- invalid input;
- relevant exceptions;
- important state transitions.

Keep tests deterministic.

## Widget Tests

Verify user-visible behavior:
- widgets render correctly;
- loading/error/empty states;
- taps and text input;
- validation;
- navigation callbacks where appropriate.

Avoid tests that merely assert private implementation details.

## Async Tests

Use Flutter/Dart test APIs correctly and wait for asynchronous work rather than adding arbitrary delays.

## Golden Tests

If the project uses golden tests:
- follow its existing naming and update workflow;
- update goldens only when the visual change is intentional;
- inspect the resulting visual difference when possible.

## Debugging Failures

1. Reproduce the smallest failing test.
2. Determine whether the failure is production code, test code, fixture, timing, or environment.
3. Fix the root cause.
4. Re-run the focused test.
5. Run the broader relevant suite.
6. Report the actual result.

Never make a test pass by weakening an assertion without understanding the behavior change.
