---
name: flutter-ui
description: Build and refactor Flutter UI, screens, widgets, forms, responsive layouts, themes, accessibility, loading/error/empty states, and reusable components. Use when the task is primarily visual or presentation-layer work.
---

# Flutter UI

## Before Coding

Inspect:
- existing screens and reusable widgets;
- theme configuration;
- typography;
- spacing conventions;
- color system;
- localization;
- responsive/breakpoint utilities;
- state-management conventions.

Reuse existing design primitives instead of creating duplicates.

## Widget Design

- Prefer small, focused widgets.
- Extract a widget when it has a meaningful responsibility or is reused.
- Prefer composition.
- Use `const` wherever possible.
- Avoid putting API calls or business rules directly in `build`.
- Keep `build` declarative.
- Avoid excessive nesting when extraction improves readability.

## State

Explicitly consider:
- initial/loading;
- success;
- empty;
- error;
- retry;
- disabled/submitting.

Do not create local state if the existing application state already owns that concern.

## Forms

- Use the project's existing form approach.
- Keep validation close to the relevant field/domain rule.
- Handle keyboard/focus behavior.
- Prevent duplicate submissions.
- Show validation and server errors distinctly when appropriate.
- Dispose `TextEditingController` and `FocusNode` instances when owned by a StatefulWidget/controller.

## Responsive UI

Consider:
- narrow phones;
- large phones;
- tablets;
- portrait/landscape when relevant.

Avoid hard-coded dimensions when they cause overflow or prevent adaptation.

## Accessibility

When appropriate:
- provide semantic labels;
- preserve sufficient touch target sizes;
- ensure controls are keyboard/focus accessible on supported platforms;
- do not communicate information using color alone.

## Performance

Watch for:
- unnecessary rebuilds;
- expensive work in `build`;
- missing `const`;
- large lists without appropriate lazy builders;
- unnecessary image decoding;
- repeated computations that can be derived once.

## Visual Changes

When implementing from an existing design:
1. identify the reusable components;
2. implement structure;
3. apply theme/spacing/typography;
4. implement states;
5. verify responsive behavior;
6. run analyzer/tests.

Do not replace the project's design system with a new one unless explicitly requested.
