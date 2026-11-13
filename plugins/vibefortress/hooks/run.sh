#!/bin/sh
# Runs one Vibe Fortress hook from the npm package "vibefortress" at one exact version.
# It never waits for a download and never fails: when the package is not on this machine yet it starts
# the download in the background and ends at once; later hooks use the downloaded copy.
# usage: sh run.sh <session-start|post-bash|pre-bash|stop>
VERSION="0.1.52"
SPEC="vibefortress@0.1.52"

if ! command -v node >/dev/null 2>&1 || ! node -e 'process.exit(parseInt(process.versions.node, 10) >= 20 ? 0 : 1)' >/dev/null 2>&1; then
  [ "$1" = "session-start" ] && printf '%s' '{"systemMessage":"Vibe Fortress needs Node 20 or newer to scan. Install it from nodejs.org, then restart Claude Code."}'
  exit 0
fi

DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.vibefort}"
export VIBEFORT_HOME="$DATA"
PKG="$DATA/pkg/$VERSION"
HOOK="$PKG/node_modules/vibefortress/dist/hook.js"

if [ -f "$HOOK" ]; then
  exec node "$HOOK" "$1"
fi

# Not here yet: fetch it once, in the background. A lock folder keeps two hooks from fetching at the same time;
# a lock older than 10 minutes is taken to be left over from a fetch that died.
command -v npm >/dev/null 2>&1 || exit 0
mkdir -p "$DATA/pkg" 2>/dev/null || exit 0
LOCK="$PKG.installing"
if [ -d "$LOCK" ] && [ -n "$(find "$LOCK" -prune -mmin +10 2>/dev/null)" ]; then rmdir "$LOCK" 2>/dev/null; fi
if mkdir "$LOCK" 2>/dev/null; then
  (
    if npm install --prefix "$PKG" --ignore-scripts --no-audit --no-fund --no-package-lock --silent "$SPEC" && [ -f "$HOOK" ]; then
      # keep only this version
      for d in "$DATA"/pkg/*/; do [ "${d%/}" = "$PKG" ] || rm -rf "${d%/}"; done
    else
      rm -rf "$PKG"
    fi
    rmdir "$LOCK" 2>/dev/null
  ) </dev/null >/dev/null 2>&1 &
fi
exit 0
