# Styling Guide

Tags: #frontend #styling #conventions

We prefer plain CSS with custom properties over heavy frameworks. Keep the
cascade shallow and the specificity low.

## Custom properties

Define colours and spacing as custom properties on `:root`. Components read
them; they never hard-code hex values.

## Layout

Reach for flexbox and grid before absolute positioning. Absolute positioning is
a last resort, not a default.

## Dark mode

Support dark mode with a `prefers-color-scheme` media query that overrides the
custom properties. Do not maintain a second stylesheet.
