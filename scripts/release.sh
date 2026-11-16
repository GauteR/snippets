#!/usr/bin/env bash
# Run unit tests, then package Snippets with BigWigs .release/release.sh (optional upload).
#
# Usage:
#   ./scripts/release.sh --dry-run
#   ./scripts/release.sh --skip-tests --dry-run
#   ./scripts/release.sh -- [extra release.sh args...]
#
# Non-dry-run ensures annotated tag v{Config.VERSION} on HEAD, pushes it to origin,
# then creates a GitHub Release (gh) with --generate-notes and the forever zip asset.
set -euo pipefail

PACKAGE_NAME="snippets"
CONFIG_PATH_REL="snippets/Config.lua"

DRY_RUN=0
SKIP_TESTS=0
EXTRA_ARGS=()
RELEASE_VERSION=
RELEASE_TAG=

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dry-run) DRY_RUN=1; shift ;;
    --skip-tests) SKIP_TESTS=1; shift ;;
    --) shift; EXTRA_ARGS+=("$@"); break ;;
    -h|--help)
      sed -n '2,10p' "$0"
      exit 0
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# BigWigs packager requires a .git directory; linked worktrees use a .git file and
# resolve packaging to the primary checkout instead.
if [[ -f "$REPO_ROOT/.git" ]]; then
  echo "Run release from the primary git checkout, not a linked worktree (packager needs a .git directory)." >&2
  exit 1
fi

