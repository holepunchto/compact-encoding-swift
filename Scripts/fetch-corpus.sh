#!/bin/sh
# Resolves the compact-encoding corpus into .corpus/, which is gitignored: the
# fixtures are pinned here rather than vendored, so a case added upstream
# arrives by bumping VERSION and SHA256 together.
set -eu

VERSION=0.3.1
SHA256=e1f518f05e52f22d6602d6e14e48323f0dde8ce19b557a67fd8bce74d6d109ab

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
dest=$root/.corpus
tarball=compact-encoding-test-$VERSION.tgz
url=https://registry.npmjs.org/compact-encoding-test/-/$tarball

if [ -f "$dest/VERSION" ] && [ "$(cat "$dest/VERSION")" = "$VERSION" ]; then
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -sSfL --retry 3 -o "$tmp/$tarball" "$url"
echo "$SHA256  $tmp/$tarball" | sha256sum -c -

rm -rf "$dest"
mkdir -p "$dest"
tar xzf "$tmp/$tarball" -C "$dest" --strip-components=1
echo "$VERSION" > "$dest/VERSION"
