// Runs one Vibefortress hook from the npm package "vibefortress" at one exact version.
// usage: node run.mjs <session-start|post-bash|pre-bash|stop>
// It never waits for a download and never fails (always exits 0). When the package is not on this machine yet, it starts
// the download in the background and ends at once; later hooks use the downloaded copy.
// The only things it runs: the hook program of that package, and `npm install` of that exact version (with --ignore-scripts).
import { spawn, spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, rmSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const VERSION = "0.1.74";
const SPEC = "vibefortress@0.1.74";
const NODE_MISSING = '{"systemMessage":"Vibefortress needs Node 20 or newer to scan. Install it from nodejs.org, then restart the app."}';

const event = process.argv[2] ?? "";
const data = process.env.CLAUDE_PLUGIN_DATA || join(homedir(), ".vibefortress");
const pkg = join(data, "pkg", VERSION);
const hook = join(pkg, "node_modules", "vibefortress", "dist", "hook.js");
const lock = `${pkg}.installing`;
const win = process.platform === "win32";

const drop = (p) => { try { rmSync(p, { recursive: true, force: true }); } catch { /* nothing to remove */ } };

// Second life of this file: the background fetch. Started by startFetch() below, detached, with no terminal attached.
function install() {
  const r = spawnSync(win ? "npm.cmd" : "npm", ["install", "--prefix", pkg, "--ignore-scripts", "--no-audit", "--no-fund", "--no-package-lock", "--silent", SPEC], { stdio: "ignore", shell: win, windowsHide: true });
  if (r.status === 0 && existsSync(hook)) {
    // keep only this version
    for (const d of readdirSync(join(data, "pkg"), { withFileTypes: true })) {
      const p = join(data, "pkg", d.name);
      if (d.isDirectory() && p !== pkg && p !== lock) drop(p);
    }
  } else drop(pkg);
  drop(lock);
}

// A lock folder keeps two hooks from fetching at the same time; a lock older than 10 minutes is taken to be left over from a fetch that died.
function startFetch() {
  try {
    mkdirSync(join(data, "pkg"), { recursive: true });
    try { if (Date.now() - statSync(lock).mtimeMs > 10 * 60 * 1000) drop(lock); } catch { /* no lock */ }
    mkdirSync(lock);
  } catch { return; }
  try {
    spawn(process.execPath, [fileURLToPath(import.meta.url), "--install"], { detached: true, stdio: "ignore", windowsHide: true }).unref();
  } catch { drop(lock); }
}

if (event === "--install") {
  install();
} else if (parseInt(process.versions.node, 10) < 20) {
  if (event === "session-start") process.stdout.write(NODE_MISSING);
} else if (existsSync(hook)) {
  spawnSync(process.execPath, [hook, event], { stdio: "inherit", env: { ...process.env, VIBEFORTRESS_HOME: data } });
} else {
  startFetch();
}
process.exit(0);
