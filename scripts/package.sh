#!/bin/sh
# Build a Debian package that installs `fts` to /usr/bin.
# Usage: scripts/package.sh [version]   (version defaults to a unix timestamp)
set -e

cd "$(dirname "$0")/.."

name=fts
version="${1:-$(date '+%s')}"
arch=all
dirname="$name"_"$version"_"$arch"

rm -rf "$dirname"
mkdir -p "$dirname/DEBIAN" "$dirname/usr/bin"

cp fts "$dirname/usr/bin/fts"
chmod 755 "$dirname/usr/bin/fts"
chmod 755 "$dirname/DEBIAN"

cat << EOF > "$dirname/DEBIAN/control"
Package: $name
Version: $version
Architecture: $arch
Maintainer: Vasileios Pasialiokis <vas@postquant.xyz>
Description: full-text search over markdown docs, powered by sqlite3
 Scan a folder of markdown files into a sqlite3 FTS5 index and query it
 from the command line, ranked by relevance, with support for #tags.
Depends: sqlite3
EOF

dpkg-deb --build --root-owner-group "$dirname"
rm -rf "$dirname"

echo "built $dirname.deb"
