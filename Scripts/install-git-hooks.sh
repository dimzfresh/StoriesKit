#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

chmod +x .githooks/pre-commit
chmod +x Scripts/run-swiftlint.sh
chmod +x Scripts/run-tests.sh

git config core.hooksPath .githooks

echo "Git hooks installed (core.hooksPath=.githooks)"
echo "Run ./Scripts/run-swiftlint.sh lint to lint the project."
