#!/usr/bin/env bash
# Compatibility wrapper. Prefer ./setup.sh
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup.sh" "$@"
