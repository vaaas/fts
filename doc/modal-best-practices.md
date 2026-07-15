# Modal Best Practices

Tags: #frontend #styling #accessibility

A modal traps focus, dims the page behind it, and closes on `Escape`. If it
does not do all three, it is not finished.

## Focus management

When a modal opens, move focus to the first interactive element inside it. When
it closes, return focus to the element that opened it.

## Scroll locking

Lock the background scroll while the modal is open, but preserve the scroll
position so the page does not jump when the modal closes.

## Avoid nesting

A modal that opens another modal is a design smell. Prefer a single modal whose
content changes, or a dedicated page.
