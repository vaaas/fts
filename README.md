# fts

Full-text search over a folder of markdown documents, powered by `sqlite3` and
a small POSIX shell script. No runtime, no services — one file and a database.

## Requirements

- `sqlite3` (built with the FTS5 extension, which is the default)
- a POSIX shell (`sh`/`dash`/`bash`)

## Quick start

```sh
./fts -i            # scan ./doc and build the search index
./fts backend       # search, best matches first
```

```
./doc/database-conventions.md:# Database Conventions  Tags: #backend #database …
./doc/auth-flow.md:# Authentication Flow  Tags: #auth #backend #security  Our …
```

Each result is a single `path:text` line — the same shape as `grep -r` — where
`text` is a sample drawn from around the match. Results are ordered by
relevance (best first) rather than by filename, so the ranking shows in the
order. The format is deliberately grep-like so tools and LLMs can parse it
without special handling.

## Usage

```
fts -i [-d DIR] [-b FILE]   Build the search index from markdown files.
fts [options] QUERY...      Search the index, best matches first.
fts -p PATH                 Print a document.
```

A single argument that is an existing file is printed rather than searched, so
`fts doc/auth-flow.md` opens that page (`-p` does the same, explicitly).

### Options

| Option | Description | Default |
| --- | --- | --- |
| `-i` | Build (initialise) the search index | |
| `-p` | Print a document instead of searching | |
| `-n N` | Maximum number of results | `10` |
| `-s S` | Minimum relevance score; drops weaker matches | `0` |
| `-d DIR` | Documents folder | `./doc` |
| `-b FILE` | Index database file | `./.fts.db` |
| `-h` | Show help | |

Options must come before the query. The documents folder and database file can
also be set with the `FTS_DOCS` and `FTS_DB` environment variables.

### Examples

```sh
fts token refresh        # multiple words are combined (all must match)
fts -n 5 deployment      # cap the number of results
fts -s 1.0 database      # only reasonably strong matches
fts -d ./notes -i        # index a different folder
```

## Tags

Tags are a lightweight convention: a `#tag` written anywhere in a document, for
example:

```markdown
Tags: #backend #security
```

Tags are indexed into their own column and weighted above ordinary body text,
so searching the bare word surfaces tagged pages first:

```sh
fts backend    # pages tagged #backend rank at the top
```

You do not type the `#` when searching — `fts backend` and `fts #backend`
behave the same.

## How it works

`-i` walks the documents folder for `*.md` files and inserts each into a
sqlite3 [FTS5](https://www.sqlite.org/fts5.html) virtual table with four
columns: `path`, `title`, `tags`, and `body`. The title is the first `#`
heading (falling back to the filename), and tags are extracted with a `#tag`
pattern.

Queries run through FTS5's `MATCH` and are ranked with `bm25`, using per-column
weights that favour title and tag hits. Re-run `fts -i` whenever the documents
change.

## Installing (Debian)

Build a `.deb` and install it so `fts` is on your `PATH`:

```sh
scripts/package.sh 1.0.0        # produces fts_1.0.0_all.deb
sudo dpkg -i fts_1.0.0_all.deb
```

Omit the version argument to use a unix timestamp instead. The package installs
`fts` to `/usr/bin/fts` and depends on `sqlite3`.

## Claude skill (optional)

An optional Claude skill under `skill/docs-search/` teaches Claude to search
your docs with `fts` before answering from memory. Install it by copying the
folder into your skills directory:

```sh
cp -r skill/docs-search ~/.claude/skills/          # for all projects
# or, per project:
cp -r skill/docs-search .claude/skills/
```
