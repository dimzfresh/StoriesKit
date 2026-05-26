#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGE_DIR="${ROOT}/StoriesKit"

cd "$PACKAGE_DIR"

DESTINATION="${1:-platform=iOS Simulator,name=iPhone 16,OS=latest}"

xcodebuild test \
  -scheme StoriesKit \
  -destination "$DESTINATION" \
  -quiet

echo "Tests passed."
