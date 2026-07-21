# Terminal Dashboard for Even G2 Smart Glasses

## A Love Story Between a Man and His Terminal

Once upon a time, there was a senior developer. Let's call him... well, let's just say he was *very* senior. The kind of senior where `git log --author` goes back further than some interns have been alive.

He had finally achieved the dream: **hands free.** A pair of Even Realities G2 smart glasses sat on his nose, a tiny green HUD glowing in the corner of his right eye. The future had arrived.

But there was a problem.

See, this developer had a deep, committed, long-term relationship. Not with a person — with his **Terminal.** They'd been through everything together. Midnight deploys. Production fires. That one time they accidentally `rm -rf`'d and had to pretend nothing happened.

He couldn't leave. He *wouldn't* leave.

But the world outside the Terminal kept demanding attention. WhatsApp messages. Calendar invites. Emails piling up like unreviewed PRs. Every time he `⌘+Tab`'d away to check his phone, it felt like betrayal. The Terminal cursor blinked at him, wounded.

> *"Am I not enough for you?"*

So he made a decision. A bold, possibly unhinged decision:

**What if the Terminal could show him *everything*? Right there. On his glasses. Without ever leaving.**

No app store. No custom firmware. No React Native. Just bash, python, and an AI that doesn't ask too many questions.

```
glasses-cli.sh → Claude Code → AskUserQuestion → Phone → Even Hub → Glasses
                    ↑
        "just pass it through,
         don't think about it"
```

And just like that, the developer and his Terminal lived happily ever after.

They never had to be apart again.

---

## What This Actually Is

A single bash script that turns **Claude Code** into a live display engine for **Even G2 smart glasses**. It aggregates:

