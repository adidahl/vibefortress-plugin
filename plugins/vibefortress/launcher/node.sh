# Vibefortress Node finder (054 D-506). Sourced by hooks/run.sh and mcp/run.sh, never run on its own.
# Finds a Node 20 or newer that is already installed and puts its folder first on PATH, so npm and npx come from the same install.
# Order: the PATH this app gave us, the nvm default, then fixed install folders (Volta, fnm, asdf, mise, Homebrew on Apple silicon
# and Intel, the nodejs.org installer, MacPorts). Desktop apps on macOS start us with the bare system PATH, which has none of these.
# Reads no shell profile and no project version file, installs nothing, downloads nothing, prints nothing.

case ":${PATH:-}:" in *:/usr/bin:*) ;; *) PATH=${PATH:+$PATH:}/usr/bin:/bin; export PATH ;; esac

# Is the node at $1 version 20 or newer?
vf_new_enough() {
  "$1" --version 2>/dev/null | grep -Eq '^v(2[0-9]|[3-9][0-9]|[1-9][0-9][0-9]+)\.'
}

# Takes folder $1 when it holds a new enough node (and npx beside it when the caller needs npx).
vf_use_dir() {
  [ -n "$1" ] && [ -x "$1/node" ] || return 1
  [ "$vf_need" != npx ] || [ -x "$1/npx" ] || return 1
  vf_new_enough "$1/node" || return 1
  PATH=$1:$PATH
  export PATH
}

# Loads only the nvm installed in folder $1 and its default version.
vf_use_nvm() {
  case "$1" in /*) ;; *) return 1 ;; esac
  [ -r "$1/nvm.sh" ] || return 1
  NVM_DIR=$1
  export NVM_DIR
  . "$NVM_DIR/nvm.sh" --no-use >/dev/null 2>&1 || return 1
  nvm use --silent default >/dev/null 2>&1 || return 1
  command -v node >/dev/null 2>&1 && vf_new_enough node || return 1
  [ "$vf_need" != npx ] || command -v npx >/dev/null 2>&1
}

# vf_find_node node|npx: returns 0 with PATH set, or 1 when no usable Node is installed.
vf_find_node() {
  vf_need=${1:-node}
  if command -v node >/dev/null 2>&1 && vf_new_enough node; then
    if [ "$vf_need" != npx ] || command -v npx >/dev/null 2>&1; then return 0; fi
  fi
  vf_home=${HOME:-/nonexistent}
  for vf_nvm in "${NVM_DIR:-}" "${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/nvm}" "$vf_home/.nvm"; do
    [ -n "$vf_nvm" ] && vf_use_nvm "$vf_nvm" && return 0
  done
  for vf_d in \
    "${VOLTA_HOME:-$vf_home/.volta}/bin" \
    "$vf_home/.local/share/fnm/aliases/default/bin" \
    "$vf_home/Library/Application Support/fnm/aliases/default/bin" \
    "${ASDF_DATA_DIR:-$vf_home/.asdf}/shims" \
    "$vf_home/.local/share/mise/shims" \
    /opt/homebrew/bin \
    /opt/homebrew/opt/node@26/bin /opt/homebrew/opt/node@24/bin /opt/homebrew/opt/node@22/bin /opt/homebrew/opt/node@20/bin \
    /usr/local/bin \
    /usr/local/opt/node@26/bin /usr/local/opt/node@24/bin /usr/local/opt/node@22/bin /usr/local/opt/node@20/bin \
    /opt/local/bin; do
    vf_use_dir "$vf_d" && return 0
  done
  return 1
}
