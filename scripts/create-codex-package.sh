#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
DIST_DIR="$REPO_ROOT/dist"
STAGING_DIR="$DIST_DIR/codex-skills"

if [[ -n "${RELEASE_PLEASE_VERSION:-}" ]]; then
  VERSION="$RELEASE_PLEASE_VERSION"
elif [[ -f package.json ]]; then
  VERSION="$(node -p "require('./package.json').version")"
else
  VERSION="$(git describe --tags --abbrev=0 | sed 's/^v//')"
fi

ARCHIVE="codex-skills-${VERSION}.tar.gz"
tar -czf "$DIST_DIR/$ARCHIVE" -C "$STAGING_DIR" skills