- **Unread messages** — WhatsApp + Telegram via [Beeper](https://beeper.com)
- **Tasks & calendar** — from any JSON API
- **Email counts** — inbox at a glance
- **News headlines** — any RSS feed
- **SSH intrusion alerts** — because paranoia is a feature

All pushed to your glasses every 60 seconds. You never leave the Terminal. The Terminal never leaves you.

## The Trick

Smart glasses like the Even G2 have no app store. No SDK for custom apps (well, sort of). But they *do* display phone notifications.

Claude Code has a tool called `AskUserQuestion` — it pops up interactive prompts. Those prompts trigger phone notifications. If Even Hub is installed, those notifications fly to your glasses via Bluetooth.

So we simply:
1. Run a bash script that fetches all your data
2. Tell Claude Code: *"Here's the text. Show it. Don't think. Just show it."*
3. Claude obeys (for once)
4. Phone gets notification
5. Glasses display it

The AI coding assistant becomes a dumb display pipe. Which, honestly, might be its highest calling.

## Architecture

```
┌─────────────────────────────────────────────┐
│                  Your Mac                    │
│                                              │
│  glasses-cli.sh ──→ Claude Code session      │
│    (bash + python3)    │                     │
│    - Beeper API        │ AskUserQuestion     │
│    - Your API          │ (tool call)         │
│    - RSS feed          ▼                     │
│              Phone notification              │
│                    │                         │
└────────────────────┼─────────────────────────┘
                     │ Even Hub app (BLE)
                     ▼
              ┌──────────────┐
              │   Even G2    │
              │  Smart Glass │
              │  576×288 px  │
              │  4-bit green │
              └──────────────┘
```

## What You See On Your Glasses

```
Terminal Dashboard  2026-07-22 Wednesday 14:30

[ 3 unread messages ]
  07/22 14:25  Alice: Hey, are we still meeting at 3?
  07/22 14:20  Bob: Check the latest PR when you can
  07/22 13:55  Mom: [media]

[ 4 tasks ]
  Review Q3 roadmap (due 2026-07-22)
  Ship feature flags (due 2026-07-23)
  Update onboarding docs
  Fix login redirect bug (due 2026-07-25)

[ 2 events today ]
  15:00 Team standup
  17:30 1:1 with manager

[ Email: 8 inbox | Jobs: 1 active ]

[ News ]
  Breaking: Major policy change announced...
  Local transit expansion approved by council
```

All while your Terminal cursor keeps blinking. Content. Undisturbed.

## The Monitoring Loop

```
You open Terminal
     │
     ▼
  "Dashboard, please"
     │
     ▼
  glasses-cli.sh dashboard ──→ Glasses show everything
     │
     │ You tap "Start Monitoring"
     ▼
  Every 60 seconds:
     │
     ├─ New message? ──→ Glasses buzz: "Alice: where are you"
     ├─ New task?    ──→ Glasses buzz: "New: Fix prod bug"  
     ├─ Meeting soon?──→ Glasses buzz: "15:00 Team standup"
     └─ Nothing new? ──→ Silence. Peace. Code.
```

Session alive = monitoring runs. Session dies = monitoring stops. Reconnect = auto-restarts. It breathes with you.

## Setup

### You Need

- **Even Realities G2** (or G1) smart glasses + Even Hub app
- **Claude Code** ([claude.ai/code](https://claude.ai/code))
- **Beeper** with Bridge Manager API ([beeper.com](https://beeper.com))
- **Python 3** and **curl** (you're a senior developer, you have these)

### 5 Minutes To Happiness

```bash
# 1. Clone
git clone https://github.com/tathome2025/terminal-dashboard.git
cd terminal-dashboard

# 2. Configure
cp .env.example .env
# Edit .env — add your Beeper token, API URLs, etc.

# 3. Test
bash glasses-cli.sh dashboard
# You should see JSON with a "display" field

# 4. Tell Claude Code about it
# Copy claude-memory-example.md into your project memory
# Adjust the script path

# 5. Start a new Claude Code session
# Dashboard auto-launches. Put on your glasses.
# Never ⌘+Tab again.
```

### Beeper Setup

[Beeper's Bridge Manager MCP Server](https://github.com/nicolo-ribaudo/beeper-mcp-server) gives you a local API to read WhatsApp + Telegram messages.

1. Install the MCP server
2. Grab your Bridge API token
3. Put it in `.env` as `BEEPER_TOKEN`

It runs at `http://127.0.0.1:23373/v0/mcp`. Local. Fast. No cloud middleman.

### Your Own Dashboard API

Point `HUB_API_URL` at any endpoint returning this shape:

```json
{
  "todos": [{"id": "1", "t": "Task name", "due": "2026-07-22"}],
  "events": [{"title": "Meeting", "start": "2026-07-22T10:00:00Z"}],
  "email": {"inbox": 5, "ads": 12, "system": 3},
  "jobs": [{"status": "pending", "title": "Deploy v2.1"}]
}
```

Build it with whatever you want — Next.js, Flask, Express, a CGI script from 2003. The script doesn't judge.

## The Script: `glasses-cli.sh`

One file. Six commands. No dependencies beyond bash + python3 + curl.

| Command | What it does |
|---------|-------------|
| `dashboard` | Full dashboard, pre-formatted, ready for glasses |
| `check` | Diff-only — just new alerts since last check (for the 60s loop) |
| `read <chatID>` | Read messages from a specific conversation |
| `beeper` | Beeper-only diff check |
| `hub` | API-only diff check |
| `ssh` | SSH intrusion check |

The `dashboard` command outputs JSON with a `display` field — that's the pre-formatted text that goes straight to your glasses. Claude Code doesn't need to think about formatting. It just passes it through. Zero AI thinking time = faster updates.

## The Claude Code Memory Trick

The file `claude-memory-example.md` is key. It tells Claude Code:

1. **Auto-start** the dashboard on every new session
2. Follow a **strict mechanical flow** — no thinking, no analysis, no "let me summarize what I see"
3. **Pass script output directly** to `AskUserQuestion`
4. Run a **60-second monitoring loop** via `ScheduleWakeup`

This turns a thinking AI into a non-thinking display pipe. The less Claude thinks, the faster your glasses update. Ironic? Maybe. Effective? Absolutely.

## Make It Yours

### Different Message Sources

Swap Beeper for anything:
- **Slack** — Slack Web API for unread channels
- **Discord** — Bot API for server notifications
- **Matrix** — For the truly committed

### Different Data

The Hub API is generic. Point it at:
- **Todoist / Notion / Linear** — Build a tiny proxy
- **GitHub** — Issues, PRs, CI status
- **Home Assistant** — "Living room: 24°C"
- **Stock portfolio** — Watch numbers go up (or down)

### Different News

Change `NEWS_RSS_URL` in `.env`:
- `https://feeds.bbci.co.uk/news/rss.xml`
- `https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml`
- Your company's internal blog RSS
- Literally any RSS/Atom feed

### Different Glasses

If it receives phone notifications, it works:
- **Even G2** (tested, this is what started it all)
- **Even G1** (should work)
- **Meta Ray-Ban** (via Meta notifications)
- **Any AugmentOS-compatible device**

## FAQ

**Q: Isn't using an AI coding assistant as a notification pipe... overkill?**
A: Yes. But also: no custom app development, no BLE protocol, no firmware hacking. Just bash. The senior developer in our story values his time.

**Q: What happens when Claude Code disconnects?**
A: The dashboard stops. Like a heartbeat. Reconnect, it restarts. Session-bound by design — it lives and dies with your coding session.

**Q: Can I run this without glasses?**
A: Yes! The `AskUserQuestion` prompt shows up in Claude Code itself. Glasses just add the "never leave Terminal" magic.

**Q: What about battery life?**
A: Even G2 lasts ~2 days. The dashboard is just text notifications — minimal power draw.

## Contributing

The senior developer welcomes contributions. Some ideas to make the Terminal relationship even stronger:

- [ ] Weather widget (so you know if you need to go outside... but why would you)
- [ ] System monitoring (CPU/RAM/disk on your glasses)
- [ ] Calendar countdown ("meeting in 12 min" → "meeting in 5 min" → "you're late")
- [ ] Pomodoro timer
- [ ] Custom widget plugin system
- [ ] Support for other AI coding assistants

## License

MIT — because the Terminal believes in freedom.

---

*Dedicated to every developer who has ever mass-dismissed 47 notifications just to get back to their Terminal faster.*

*You are not alone. You are home.*

*`$ _`*
