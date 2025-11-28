#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Install it with Homebrew:"
  echo "  brew install xcodegen"
  echo "or via Mint:"
  echo "  mint install yonaskolb/xcodegen"
  exit 1
fi

echo "Generating Xcode project from project.yml..."
xcodegen generate --spec project.yml
echo "Done. Open ExampleMVVM.xcodeproj"
