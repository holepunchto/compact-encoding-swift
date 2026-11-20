#!/bin/sh
# Resolves the compact-encoding corpus into .corpus/, which is gitignored: the
# fixtures are pinned here rather than vendored, so a case added upstream
# arrives by bumping VERSION and SHA256 together.
set -eu

VERSION=0.3.0
SHA256=effe7a66dc4d48442de1c2897f81ad6e3a29376384e6bd67b33bfd63d94e7da9

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
