---
name: nudges
description: Dismiss or switch off Vibe Fortress reminders. Use ONLY when the user says things like "not now", "dismiss that", "stop reminding me", "turn off the security reminders" or asks to turn them back on or see what is quiet.
---

# Vibe Fortress reminders

Call the `local_nudges` tool with `path` set to the project folder.

- "not now" / "dismiss" after a reminder: action `dismiss` with the type of the reminder you were told about (`first_run_offer` for the quick-check offer, `post_commit_finding` for a notice after a commit, `task_finished_reminder` for the end-of-task line, `live_secret_warning` for the secret warning). Two dismissals of one type keep that type quiet for 7 days.
- "remind me later" (the offer card button): action `snooze` with type `first_run_offer`. Quiet for 3 days; only the date is stored.
- "stop reminding me" / "turn off": action `off`. "turn them back on": action `on`. "what is quiet": action `status`.

Never call it on your own initiative. Confirm in one short sentence what you did.
