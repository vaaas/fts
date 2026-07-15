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
fts PATH                    Print a document.
```

A single argument that is an existing file is printed rather than searched, so
`fts doc/auth-flow.md` opens that page. (For anything else, `cat` works too.)

### Options

| Option | Description | Default |
| --- | --- | --- |
| `-i` | Build (initialise) the search index | |
| `-n N` | Maximum number of results | `10` |
| `-s S` | Minimum relevance score; drops weaker matches | `0` |
| `-d DIR` | Documents folder | `./doc` |
| `-b FILE` | Index database file | `./.fts.db` |
| `-h` | Show help | |

Options must come before the query. The documents folder and database file can
also be set with the `FTS_DOCS` and `FTS_DB` environment variables.

### Examples

```sh
fts token refresh        # any term may match; more matches rank higher
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
weights that favour title and tag hits. Query terms are combined with `OR`, so
any term can match and bm25 floats the documents matching more (and rarer)
terms to the top. Re-run `fts -i` whenever the documents change.

The index is tokenised with the `porter` stemmer, so a search matches across
word forms — `refreshing` finds `refresh`, `conventions` finds `convention` —
without the query having to guess the exact wording in the document. Documents
whose only matches are on non-discriminative terms (scoring at FTS5's clamped
floor) are dropped by the default minimum score.

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

## Why this approach

`fts` bets that a plain ranked, grep-like search over documents is a strong fit
for LLM agents — cheaper and simpler than a vector database, and closer to the
tooling agents already know. These sources informed that bet.

**Academic papers**

- Is Grep All You Need? How Agent Harnesses Reshape Agentic Search — <https://arxiv.org/abs/2605.15184>
- EnterpriseRAG-Bench: A RAG Benchmark for Company Internal Knowledge — <https://arxiv.org/abs/2605.05253>
- GrepRAG: An Empirical Study and Optimization of Grep-Like Retrieval for Code Completion — <https://arxiv.org/abs/2601.23254>
- AutoRAG: Automated Framework for optimization of Retrieval Augmented Generation Pipeline — <https://arxiv.org/abs/2410.20878>

**Independent benchmarks & practitioner writeups**

- I benchmarked code retrieval for AI coding agents on 60 tasks (Sverklo) — <https://sverklo.com/blog/i-benchmarked-code-retrieval-for-ai-agents/>
- Is grep really better than a vector DB? (Sara Zan) — <https://www.zansara.dev/posts/2026-03-15-vector-dbs-vs-grep/>
- AI Agents Don't Need Vector Search Anymore: Inside the Agentic Search Stack Replacing RAG in 2026 (Medium) — <https://buzzgrewal.medium.com/ai-agents-dont-need-vector-search-anymore-inside-the-agentic-search-stack-replacing-rag-in-2026-58efcabe4f6f>
- Grep Beats Vector Retrieval In Agent Harnesses For Fact Retrieval (Digg) — <https://digg.com/ai/0fabn997>
- Is Grep All You Need? Grep vs Vector Retrieval for Agentic Search (DEV Community) — <https://dev.to/pueding/is-grep-all-you-need-grep-vs-vector-retrieval-for-agentic-search-534k>

**Tooling (the search/index approach itself)**

- ripgrep-all (rga) — <https://github.com/phiresky/ripgrep-all>
- rga introductory blogpost (phiresky) — <https://phiresky.github.io/blog/2019/rga--ripgrep-for-zip-targz-docx-odt-epub-jpg/>
- ripgrep — <https://github.com/BurntSushi/ripgrep>
