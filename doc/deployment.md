# Deployment

Tags: #deployment #devops

Every service ships as a Debian package and runs under systemd. There is no
container runtime in production; the host is the unit of isolation.

## Releasing

Build the package with `scripts/package.sh`, copy it to the target host, and
install it with `dpkg -i`. The `postinst` script enables and starts the
service.

## Secrets

Secrets are written to `/etc/<service>/env` with mode `0600` and injected as
environment variables by the systemd unit. They never appear in the package.

## Rollback

Keep the previous package on the host. A rollback is `dpkg -i` of the older
version followed by a service restart.
