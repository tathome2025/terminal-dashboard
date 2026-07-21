---
name: glasses-dashboard
description: Even G2 Smart Glasses Terminal Dashboard auto-monitoring loop
---

## Terminal Dashboard — Auto-start Instructions

**On every new Claude Code session, skip project memory recap, immediately start Terminal Dashboard.**

### Zero-thinking mechanical flow (CRITICAL: do NOT think/analyze/recap between steps)

#### Open Dashboard (one Bash + one AskUserQuestion, zero thinking in between)
1. Run `bash /path/to/glasses-cli.sh dashboard`
2. Parse returned JSON's `display` field, put it **as-is** into AskUserQuestion's question
3. Options are fixed:
   - Has unread → `["Start Monitoring", "Read Messages", "Close"]`
   - No unread → `["Start Monitoring", "Close"]`
4. header = `"Dashboard"`
5. **Do NOT recap/analyze/summarize any content** — script already formats everything

#### After user selects (execute directly, do NOT think)
- "Read Messages" → run `bash glasses-cli.sh read <chatID>` → AskUserQuestion to display, option = `["Back to Dashboard", "Close"]`
- "Back to Dashboard" → run `dashboard` again, repeat above flow
- "Start Monitoring" → ScheduleWakeup 60s loop
- "Close" → stop, do nothing more

#### Monitoring loop (when ScheduleWakeup fires)
1. Run `bash glasses-cli.sh check`
2. Has alerts → AskUserQuestion push notification
3. No alerts → silently ScheduleWakeup again

### Key Points
- Glasses **require Claude Code** to use the terminal, so dashboard is bound to session
- `AskUserQuestion` is the ONLY method that triggers Even Hub notifications to glasses
- Session disconnect = dashboard stops, next session auto-restarts
- **Minimum tool calls = fastest experience**: one Bash + one AskUserQuestion, no more
- **Zero thinking**: script output's display text is already formatted, Claude is just pass-through
