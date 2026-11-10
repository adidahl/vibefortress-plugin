---
name: start
description: First-run guide for Vibe Fortress. Use when the user runs /vibefortress:start, says "now try it", "get started with Vibe Fortress", "what can Vibe Fortress do" or has just installed the plugin.
---

# Vibe Fortress: get started

Say, in plain language and in under six lines:
1. Vibe Fortress checks your project for leaked secrets, vulnerable packages and common mistakes, on this computer. Your code never leaves it, and no account is needed.
2. Ask which project to check: this folder, another folder, or a GitHub repository (you would download a copy into `~/vibefort-work` after their yes).
3. On their answer follow the `vibefortress` skill: run `local_scan`, present at most five findings, offer a deeper review, then offer to fix on a new branch (a pull request only after a second yes).
4. Mention once that later, an optional free account (30-day trial, no card) adds deeper reviews, live and cloud checks and a dashboard, and that you can link it without copying any token.

Do not scan before the user answers the question in step 2 unless they already named a project.
