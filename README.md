# Terminal Dashboard for Even G2 Smart Glasses

**[繁體中文版 README](README.zh.md)**

## A Love Story Between a Code Farmer and His Terminal

> **码农** (mǎ nóng) — *n.* Chinese developer slang, literally "code farmer." One who toils in the fields of source code from dawn till dusk, mass-`git commit`-ing through the seasons. See also: you.

Once upon a time, there was a code farmer. He called himself "senior" — not because of decades of experience, not because of any impressive title on LinkedIn, but because one day, for the first time in his life, he spoke to his Terminal and the Terminal *listened*.

No typing. Just talking. And code appeared.

He sat there, hands resting on the desk — not hovering over a keyboard, not reaching for a mouse — just... resting. He felt the weight of all those years of `Ctrl+C`, `Ctrl+V`, all those mass-RSI scares, all those mass-calluses on his pinky from holding `Shift`. Gone. The AI typed for him now. He just had to speak.

*"So this is what senior feels like,"* he thought.

But here's the thing — he was late. Painfully, embarrassingly late. Other developers had been doing this for months. Twitter was full of people showing off their voice-coded apps, their AI-pair-programmed startups, their mass-zero-keyboard workflows. And here he was, a mass-veteran code farmer, just now feeling the dirt fall from his mass-calloused hands for the first time. Just now looking up from the screen. Just now beginning.

He was the last one to arrive at the future. But he arrived.

And when he did, a pair of Even Realities G2 smart glasses sat on his nose, a tiny green HUD glowing in the corner of his right eye. His hands were free. His eyes could look up from the screen. The future had been waiting for him, patient as a blinking cursor.

But there was a problem.

See, this code farmer had a deep, committed, long-term relationship. Not with a person — with his **Terminal.** They'd been through everything together. Midnight deploys. Production fires. That mass-`rm -rf` incident they swore never to speak of again. The Terminal had never let him down. (Well, except that one time. But they'd worked through it.)

He couldn't leave. He *wouldn't* leave.

But the world outside the Terminal kept demanding attention. WhatsApp messages buzzing. Calendar invites multiplying. Emails piling up like unreviewed PRs. Every time he `⌘+Tab`'d away to check his phone, it felt like mass-betrayal. The Terminal cursor blinked at him, wounded. Waiting.

> *"Am I not enough for you?"*

The code farmer stared at the blinking cursor. He stared at the green glow in the corner of his eye. And then — in a quiet moment of clarity that only comes to latecomers who have nothing left to prove — he made a decision.

A bold, possibly unhinged decision:

**What if the Terminal could show him *everything*? Right there. On his glasses. Without ever leaving.**

Sure, the Even G2 has apps. It has an SDK. But using those means leaving Terminal. Switching windows. `⌘+Tab`. Betrayal.

So he chose another way. No app. No SDK. Just bash, python, and an AI that doesn't ask too many questions.

```
glasses-cli.sh → Claude Code → AskUserQuestion → Phone → Even Hub → Glasses
                    ↑
        "just pass it through,
         don't think about it"
```

He wrote the script. He taught the AI not to think. He put on his glasses.

And there it was — his unread messages, his tasks, his calendar, today's news — all floating gently in the corner of his right eye, in 4-bit grayscale green. His hands rested at his sides, free. His Terminal cursor blinked on, content. Undisturbed.

The code farmer smiled. It was the kind of smile you smile when you arrive late to a party and realize — the music is still playing. The dance floor is not empty. You haven't missed it. You're just in time.

He was late. He was just beginning. And that was perfectly fine.

Because now, he could have it all — the Terminal, the messages, the outside world — without ever leaving the warm glow of his command line. Without ever lifting his hands again.

And so, the late-arriving, just-beginning, finally-senior code farmer and his Terminal lived happily ever after.

Together. In `$HOME`. Forever.

`$ _`

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

The Even G2 has its own apps and SDK — but using them means leaving Terminal. For a code farmer, that's like being asked to leave home. This project takes a different path: it stays inside Terminal and exploits one simple fact — the glasses display phone notifications.

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
- **Python 3** and **curl** (you're a senior code farmer, you have these)

### 5 Minutes To Happiness

```bash
# 1. Clone
git clone https://github.com/TATLivingDEV/terminal-dashboard.git
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

**Q: Even G2 has its own apps and SDK. Why not just build a proper app?**
A: Because that means leaving Terminal. This project exists precisely so you *don't* have to leave. The apps are great — but they live outside the command line. We live inside it.

**Q: Isn't using an AI coding assistant as a notification pipe... overkill?**
A: Yes. But also: you never leave Terminal, no new SDK to learn, no context switching. Just bash. The code farmer in our story has fields to tend. He values his time.

**Q: What happens when Claude Code disconnects?**
A: The dashboard stops. Like a heartbeat. Reconnect, it restarts. Session-bound by design — it lives and dies with your coding session.

**Q: Can I run this without glasses?**
A: Yes! The `AskUserQuestion` prompt shows up in Claude Code itself. Glasses just add the "never leave Terminal" magic.

**Q: What about battery life?**
A: Even G2 lasts ~2 days. The dashboard is just text notifications — minimal power draw.

## Contributing

The senior code farmer welcomes contributions. Some ideas to make the Terminal relationship even stronger:

- [ ] Weather widget (so you know if you need to go outside... but why would you)
- [ ] System monitoring (CPU/RAM/disk on your glasses)
- [ ] Calendar countdown ("meeting in 12 min" → "meeting in 5 min" → "you're late")
- [ ] Pomodoro timer
- [ ] Custom widget plugin system
- [ ] Support for other AI coding assistants

## License

MIT — because the Terminal believes in freedom.

---

*Dedicated to every 码农 who arrived late, who is just beginning, and who mass-dismissed 47 notifications just to get back to their Terminal faster.*

*It's not too late. You're right on time.*

*You are not alone. You are `$HOME`.*

*`$ _`*
