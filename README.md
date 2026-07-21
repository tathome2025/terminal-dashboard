# Terminal Dashboard for Even G2 Smart Glasses

Turn your **Even Realities G2** smart glasses into a live personal dashboard — messages, tasks, calendar, email, and news — powered by **Claude Code** as the rendering engine.

## The Idea

Smart glasses like the Even G2 have a tiny monocular display (576x288, 4-bit grayscale green). There's no app store, no custom firmware flashing. But there *is* a notification system: anything that triggers a phone notification can appear on the glasses via the Even Hub app.

Claude Code's `AskUserQuestion` tool generates interactive prompts that trigger phone notifications through Even Hub. This project exploits that path:

```
glasses-cli.sh (data) → Claude Code (pass-through) → AskUserQuestion → Phone notification → Even Hub → Glasses display
```

The result: a live dashboard on your glasses that aggregates:
- **Unread messages** (WhatsApp + Telegram via Beeper)
- **Tasks & calendar** (from any API)
- **Email counts**
- **News headlines** (RSS)
- **SSH intrusion alerts** (optional)

All refreshed every 60 seconds in a monitoring loop.

## How It Works

### Architecture

```
┌─────────────────────────────────────────────┐
│                  Mac / PC                    │
│                                              │
│  glasses-cli.sh ──→ Claude Code session      │
│    (bash + python3)    │                     │
│    - Beeper API        │ AskUserQuestion     │
│    - Hub API           │ (tool call)         │
│    - RSS feed          ▼                     │
│              Phone notification              │
│                    │                         │
└────────────────────┼─────────────────────────┘
                     │ Even Hub app (BLE)
                     ▼
              ┌──────────────┐
              │   Even G2    │
              │  Smart Glass │
              │  (display)   │
              └──────────────┘
```

### Key Insight: Claude Code as a Glasses Rendering Engine

Claude Code is an AI coding assistant that runs in your terminal. It has a tool called `AskUserQuestion` that shows interactive prompts with options. On phones, these prompts trigger system notifications. If Even Hub is installed, those notifications are forwarded to the glasses display.

By making Claude Code's behavior **mechanical** (run script → pass output to AskUserQuestion → handle selection → repeat), it becomes a real-time display pipeline for the glasses. The AI doesn't need to "think" — it just shuttles pre-formatted text to the glasses.

### The Script: `glasses-cli.sh`

A single bash script that:

1. **`dashboard`** — Fetches all data sources in parallel, formats a complete dashboard display, outputs JSON with a pre-formatted `display` field ready for glasses
2. **`check`** — Diff-based monitoring: compares current state vs. last check, only outputs new alerts (for the 60-second loop)
3. **`read <chatID>`** — Reads messages from a specific chat conversation
4. **`beeper`** / **`hub`** / **`ssh`** — Individual source checks

### The Claude Code Memory Config

A memory file (`claude-memory-example.md`) tells Claude Code to:
1. Auto-start the dashboard on every new session
2. Follow a strict mechanical flow (no thinking, no analysis)
3. Pass script output directly to `AskUserQuestion`
4. Run a 60-second monitoring loop via `ScheduleWakeup`

## Setup

### Prerequisites

