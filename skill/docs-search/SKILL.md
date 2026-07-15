---
name: docs-search
description: Search the project's knowledge base of markdown docs for conventions, decisions, and reference material. Use whenever you need project docs, past decisions, or internal conventions before answering from memory or asking the user. Triggers on questions about how this project does things (auth, deployment, styling, database, logging, tags).
---

## Documentation search

When you need project docs, conventions, or past decisions, search the
knowledge base before answering from memory or asking me:

    fts <query>            # full-text + tag search, grep-style path:text lines
    fts <path>             # print a full page

The command figures out whether the argument is a query or a path: a single
argument that is an existing file is printed, anything else is searched.

Examples:

    fts modal              # → "Modal Best Practices", "Styling Guide", ...
    fts auth flow
    fts doc/auth-flow.md   # print the page
    fts backend            # tag search: pages tagged #backend rank first

Tags are written as `#tag` inside documents. Searching the bare word (`fts
backend`) surfaces anything tagged `#backend`, because tags are indexed and
weighted above ordinary body text.

Useful flags:

    fts -n 5 deployment        # cap the result count
    fts -s 1.0 database        # drop weak matches below a relevance score

If the index is missing, build it once with `fts -i` (it scans the `doc`
folder). Re-run `fts -i` after docs change.

Prefer this over guessing. Multiple searches with refined terms is normal and
expected — that's how the system is meant to be used.
