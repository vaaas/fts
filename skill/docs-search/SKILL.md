---
name: docs-search
description: Search the project's knowledge base of markdown docs for conventions, decisions, and reference material. Use whenever you need project docs, past decisions, or internal conventions before answering from memory or asking the user. Triggers on questions about how this project does things (auth, deployment, styling, database, logging, tags).
---

Before answering from memory or asking the user, search the knowledge base:

    fts <query>     # ranked, grep-style path:text results
    fts <path>      # print a page

Run `fts -h` for flags and index setup. Refining terms across several searches
is normal and expected.