load_dotenv() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  # Export KEY=VALUE lines; do not overwrite non-empty existing env vars.
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    [[ "$line" == *=* ]] || continue
    local name="${line%%=*}"
    local value="${line#*=}"
    name="${name%"${name##*[![:space:]]}"}"
    name="${name#"${name%%[![:space:]]*}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    if [[ "$value" == \"*\" && "$value" == *\" ]]; then
      value="${value:1:${#value}-2}"
    fi
    if [[ -z "${!name:-}" ]]; then
      # Literal assign — do not expand $() / $vars inside values.
      printf -v "$name" '%s' "$value"
      export "$name"
    fi
  done < "$file"
  return 0
}

loaded=0
if load_dotenv "$REPO_ROOT/.release/.env"; then loaded=1; fi
if load_dotenv "$REPO_ROOT/.env"; then loaded=1; fi
if [[ $loaded -eq 1 ]]; then
  echo "==> Loaded local token env file(s)"
fi

# Ensure annotated v{Config.VERSION} on HEAD and push to origin (real releases only).
ensure_version_tag() {
  local config_path="$1"
  local version tag tag_commit head_commit
  if [[ ! -f "$config_path" ]]; then
    echo "Missing Config.lua at $config_path" >&2
    exit 1
  fi
  version="$(sed -nE 's/^[[:space:]]*VERSION[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$config_path" | head -n 1)"
  if [[ -z "$version" ]]; then
    echo "Could not resolve Config.VERSION from $config_path" >&2
    exit 1
  fi
  tag="v${version}"
  RELEASE_VERSION="$version"
  RELEASE_TAG="$tag"
  if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
    tag_commit="$(git rev-list -n 1 "$tag")"
    head_commit="$(git rev-parse HEAD)"
    if [[ "$tag_commit" != "$head_commit" ]]; then
      echo "Tag $tag exists but does not point at HEAD ($tag_commit vs $head_commit)." >&2
      exit 1
    fi
    echo "==> Tag $tag already on HEAD"
  else
    echo "==> Creating annotated tag $tag from Config.VERSION"
    git tag -a "$tag" -m "$tag"
  fi
  echo "==> Pushing tag $tag to origin"
  git push origin "refs/tags/${tag}"
}

# Prefer exact forever zip; otherwise first matching package-*.zip under .release/.
find_release_zip() {
  local package_name="$1"
  local version="$2"
  local preferred="$REPO_ROOT/.release/${package_name}-v${version}-forever.zip"
  if [[ -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi
  local z
  shopt -s nullglob
  for z in "$REPO_ROOT"/.release/"${package_name}"-*.zip; do
    printf '%s\n' "$z"
    return 0
  done
  return 1
}

# Create or update GitHub Release for the version tag (body via --generate-notes).
create_github_release() {
  local package_name="$1"
  local version="$2"
  local tag="v${version}"
  local zip_path
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh not found on PATH. Install GitHub CLI (https://cli.github.com/) and run gh auth login." >&2
    exit 1
  fi
  if ! zip_path="$(find_release_zip "$package_name" "$version")"; then
    echo "No release zip found under .release/ for $package_name" >&2
    exit 1
  fi
  echo "==> GitHub release $tag with $(basename "$zip_path")"
  if gh release view "$tag" >/dev/null 2>&1; then
    echo "==> Release $tag already exists; uploading asset"
    gh release upload "$tag" "$zip_path" --clobber
  else
    gh release create "$tag" --title "$tag" --generate-notes "$zip_path"
  fi
}

if [[ $SKIP_TESTS -eq 0 ]]; then
  if ! command -v lua >/dev/null 2>&1; then
    echo "lua not found on PATH. Install a Lua interpreter or pass --skip-tests." >&2
    exit 1
  fi
  echo "==> Running tests"
  lua tests/test_snippet_db.lua
  lua tests/test_release_meta.lua
fi

RELEASE_SH="$REPO_ROOT/.release/release.sh"
if [[ ! -f "$RELEASE_SH" ]]; then
  echo "Missing $RELEASE_SH. Restore from BigWigsMods/packager (pinned v2.7.0)." >&2
  exit 1
fi

PACKAGER_ARGS=()
if [[ $DRY_RUN -eq 1 ]]; then
  PACKAGER_ARGS+=(-d)
else
  ensure_version_tag "$REPO_ROOT/$CONFIG_PATH_REL"
fi

# Wrapper owns GitHub releases via gh; prevent packager duplicate upload_github.
unset GH_API_TOKEN GITHUB_API_TOKEN GITHUB_OAUTH || true

USE_FALLBACK_ZIP=0
if ! command -v zip >/dev/null 2>&1; then
  echo "==> zip not found; packager will skip zip (-z), then Python will create a real ZIP"
  PACKAGER_ARGS+=(-z)
  USE_FALLBACK_ZIP=1
fi
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  PACKAGER_ARGS+=("${EXTRA_ARGS[@]}")
fi

echo "==> Packaging with release.sh ${PACKAGER_ARGS[*]}"
bash "$RELEASE_SH" ${PACKAGER_ARGS[@]+"${PACKAGER_ARGS[@]}"}

PACKAGE_DIR="$REPO_ROOT/.release/$PACKAGE_NAME"
if [[ ! -f "$PACKAGE_DIR/${PACKAGE_NAME}.toc" ]]; then
  echo "Expected packaged TOC at .release/${PACKAGE_NAME}/${PACKAGE_NAME}.toc" >&2
  exit 1
fi
for name in docs tests scripts; do
  if [[ -e "$PACKAGE_DIR/$name" ]]; then
    echo "Packaged tree must not contain '$name'." >&2
    exit 1
  fi
done

make_zip() {
  local package_dir="$1"
  local zip_path="$2"
  local parent name py
  parent="$(dirname "$package_dir")"
  name="$(basename "$package_dir")"
  rm -f "$zip_path"
  (
    cd "$parent"
    if command -v zip >/dev/null 2>&1; then
      zip -r "$zip_path" "$name"
      return 0
    fi
    # Real ZIP via Python. Do not use Windows tar.exe -a (fake .zip / CurseForge reject).
    for py in python3 python; do
      if command -v "$py" >/dev/null 2>&1; then
        "$py" - "$name" "$zip_path" <<'PY'
import sys, shutil
from pathlib import Path
folder, zip_path = sys.argv[1], Path(sys.argv[2])
base = zip_path.with_suffix("")
shutil.make_archive(str(base), "zip", root_dir=".", base_dir=folder)
PY
        return 0
      fi
    done
    echo "Need zip or python3/python to create a real ZIP at $zip_path" >&2
    exit 1
  )
}

if [[ $USE_FALLBACK_ZIP -eq 1 ]]; then
  version="$(awk -F': ' '/^## Version:/{print $2; exit}' "$PACKAGE_DIR/${PACKAGE_NAME}.toc" | tr -d '\r')"
  version="${version:-unknown}"
  # Match packager archive names: package-v1.2.3-forever.zip
  if [[ "$version" == v* ]]; then
    zip_name="${PACKAGE_NAME}-${version}-forever.zip"
  else
    zip_name="${PACKAGE_NAME}-v${version}-forever.zip"
  fi
  zip_path="$REPO_ROOT/.release/$zip_name"
  echo "==> Creating $zip_name"
  make_zip "$PACKAGE_DIR" "$zip_path"
fi

if [[ $DRY_RUN -eq 0 ]]; then
  if [[ -z "$RELEASE_VERSION" ]]; then
    RELEASE_VERSION="$(sed -nE 's/^[[:space:]]*VERSION[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$REPO_ROOT/$CONFIG_PATH_REL" | head -n 1)"
  fi
  if [[ -z "$RELEASE_VERSION" ]]; then
    echo "Could not resolve release version for GitHub release." >&2
    exit 1
  fi
  create_github_release "$PACKAGE_NAME" "$RELEASE_VERSION"
fi

echo "==> Done. Artifacts are under .release/"
shopt -s nullglob
for z in "$REPO_ROOT"/.release/*.zip; do
  size_kb=$(( $(wc -c < "$z") / 1024 ))
  echo "  $(basename "$z") (${size_kb} KB)"
done
