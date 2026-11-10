# Vibe Fortress for Claude Code

Security that keeps up with vibe coding. Vibe Fortress scans your project on your own computer for leaked secrets, vulnerable packages, common code mistakes and risky configuration. It explains each finding in plain language and fixes it on a new branch when you say so. It never blocks a commit or a push, and it needs no account.

## Install

The quick way, from a terminal. It finds the AI tools on your computer and sets Vibe Fortress up in each:

```
npx vibefortress
```

Or in Claude Code only:

```
/plugin marketplace add adidahl/vibefortress-plugin
/plugin install vibefortress@vibefortress
/reload-plugins
```

Then open a project and say **check my app**, or run `/vibefortress:start`.

## What this plugin contains, and what it downloads

This repository holds the plugin's instructions for Claude (three skills and one agent), its hooks and its settings. It holds no program code.

The scanner itself is the npm package [`vibefortress`](https://www.npmjs.com/package/vibefortress). The plugin starts it with `npx -y vibefortress@0.1.31 mcp`, always at this one exact version, and its hooks use a copy of the same version that is fetched once into the plugin's own data folder (`npm install --ignore-scripts`, no other packages). The package has no dependencies. Each release is signed, and the scanner checks its own files against that signature when it starts.

On first use the scanner downloads three open-source tools (gitleaks, OSV-Scanner, Opengrep) and checks each against a fixed SHA-256 value before running it.

Needs Node 20 or newer on your PATH.

## What the hooks do

- When a session starts: one short line that offers a quick check.
- After a `git commit` run by Claude: scans the files in that commit and says in one line if something serious was added.
- Before a `git push` run by Claude: warns when a live-looking secret is about to reach a public repository. It warns; it does not stop the push.
- When Claude finishes a task: at most a short reminder about open findings.

Every hook ends quietly when Node or the package is missing.

## What stays on your computer

Your code, always. Only if you sign in and turn sync on does a short summary per finding (no code, no secret values) go to your Vibe Fortress workspace.

## Licence

Proprietary, all rights reserved. See [LICENSE](LICENSE). Vibe Fortress is an independent product and is not made by Anthropic.
