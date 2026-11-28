#!/bin/sh
# Vibefortress hook launcher (054 D-504, D-506). Finds Node with launcher/node.sh, then runs the readable hooks/run.mjs beside it.
# Never blocks: always exits 0. No shell profiles, project version files, runtime installs or downloads.
case "$#:${1:-}" in
  1:session-start|1:post-bash|1:pre-bash|1:stop) vf_event=$1 ;;
  *) exit 0 ;;
esac
case "$0" in */*) vf_dir=${0%/*} ;; *) vf_dir=. ;; esac
vf_missing() {
  [ "$vf_event" = session-start ] && printf '%s' '{"systemMessage":"Vibefortress needs Node 20 or newer to scan. Install it from nodejs.org, then restart the app."}'
  exit 0
}
[ -r "$vf_dir/../launcher/node.sh" ] || vf_missing
. "$vf_dir/../launcher/node.sh" >/dev/null 2>&1 || vf_missing
vf_find_node node >/dev/null 2>&1 || vf_missing
exec node "$vf_dir/run.mjs" "$vf_event"
