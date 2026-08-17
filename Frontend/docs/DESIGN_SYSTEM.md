# HomeFix Flutter Design System

This document defines the shared visual language for the `frontend-ui-redesign` phase. It is intentionally presentation-only: API contracts, authentication, pricing, payment, authorization, and business rules remain in the existing production-hardening architecture.

## Brand

Customer-facing primary: Sky Blue (`AppColors.primary`).
Technician-facing accent: Amber (`AppColors.technicianPrimary`).
Functional colors: Emerald for success, amber for warning, rose for errors, sky for informational states.

## Typography

The app uses the existing Cairo font family and a centralized Material 3 text hierarchy in `AppDesignTokens.baseTextTheme`.

Use semantic text styles (`titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, etc.) instead of screen-specific font sizes.

## Spacing

Use the 4pt-based scale exposed by `AppDesignTokens`: 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, and 64.

## Shape

Standard corners are 8, 10, 12, 16, and 20dp. Pill components use `AppDesignTokens.radiusPill`.

## Components

Use these shared primitives before creating a screen-specific equivalent:

- `HomeFixButton` for primary, secondary, outline, text, and destructive actions.
- `HomeFixCard` and `HomeFixSectionHeader` for content grouping.
- `HomeFixField` and `HomeFixDropdown` for forms.
- `HomeFixStatusChip` for semantic status indicators.
- `HomeFixSkeleton`, `HomeFixLoadingList`, `HomeFixErrorState`, and `HomeFixSuccessBanner` for async state presentation.
- `HomeFixContent` / `AppResponsive` for responsive page widths and padding.

## Motion

Prefer the shared 160ms/220ms/320ms durations and ease-out/ease-in-out curves. Animations should reinforce hierarchy and state changes, not distract from tasks.

## Responsive behavior

Avoid fixed screen dimensions. Use `AppResponsive.pagePadding`, constrained content widths, `LayoutBuilder`, and flexible row/column layouts for small phones, large phones, and tablet-sized screens.

## Accessibility

Keep touch targets at or above 48dp, preserve readable contrast, and use semantic labels for icon-only actions. The redesign must remain usable with increased text scaling and both RTL and LTR content.
