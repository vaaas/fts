# Logging and Observability

Tags: #observability #devops

Logs are structured JSON, one object per line, written to standard output. The
host's journal captures them; we do not manage log files inside services.

## What to log

Log the start and end of every request with a correlation id, the outcome, and
the duration in milliseconds. Do not log credentials or bearer tokens.

## Levels

Use `error` for conditions a human must act on, `warn` for recoverable
surprises, and `info` for the request lifecycle. Debug logging is off in
production and toggled per service without a redeploy.

## Metrics

Counters and histograms live alongside logs. A request that is worth logging is
usually worth counting.
