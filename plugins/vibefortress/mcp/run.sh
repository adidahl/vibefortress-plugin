#!/bin/sh
# Vibefortress local service launcher (054 D-506). Finds Node and npx with launcher/node.sh, then starts the pinned package.
# stdout is the protocol channel: nothing else may print there. No shell profiles, runtime installation or project .nvmrc.
fail() { printf '%s\n' "Vibefortress local tools unavailable: $1" >&2; exit 1; }
[ "$#" -eq 0 ] || fail 'This launcher accepts no arguments.'
case "$0" in */*) vf_dir=${0%/*} ;; *) vf_dir=. ;; esac
[ -r "$vf_dir/../launcher/node.sh" ] || fail 'The plugin is incomplete. Reinstall Vibefortress.'
. "$vf_dir/../launcher/node.sh" >/dev/null 2>&1 || fail 'The plugin is incomplete. Reinstall Vibefortress.'
vf_find_node npx >/dev/null 2>&1 || fail 'Vibefortress needs Node 20 or newer with npm. Install it from nodejs.org, Homebrew or nvm, then restart the app.'
exec npx -y 'vibefortress@0.1.74' mcp
