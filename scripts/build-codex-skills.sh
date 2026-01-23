#!/usr/bin/env bash
set -euo pipefail

#######################################
# Excluded skill directories
#
# These are directory names under /skills
#######################################
CODEX_SKILLS_EXCLUDE=(
  ".DS_Store"
)

#######################################
# Paths
#######################################
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"
AGENTS_ROOT="$REPO_ROOT/agents"
DIST_DIR="$REPO_ROOT/dist"
STAGING_DIR="$DIST_DIR/codex-skills"
OUT_SKILLS_DIR="$STAGING_DIR/skills"

#######################################
# Preconditions
#######################################
if [[ ! -d "$SKILLS_ROOT" ]]; then
  echo "ERROR: /skills directory not found" >&2
  exit 1
fi

if [[ ! -d "$AGENTS_ROOT" ]]; then
  echo "ERROR: /agents directory not found" >&2
  exit 1
fi

#######################################
# Resolve version
#######################################
if [[ -n "${RELEASE_PLEASE_VERSION:-}" ]]; then
  VERSION="$RELEASE_PLEASE_VERSION"
elif [[ -f "$REPO_ROOT/package.json" ]]; then
  VERSION="$(node -p "require('./package.json').version")"
else
  VERSION="$(git describe --tags --abbrev=0 | sed 's/^v//')"
fi

if [[ -z "$VERSION" ]]; then
  echo "ERROR: Unable to determine release version" >&2
  exit 1
fi

#######################################
# Prepare staging directory
#######################################
rm -rf "$STAGING_DIR"
mkdir -p "$OUT_SKILLS_DIR"

#######################################
# Copy all skills by default
#######################################
cp -R "$SKILLS_ROOT/." "$OUT_SKILLS_DIR/"

#######################################
# Apply exclude list
#######################################
for excluded in "${CODEX_SKILLS_EXCLUDE[@]}"; do
  rm -rf "$OUT_SKILLS_DIR/$excluded"
done

#######################################
# Materialize agent skills
#
# /agents/foo.md -> /skills/foo/SKILL.md
#######################################
shopt -s nullglob
for agent_md in "$AGENTS_ROOT"/*.md; do
  name="$(basename "$agent_md
