#!/usr/bin/env bash
# Run unit tests, then package Snippets with BigWigs .release/release.sh (optional upload).
#
# Usage:
#   ./scripts/release.sh --dry-run
#   ./scripts/release.sh --skip-tests --dry-run
#   ./scripts/release.sh -- [extra release.sh args...]
set -euo pipefail

DRY_RUN=0
SKIP_TESTS=0
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dry-run) DRY_RUN=1; shift ;;
    --skip-tests) SKIP_TESTS=1; shift ;;
    --) shift; EXTRA_ARGS+=("$@"); break ;;
    -h|--help)
      sed -n '2,8p' "$0"
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

if [[ $SKIP_TESTS -eq 0 ]]; then
  if ! command -v lua >/dev/null 2>&1; then
    echo "lua not found on PATH. Install a Lua interpreter or pass --skip-tests." >&2
    exit 1
  fi
  echo "==> Running tests"
  lua tests/test_snippet_db.lua
fi

RELEASE_SH="$REPO_ROOT/.release/release.sh"
if [[ ! -f "$RELEASE_SH" ]]; then
  echo "Missing $RELEASE_SH. Restore from BigWigsMods/packager (pinned v2.7.0)." >&2
  exit 1
fi

PACKAGER_ARGS=()
if [[ $DRY_RUN -eq 1 ]]; then
  PACKAGER_ARGS+=(-d)
fi

USE_TAR_ZIP=0
if ! command -v zip >/dev/null 2>&1; then
  echo "==> zip not found; packager will skip zip (-z), then archive fallback will create it"
  PACKAGER_ARGS+=(-z)
  USE_TAR_ZIP=1
fi
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  PACKAGER_ARGS+=("${EXTRA_ARGS[@]}")
fi

echo "==> Packaging with release.sh ${PACKAGER_ARGS[*]}"
bash "$RELEASE_SH" ${PACKAGER_ARGS[@]+"${PACKAGER_ARGS[@]}"}

PACKAGE_DIR="$REPO_ROOT/.release/snippets"
if [[ ! -f "$PACKAGE_DIR/snippets.toc" ]]; then
  echo "Expected packaged TOC at .release/snippets/snippets.toc" >&2
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
  local parent name
  parent="$(dirname "$package_dir")"
  name="$(basename "$package_dir")"
  rm -f "$zip_path"
  (
    cd "$parent"
    if command -v zip >/dev/null 2>&1; then
      zip -r "$zip_path" "$name"
      return 0
    fi
    # Windows tar.exe supports auto format from the .zip extension via -a.
    if command -v tar.exe >/dev/null 2>&1; then
      tar.exe -a -cf "$zip_path" "$name"
      return 0
    fi
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$name" "$zip_path" <<'PY'
import sys, shutil
from pathlib import Path
folder, zip_path = sys.argv[1], Path(sys.argv[2])
base = zip_path.with_suffix("")
shutil.make_archive(str(base), "zip", root_dir=".", base_dir=folder)
PY
      return 0
    fi
    echo "Need zip, tar.exe, or python3 to create $zip_path" >&2
    exit 1
  )
}

if [[ $USE_TAR_ZIP -eq 1 ]]; then
  version="$(awk -F': ' '/^## Version:/{print $2; exit}' "$PACKAGE_DIR/snippets.toc" | tr -d '\r')"
  version="${version:-unknown}"
  zip_name="snippets-${version}-forever.zip"
  zip_path="$REPO_ROOT/.release/$zip_name"
  echo "==> Creating $zip_name"
  make_zip "$PACKAGE_DIR" "$zip_path"
fi

echo "==> Done. Artifacts are under .release/"
shopt -s nullglob
for z in "$REPO_ROOT"/.release/*.zip; do
  size_kb=$(( $(wc -c < "$z") / 1024 ))
  echo "  $(basename "$z") (${size_kb} KB)"
done