- **Even Realities G2** smart glasses (connected via Even Hub app on iPhone/Android)
- **Claude Code** installed and running ([claude.ai/code](https://claude.ai/code))
- **Beeper** with Bridge Manager API enabled ([beeper.com](https://beeper.com)) — for WhatsApp/Telegram messages
- **Python 3** and **curl** available in terminal
- A dashboard API endpoint (optional — you can use any API that returns JSON)

### Quick Start

1. **Clone this repo:**
   ```bash
   git clone https://github.com/AugmentOS-Community/terminal-dashboard.git
   cd terminal-dashboard
   ```

2. **Configure credentials:**
   ```bash
   cp .env.example .env
   # Edit .env with your Beeper token, API URLs, etc.
   ```

3. **Test the script:**
   ```bash
   bash glasses-cli.sh dashboard
   # Should output JSON with a "display" field
   ```

4. **Set up Claude Code memory:**
   - Copy `claude-memory-example.md` content into your Claude Code project memory
   - Adjust the script path to match your setup
   - Start a new Claude Code session — the dashboard should auto-launch

5. **Wear your glasses and enjoy!**

### Beeper Setup

This project uses [Beeper's Bridge Manager MCP Server](https://github.com/nicolo-ribaudo/beeper-mcp-server) to access WhatsApp and Telegram messages via a local API.

1. Install the Beeper MCP server
2. Get your Bridge API token from Beeper settings
3. Set `BEEPER_TOKEN` in your `.env`

The API runs locally at `http://127.0.0.1:23373/v0/mcp` by default.

### Custom Dashboard API

The `HUB_API_URL` should point to any endpoint that returns JSON in this format:

```json
{
  "todos": [
    {"id": "1", "t": "Buy groceries", "due": "2026-07-22"}
  ],
  "events": [
    {"title": "Team standup", "start": "2026-07-22T10:00:00Z"}
  ],
  "email": {
    "inbox": 5,
    "ads": 12,
    "system": 3
  },
  "jobs": [
    {"status": "pending", "title": "Deploy v2.1"}
  ]
}
```

You can build this with any backend — Next.js API route, Flask, Express, etc. The script just needs a URL and a Bearer token.

## Example Output

When running `glasses-cli.sh dashboard`, you get:

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
  Tech company reports record earnings
```

This text appears directly on your Even G2 glasses display.

## How the Monitoring Loop Works

```
Session start
     │
     ▼
  dashboard ──→ AskUserQuestion ──→ Glasses show full dashboard
     │
     │ User picks "Start Monitoring"
     ▼
  ScheduleWakeup(60s)
     │
     ▼ (60s later)
  check ──→ Any new alerts?
     │           │
     │ No        │ Yes
     │           ▼
     │     AskUserQuestion ──→ Glasses show alert
     │
     ▼
  ScheduleWakeup(60s) ──→ repeat...
```

The loop runs as long as the Claude Code session is alive. Disconnect = loop stops. Reconnect = auto-restarts (if configured in memory).

## Adapting for Your Use Case

### Different Message Sources

Replace the Beeper integration with any messaging API:
- **Slack**: Use Slack Web API to check unread channels
- **Discord**: Use Discord bot API
- **Email only**: Use IMAP to check inbox directly

### Different Data Sources

The Hub API is generic — point it at anything:
- **Todoist / Notion / Linear**: Build a small proxy API
- **GitHub**: Issues and PR notifications
- **Home Assistant**: Smart home sensor readings
- **Stock prices**: Financial data API

### Different RSS Feeds

Change `NEWS_RSS_URL` in `.env` to any RSS feed:
- `https://feeds.bbci.co.uk/news/rss.xml` (BBC)
- `https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml` (NYT)
- Any RSS/Atom feed URL

### Different Smart Glasses

The concept works with any glasses that receive phone notifications:
- **Even G2** (tested)
- **Even G1** (should work)
- **Meta Ray-Ban** (via Meta notification system)
- **Any AugmentOS-compatible glasses**

The key is: if it can display phone notifications, it can display this dashboard.

## Why Claude Code?

You might ask: why use an AI coding assistant as a display pipeline? Because:

1. **No app development needed** — No custom iOS/Android app, no BLE protocol implementation, no firmware flashing
2. **AskUserQuestion = notification bridge** — It's the only reliable way to push text to glasses without building a native app
3. **Terminal-native** — Runs in any terminal, works over SSH, works headless on a server
4. **Scriptable** — Standard bash + python, easy to extend
5. **Session-bound** — Start when you start working, stops when you stop. Natural lifecycle.

The tradeoff: you need an active Claude Code session. But if you're already using Claude Code for development (which many developers are), the dashboard comes "free" — it runs alongside your coding session.

## Contributing

Contributions welcome! Some ideas:

- [ ] Support for more messaging platforms (Slack, Discord, Matrix)
- [ ] Weather widget
- [ ] System monitoring (CPU, memory, disk)
- [ ] Calendar countdown (time until next event)
- [ ] Custom widget plugin system
- [ ] Support for other AI coding assistants (Cursor, Windsurf, etc.)

## License

MIT
