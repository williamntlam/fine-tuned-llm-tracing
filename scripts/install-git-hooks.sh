#!/usr/bin/env bash
# Activate this repository's version-controlled Git hooks for the current clone.

set -euo pipefail

repository_root="$(git rev-parse --show-toplevel)"
cd "$repository_root"
git config core.hooksPath .githooks

printf 'Installed repository Git hooks from .githooks for this clone.\n'
