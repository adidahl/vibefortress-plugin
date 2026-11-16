# Vibefortress for Claude Code

Security that keeps up with vibe coding. Vibefortress scans your project on your own computer for leaked secrets, vulnerable packages, common code mistakes and risky configuration. It explains each finding in plain language and fixes it on a new branch when you say so. It never blocks a commit or a push. The quick local check needs no account; the deep scan uses the Vibefortress service and asks you to sign in with GitHub the first time.

## Install

The quick way, from a terminal. It finds the AI tools on your computer and sets Vibefortress up in each:

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

## Codex desktop

Run `npx vibefortress --client codex`. Setup registers this repository's Codex marketplace and installs the full plugin, including its three skills, advisory hooks and both MCP servers. It prints the sign-in command after verifying installation. Review and trust hooks in Codex, then start a new chat. The standalone public OpenAI directory listing is a different, restricted package.

## What this plugin contains, and what it downloads

This repository holds the plugin's instructions for Claude (three skills and two agents: one fixes findings on a branch, one reviews the findings of a deep scan independently), its hooks and its settings. It holds one short program file, `hooks/run.mjs`, which starts the hooks; the scanner itself is not in this repository.

The plugin connects two servers: `vibefortress-local`, the scanner on your computer, and `vibefortress`, the hosted service at `https://www.vibefortress.com/mcp` that runs the deep scan. Your code stays on your computer: the local scanner sends the service file names, sizes, tool results with secrets masked, and package names and versions; Claude reads the code itself. You can turn either server off in `/mcp`.

The scanner itself is the npm package [`vibefortress`](https://www.npmjs.com/package/vibefortress). The plugin starts it with `npx -y vibefortress@0.1.69 mcp`, always at this one exact version, and its hooks use a copy of the same version that is fetched once into the plugin's own data folder (`npm install --ignore-scripts`, no other packages). The package has no dependencies. Each release is signed, and the scanner checks its own files against that signature when it starts.

On first use the scanner downloads three open-source tools (gitleaks, OSV-Scanner, Opengrep) and checks each against a fixed SHA-256 value before running it.

What leaves your computer, besides the hosted service above: the package names and exact versions of your project are looked up in the public OSV vulnerability database (osv.dev); the push warning asks GitHub whether the repository you push to is public (the owner and repository name only, through your own `gh` login or one anonymous request); the first-use downloads above and the one-time download of the pinned `vibefortress` package from npm. Nothing else is sent to any other service.

Needs Node 20 or newer on your PATH.

## What the hooks do

- When a session starts: one short line that offers a quick check.
- After a `git commit` run by Claude: scans the files in that commit and says in one line if something serious was added.
- Before a `git push` run by Claude: warns when a live-looking secret is about to reach a public repository. It warns; it does not stop the push.
- When Claude finishes a task: at most a short reminder about open findings.

Every hook ends quietly when Node or the package is missing.

## What stays on your computer

Your code, always. Only if you sign in and turn sync on does a short summary per finding (no code, no secret values) go to your Vibefortress workspace.

## Privacy

What the plugin and the hosted service handle, how long, and who to ask: [vibefortress.com/privacy](https://vibefortress.com/privacy).

## Licence

Proprietary, all rights reserved. See [LICENSE](LICENSE). Vibefortress is an independent product and is not made by Anthropic.
