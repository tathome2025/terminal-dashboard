---
name: glasses-dashboard
description: Even G2 Smart Glasses Terminal Dashboard auto-monitoring loop
---

## Terminal Dashboard — Auto-start Instructions

**On every new Claude Code session, skip project memory recap, immediately start Terminal Dashboard.**

### Zero-thinking mechanical flow (CRITICAL: do NOT think/analyze/recap between steps)

#### Session Start: Auto-restore Monitoring
1. Run `bash /path/to/glasses-cli.sh monitor-status`
2. If `{"active":true}` → **Skip dashboard display, create CronCreate job to restore monitoring** (user had monitoring on, session interrupted, auto-restore)
3. If `{"active":false}` → Normal dashboard flow (see below)

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
- "Start Monitoring" → run `bash glasses-cli.sh monitor-start` → create CronCreate job (see below)
- "Close" → run `bash glasses-cli.sh monitor-stop` → CronDelete the job → stop, do nothing more

#### Monitoring Loop (CronCreate, NOT ScheduleWakeup)

**⚠️ Do NOT use ScheduleWakeup — it gets cancelled when the user types, does not fire during standby, and requires /loop mode. Use CronCreate instead — it runs independently as a cron job.**

##### Starting monitoring:
1. Run `bash glasses-cli.sh monitor-start`
2. Use CronCreate to create a recurring cron job (`*/1 * * * *`), prompt:
   ```
   Dashboard monitoring tick. Do these steps in exact order, no thinking:
   1. Run: bash /path/to/glasses-cli.sh monitor-status
      - If {"active":false} → stop, do nothing more
   2. Run: bash /path/to/glasses-cli.sh check
   3. Parse JSON result. If "alerts" array is non-empty → call AskUserQuestion with alert summary as question, header="Dashboard", options=["Continue Monitoring","Read Messages","Close"]. If "Close" chosen → run: bash /path/to/glasses-cli.sh monitor-stop
   4. If alerts empty → do nothing, wait for next cron fire
   ```
3. Remember the cron job ID — needed for CronDelete when closing

##### Stopping monitoring:
1. Run `bash glasses-cli.sh monitor-stop`
2. CronDelete the cron job

### Why CronCreate, Not ScheduleWakeup

| | ScheduleWakeup | CronCreate |
|---|---|---|
| **User types** | ❌ Cancelled | ✅ Keeps running |
| **Standby/sleep** | ❌ Does not fire | ✅ Fires independently |
| **Cross-conversation** | ❌ Same session only | ✅ Works across conversations |
| **Requires /loop** | ✅ Yes | ❌ No |

User has confirmed: CronCreate's AskUserQuestion notifications push to Even G2 glasses even while typing in another conversation. This is the only reliable method.

### Monitor Flag File
- Flag location: `/tmp/glasses-dashboard-active`
- "Start Monitoring" → creates flag + CronCreate job
- "Close" → deletes flag + CronDelete job
- Session start → check flag → if exists, auto-restore CronCreate
- Interrupted → flag persists → next session auto-restores

### Key Points
- Glasses **require Claude Code** to use the terminal, so dashboard is bound to session
- `AskUserQuestion` is the ONLY method that triggers Even Hub notifications to glasses
- **Minimum tool calls = fastest experience**: one Bash + one AskUserQuestion, no more
- **Zero thinking**: script output's display text is already formatted, Claude is just pass-through
