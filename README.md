# fts

Full-text search over a folder of markdown documents, powered by `sqlite3` and
a small POSIX shell script. No runtime, no services — one file and a database.

## Requirements

- `sqlite3` (built with the FTS5 extension, which is the default)
- a POSIX shell (`sh`/`dash`/`bash`)

## Quick start

```sh
./fts --init        # scan ./doc and build the search index
./fts backend       # search, best matches first
```

```
1.0865  ./doc/database-conventions.md  Database Conventions
        # Database Conventions  Tags: #backend #database #conventions  We use…
1.0664  ./doc/auth-flow.md  Authentication Flow
        # Authentication Flow  Tags: #auth #backend #security  Our services…
```

Each result is two lines — `score  path  title`, then an indented sample of the
matching text — ordered by relevance (higher is better). The sample is drawn
from around the match, so you can judge a hit without opening the file.

## Usage

```
fts --init [--docs DIR] [--db FILE]   Build the search index from markdown files.
fts [options] QUERY...                Search the index, best matches first.
fts --show PATH                       Print a document.
```

A single argument that is an existing file is printed rather than searched, so
`fts doc/auth-flow.md` opens that page.

### Options

| Option | Description | Default |
| --- | --- | --- |
| `-n`, `--limit N` | Maximum number of results | `10` |
| `-s`, `--min-score S` | Minimum relevance score; drops weaker matches | `0` |
| `--docs DIR` | Documents folder | `./doc` |
| `--db FILE` | Index database file | `./.fts.db` |
| `-h`, `--help` | Show help | |

The documents folder and database file can also be set with the `FTS_DOCS` and
`FTS_DB` environment variables.

### Examples

```sh
fts token refresh          # multiple words are combined (all must match)
fts -n 5 deployment        # cap the number of results
fts -s 1.0 database        # only reasonably strong matches
fts --docs ./notes --init  # index a different folder
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

`--init` walks the documents folder for `*.md` files and inserts each into a
sqlite3 [FTS5](https://www.sqlite.org/fts5.html) virtual table with four
columns: `path`, `title`, `tags`, and `body`. The title is the first `#`
heading (falling back to the filename), and tags are extracted with a `#tag`
pattern.

Queries run through FTS5's `MATCH` and are ranked with `bm25`, using per-column
weights that favour title and tag hits. Re-run `fts --init` whenever the
documents change.

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
