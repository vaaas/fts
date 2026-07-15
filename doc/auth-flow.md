# Authentication Flow

Tags: #auth #backend #security

Our services authenticate requests with short-lived bearer tokens. A client
exchanges credentials at the `/login` endpoint and receives an access token
plus a refresh token.

## Token lifetime

Access tokens expire after fifteen minutes. When a request arrives with an
expired token the gateway returns `401`, and the client silently refreshes
using the refresh token before retrying.

## Where tokens live

Never store tokens in local storage. Keep the access token in memory and the
refresh token in a secure, http-only cookie. This limits the blast radius of a
cross-site scripting bug.

See also the deployment notes for how secrets are injected into containers.
