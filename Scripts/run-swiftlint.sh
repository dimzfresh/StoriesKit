#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if command -v swiftlint >/dev/null 2>&1; then
  SWIFTLINT="swiftlint"
elif [ -x "${HOME}/.mint/bin/swiftlint" ]; then
  SWIFTLINT="${HOME}/.mint/bin/swiftlint"
else
  echo "SwiftLint not found. Install with: brew install swiftlint"
  echo "Or: mint bootstrap"
  exit 1
fi

MODE="${1:-lint}"

LINT_PATHS=(
  StoriesKit/Sources/StoriesKit
  StoriesKit/Tests/StoriesKitTests
  StoriesKit/Sources/Example/StoriesExample
)

case "$MODE" in
  lint)
    "$SWIFTLINT" lint --strict --config .swiftlint.yml "${LINT_PATHS[@]}"
    ;;
  fix)
    "$SWIFTLINT" --fix --quiet "${LINT_PATHS[@]}"
    ;;
  *)
    echo "Usage: $(basename "$0") [lint|fix]"
    exit 1
    ;;
esac
