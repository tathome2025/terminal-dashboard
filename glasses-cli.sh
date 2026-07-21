#!/usr/bin/env bash
# Terminal Dashboard for Even G2 Smart Glasses
# Aggregated dashboard pushed to glasses via Claude Code → AskUserQuestion → Even Hub
#
# Usage:
#   glasses-cli.sh dashboard    # Full dashboard (pre-formatted for glasses)
#   glasses-cli.sh check        # Diff-only monitoring (for loop)
#   glasses-cli.sh read <id>    # Read messages from a specific chat
#   glasses-cli.sh beeper       # Beeper diff check only
#   glasses-cli.sh hub          # Hub/API diff check only
#
# Configuration:
#   Set env vars directly, or create a .env file next to this script.
#   See .env.example for all available options.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="/tmp/glasses-cli"
mkdir -p "$STATE_DIR"

# Load .env if present (same directory as script)
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

# --- Config (override via env vars or .env file) ---
BEEPER_URL="${BEEPER_URL:-http://127.0.0.1:23373/v0/mcp}"
BEEPER_TOKEN="${BEEPER_TOKEN:-}"
HUB_API_URL="${HUB_API_URL:-}"
HUB_API_TOKEN="${HUB_API_TOKEN:-}"
NEWS_RSS_URL="${NEWS_RSS_URL:-https://rthk.hk/rthk/news/rss/c_expressnews_clocal.xml}"
SSH_KNOWN_IPS="${SSH_KNOWN_IPS:-}"

# ============================================================
# BEEPER - check for new messages via Beeper Bridge API
# ============================================================
check_beeper() {
  if [[ -z "$BEEPER_TOKEN" ]]; then
    echo '{"alerts":[],"total":0,"monitored":0,"error":"BEEPER_TOKEN not set"}'
    return
  fi

  local raw_file="$STATE_DIR/beeper-raw.json"
  local cur_file="$STATE_DIR/beeper-current.json"
  local state_file="$STATE_DIR/beeper-watch-state.json"

  curl -s --max-time 15 -X POST "$BEEPER_URL" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -H "Authorization: Bearer $BEEPER_TOKEN" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"search_chats","arguments":{"unreadOnly":true,"limit":50}}}' \
    2>/dev/null | grep "^data:" | head -1 | sed 's/^data: //' > "$raw_file"

  python3 - "$raw_file" "$state_file" "$cur_file" << 'PYEOF'
import sys, json, re
raw_f, state_f, cur_f = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(raw_f, 'rb') as f:
        data = json.loads(f.read())
    text = data['result']['content'][0]['text']
except:
    json.dump({"alerts": [], "total": 0, "monitored": 0}, open(cur_f, 'w'))
    sys.exit(0)

current = {}
for block in text.split('## ')[1:]:
    lines = block.strip().split('\n')
    m = re.search(r'\(chatID:\s*(\d+)\)', lines[0])
    if not m: continue
    cid = m.group(1)
    title = re.sub(r'\s*\(chatID:\s*\d+\)', '', lines[0]).strip()
    if len(title) > 35: title = title[:32] + '...'
    info = {'title': title, 'unread': 0, 'muted': False, 'platform': '', 'type': '', 'cid': cid}
    for ln in lines:
        um = re.search(r'(\d+) unread', ln)
        if um: info['unread'] = int(um.group(1))
        if 'muted' in ln.lower(): info['muted'] = True
        pm = re.search(r'Chat on (\w+)', ln)
        if pm: info['platform'] = pm.group(1)
        tm = re.search(r'\*\*Type\*\*:\s*(\w+)', ln)
        if tm: info['type'] = tm.group(1)
    current[cid] = info

try:
    with open(state_f) as f: prev = json.load(f)
except: prev = {}

alerts = []
for cid, c in current.items():
    if c.get('muted'): continue
    old = prev.get(cid, {}).get('unread', 0)
    if c['unread'] > old:
        d = c['unread'] - old
        p = c.get('platform', '')
        tag = 'WA' if p == 'WhatsApp' else 'TG' if p == 'Telegram' else p[:2]
        alerts.append({
            'source': 'beeper',
            'tag': tag,
            'title': c['title'],
            'diff': d,
            'total': c['unread'],
            'cid': cid,
            'priority': 1 if p == 'WhatsApp' else 2
        })

json.dump(current, open(state_f, 'w'))

nm = sum(1 for v in current.values() if not v['muted'])
result = {"alerts": alerts, "total": len(current), "monitored": nm}
json.dump(result, open(cur_f, 'w'))
print(json.dumps(result))
PYEOF
}

# ============================================================
# SSH - check for unknown inbound connections (optional)
# ============================================================
check_ssh() {
  python3 - "$SSH_KNOWN_IPS" << 'PYEOF'
import subprocess, json, re, sys

# Parse known IPs from env (comma-separated)
known_raw = sys.argv[1] if len(sys.argv) > 1 else ''
known_ips = {'127.0.0.1', '::1', '0.0.0.0'}
if known_raw:
    known_ips.update(ip.strip() for ip in known_raw.split(',') if ip.strip())

try:
    result = subprocess.run(['netstat', '-an'], capture_output=True, text=True, timeout=5)
    lines = result.stdout.split('\n')
    suspicious = []
    for line in lines:
        if 'ESTABLISHED' not in line: continue
        parts = line.split()
        if len(parts) < 5: continue
        local = parts[3]
        foreign = parts[4]
        # Only check INCOMING connections: local port is .22 or .443
        if not (local.endswith('.22') or local.endswith('.443')):
            continue
        ip = foreign.rsplit('.', 1)[0] if '.' in foreign else foreign
        if ip not in known_ips and not ip.startswith('192.168.') and not ip.startswith('100.'):
            suspicious.append({'ip': ip, 'line': line.strip()})

    result = {"alerts": [], "connections": len([l for l in lines if 'ESTABLISHED' in l and ('.22 ' in l or '.443 ' in l)])}
    if suspicious:
        for s in suspicious:
            result["alerts"].append({
                'source': 'ssh',
                'title': f"Unknown SSH: {s['ip']}",
                'priority': 0
            })
    print(json.dumps(result))
except Exception as e:
    print(json.dumps({"alerts": [], "error": str(e)}))
PYEOF
}

# ============================================================
# HUB API - check tasks, calendar, and email
# ============================================================
# Expected API response format:
# {
#   "todos": [{"id": "...", "t": "Task name", "due": "2026-01-01"}],
#   "events": [{"title": "Meeting", "start": "2026-01-01T10:00:00Z"}],
#   "email": {"inbox": 5, "ads": 10, "system": 3},
#   "jobs": [{"status": "pending", "title": "..."}]
# }
check_hub() {
  if [[ -z "$HUB_API_URL" || -z "$HUB_API_TOKEN" ]]; then
    echo '{"alerts":[],"error":"HUB_API_URL or HUB_API_TOKEN not set"}'
    return
  fi

  local prev_file="$STATE_DIR/hub-prev.json"

  curl -s --max-time 10 "$HUB_API_URL" \
    -H "Authorization: Bearer $HUB_API_TOKEN" \
    2>/dev/null > "$STATE_DIR/hub-current.json"

  python3 - "$STATE_DIR/hub-current.json" "$prev_file" << 'PYEOF'
import sys, json
from datetime import datetime, timezone, timedelta

cur_f, prev_f = sys.argv[1], sys.argv[2]
hkt = timedelta(hours=8)

try:
    with open(cur_f) as f:
        data = json.load(f)
except:
    print(json.dumps({"alerts": [], "error": "api fail"}))
    sys.exit(0)

try:
    with open(prev_f) as f:
        prev = json.load(f)
except:
    prev = {}

alerts = []

# Check todos
todos = data.get('todos', [])
prev_todos = prev.get('todos', [])
prev_ids = {t.get('id') for t in prev_todos}
for t in todos:
    if t.get('id') not in prev_ids:
        alerts.append({
            'source': 'hub-task',
            'title': f"New: {t.get('t', t.get('title', '?'))[:30]}",
            'priority': 2
        })

# Check email counts
email = data.get('email', {})
inbox = email.get('inbox', 0) if isinstance(email, dict) else 0
prev_email = prev.get('email', {})
prev_inbox = prev_email.get('inbox', 0) if isinstance(prev_email, dict) else 0
if isinstance(inbox, int) and isinstance(prev_inbox, int) and inbox > prev_inbox:
    diff = inbox - prev_inbox
    alerts.append({
        'source': 'hub-email',
        'title': f"Email: +{diff} new ({inbox} inbox)",
        'priority': 2
    })

# Check upcoming events (next 2 hours)
events = data.get('events', [])
now = datetime.now(timezone.utc)
upcoming = []
for e in events:
    try:
        start = datetime.fromisoformat(e.get('start', '').replace('Z', '+00:00'))
        diff_min = (start - now).total_seconds() / 60
        if 0 < diff_min < 120:
            local_time = (start + hkt).strftime('%H:%M')
            upcoming.append(f"{local_time} {e.get('title', '?')[:25]}")
    except:
        pass

if upcoming:
    alerts.append({
        'source': 'hub-calendar',
        'title': f"Soon: {upcoming[0]}",
        'priority': 1
    })

# Check jobs (active)
jobs = data.get('jobs', [])
active_jobs = [j for j in jobs if j.get('status') in ('pending', 'in_progress')]

# Save current
with open(prev_f, 'w') as f:
    json.dump(data, f)

summary = {
    "alerts": alerts,
    "tasks_pending": len(todos),
    "email_inbox": inbox if isinstance(inbox, int) else 0,
    "events_today": len(events),
    "jobs_active": len(active_jobs),
    "calendar_next": upcoming[0] if upcoming else "none"
}
print(json.dumps(summary))
PYEOF
}

# ============================================================
# DASHBOARD - full current-state view, pre-formatted for glasses
# Output: JSON with "display" (ready-to-show text) + metadata
# ============================================================
show_dashboard() {
  # Phase 1: Fetch chat list + hub + news IN PARALLEL
  if [[ -n "$BEEPER_TOKEN" ]]; then
    curl -s --max-time 8 -X POST "$BEEPER_URL" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json, text/event-stream" \
      -H "Authorization: Bearer $BEEPER_TOKEN" \
      -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"search_chats","arguments":{"unreadOnly":true,"limit":50}}}' \
      2>/dev/null | grep "^data:" | head -1 | sed 's/^data: //' > "$STATE_DIR/dash-beeper.json" &
  else
    echo '{}' > "$STATE_DIR/dash-beeper.json" &
  fi

  if [[ -n "$HUB_API_URL" && -n "$HUB_API_TOKEN" ]]; then
    curl -s --max-time 8 "$HUB_API_URL" \
      -H "Authorization: Bearer $HUB_API_TOKEN" \
      2>/dev/null > "$STATE_DIR/dash-hub.json" &
  else
    echo '{}' > "$STATE_DIR/dash-hub.json" &
  fi

  if [[ -n "$NEWS_RSS_URL" ]]; then
    curl -sL --max-time 5 "$NEWS_RSS_URL" \
      2>/dev/null > "$STATE_DIR/dash-news.xml" &
  else
    echo '' > "$STATE_DIR/dash-news.xml" &
  fi

  wait

  # Phase 2: Parse chats → get relevant unread chat IDs (skip muted)
  RELEVANT=$(python3 - "$STATE_DIR/dash-beeper.json" << 'PYEOF'
import sys, json, re
try:
    with open(sys.argv[1], 'rb') as f:
        data = json.loads(f.read())
    text = data['result']['content'][0]['text']
except:
    sys.exit(0)
cids = []
for block in text.split('## ')[1:]:
    lines = block.strip().split('\n')
    m = re.search(r'\(chatID:\s*(\d+)\)', lines[0])
    if not m: continue
    cid = m.group(1)
    info = {'unread': 0, 'muted': False, 'platform': '', 'account': ''}
    for ln in lines:
        um = re.search(r'(\d+) unread', ln)
        if um: info['unread'] = int(um.group(1))
        if 'muted' in ln.lower(): info['muted'] = True
        pm = re.search(r'Chat on (\w+)', ln)
        if pm: info['platform'] = pm.group(1)
        am = re.search(r'\((\w+)\)', ln)
        if am and 'Chat on' in ln: info['account'] = am.group(1)
    if info['muted']: continue
    if info['unread'] > 0:
        cids.append(cid)
print(' '.join(cids))
PYEOF
  )

  # Phase 3: Fetch messages for each relevant chat in parallel
  rm -f "$STATE_DIR"/dash-msg-*.json
  if [[ -n "$RELEVANT" ]]; then
    for cid in $RELEVANT; do
      curl -s --max-time 5 -X POST "$BEEPER_URL" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json, text/event-stream" \
        -H "Authorization: Bearer $BEEPER_TOKEN" \
        -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"list_messages\",\"arguments\":{\"chatID\":$cid,\"limit\":5}}}" \
        2>/dev/null | grep "^data:" | head -1 | sed 's/^data: //' > "$STATE_DIR/dash-msg-$cid.json" &
    done
    wait
  fi

  # Phase 4: Combine everything → PRE-FORMATTED display text
  python3 - "$STATE_DIR/dash-beeper.json" "$STATE_DIR/dash-hub.json" "$STATE_DIR" "$STATE_DIR/dash-news.xml" << 'PYEOF'
import sys, json, re, glob
from datetime import datetime, timezone, timedelta

beeper_f, hub_f, state_dir, news_f = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
hkt = timezone(timedelta(hours=8))
now = datetime.now(hkt)

# Common false-positive messages to skip
SKIP_TEXTS = {
    'Incoming call. Use the WhatsApp app to answer.',
    'Missed voice call',
    'Missed video call'
}

messages = []
tasks = []
calendar = []
email = {}
jobs_active = 0
news = []

# --- Parse message files ---
msg_files = sorted(glob.glob(f"{state_dir}/dash-msg-*.json"))
for mf in msg_files:
    try:
        with open(mf) as f:
            data = json.load(f)
        items = json.loads(data['result']['content'][0]['text']).get('items', [])
        for m in items:
            if not m.get('isUnread'): continue
            if m.get('type') == 'REACTION': continue
            text = m.get('text', '')
            if text in SKIP_TEXTS: continue
            if 'Incoming call' in text and 'WhatsApp' in text: continue
            ts = datetime.fromisoformat(m['timestamp'].replace('Z','+00:00')).astimezone(hkt)
            sender = m.get('senderName', '?')
            if ':' in sender: sender = sender.split(':')[0]
            if len(sender) > 18: sender = sender[:15] + '...'
            txt = text if len(text) <= 60 else text[:57] + '...'
            if not txt: txt = '[media]'
            messages.append({
                'time': ts.strftime('%m/%d %H:%M'),
                'sender': 'You' if m.get('isSender') else sender,
                'text': txt
            })
    except:
        pass

# --- Hub: tasks, calendar, email ---
try:
    with open(hub_f) as f:
        hub = json.load(f)
    for t in hub.get('todos', []):
        title = t.get('t', t.get('title', '?'))
        due = t.get('due', '')
        if len(title) > 35: title = title[:32] + '...'
        tasks.append(f"  {title}" + (f" (due {due})" if due else ""))
    for e in hub.get('events', []):
        try:
            start = datetime.fromisoformat(e.get('start', '').replace('Z', '+00:00'))
            local_time = start.astimezone(hkt).strftime('%H:%M')
            title = e.get('title', '?')
            if len(title) > 30: title = title[:27] + '...'
            calendar.append(f"  {local_time} {title}")
        except: pass
    em = hub.get('email', {})
    if isinstance(em, dict):
        email = {"inbox": em.get('inbox', 0), "ads": em.get('ads', 0), "system": em.get('system', 0)}
    jobs = hub.get('jobs', [])
    jobs_active = len([j for j in jobs if j.get('status') in ('pending', 'in_progress')])
except:
    pass

# --- News (RSS) ---
try:
    import xml.etree.ElementTree as ET
    tree = ET.parse(news_f)
    for item in tree.findall('.//item')[:5]:
        title = item.find('title').text if item.find('title') is not None else '?'
        if len(title) > 45: title = title[:42] + '...'
        news.append(f"  {title}")
except:
    pass

# ====== BUILD FORMATTED DISPLAY ======
lines = []
lines.append(f"Terminal Dashboard  {now.strftime('%Y-%m-%d %A %H:%M')}")
lines.append("")

if messages:
    lines.append(f"[ {len(messages)} unread messages ]")
    for m in messages[:8]:
        lines.append(f"  {m['time']}  {m['sender']}: {m['text']}")
else:
    lines.append("[ No unread messages ]")
lines.append("")

lines.append(f"[ {len(tasks)} tasks ]")
if tasks:
    for t in tasks[:5]: lines.append(t)
else:
    lines.append("  No pending tasks")
lines.append("")

lines.append(f"[ {len(calendar)} events today ]")
if calendar:
    for c in calendar[:4]: lines.append(c)
else:
    lines.append("  No events")
lines.append("")

inbox = email.get('inbox', 0)
lines.append(f"[ Email: {inbox} inbox | Jobs: {jobs_active} active ]")
lines.append("")

if news:
    lines.append("[ News ]")
    for n in news: lines.append(n)

display = '\n'.join(lines)

output = {
    "display": display,
    "has_unread": len(messages) > 0,
    "msg_count": len(messages),
    "task_count": len(tasks),
    "event_count": len(calendar)
}
print(json.dumps(output))
PYEOF
}

# ============================================================
# READ - fetch messages from a chat by chatID
# Usage: glasses-cli.sh read <chatID> [limit]
# ============================================================
read_messages() {
  if [[ -z "$BEEPER_TOKEN" ]]; then
    echo '{"error":"BEEPER_TOKEN not set"}'
    return
  fi

  local chat_id="$1"
  local limit="${2:-5}"
  curl -s --max-time 8 -X POST "$BEEPER_URL" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -H "Authorization: Bearer $BEEPER_TOKEN" \
    -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"list_messages\",\"arguments\":{\"chatID\":$chat_id,\"limit\":$limit}}}" \
    2>/dev/null | grep "^data:" | head -1 | sed 's/^data: //' | python3 -c "
import sys, json
from datetime import datetime, timezone, timedelta
hkt = timezone(timedelta(hours=8))
try:
    data = json.load(sys.stdin)
    items = json.loads(data['result']['content'][0]['text']).get('items', [])
    msgs = []
    for m in items:
        if m.get('type') == 'REACTION': continue
        text = m.get('text','')
        if 'Incoming call' in text and 'WhatsApp' in text: continue
        ts = datetime.fromisoformat(m['timestamp'].replace('Z','+00:00')).astimezone(hkt)
        sender = 'You' if m.get('isSender') else m.get('senderName','?').split(':')[0].split('@')[0]
        if len(sender) > 15: sender = sender[:12]+'...'
        if not text: text = '[media]'
        if len(text) > 80: text = text[:77]+'...'
        msgs.append({'time': ts.strftime('%m/%d %H:%M'), 'sender': sender, 'text': text, 'unread': m.get('isUnread',False)})
    print(json.dumps({'messages': msgs, 'chatID': $chat_id}))
except Exception as e:
    print(json.dumps({'error': str(e), 'chatID': $chat_id}))
" 2>/dev/null
}

# ============================================================
# MAIN
# ============================================================
case "${1:-check}" in
  beeper) check_beeper ;;
  ssh) check_ssh ;;
  hub) check_hub ;;
  dashboard) show_dashboard ;;
  read) read_messages "${2:-0}" "${3:-5}" ;;
  check)
    BEEPER=$(check_beeper 2>/dev/null || echo '{"alerts":[]}')
    HUB=$(check_hub 2>/dev/null || echo '{"alerts":[]}')

    python3 - "$BEEPER" "$HUB" << 'PYEOF'
import sys, json

results = []
for arg in sys.argv[1:]:
    try:
        data = json.loads(arg)
        results.append(data)
    except:
        pass

all_alerts = []
for r in results:
    all_alerts.extend(r.get('alerts', []))

all_alerts.sort(key=lambda x: x.get('priority', 5))

summary = {
    'alerts': all_alerts,
    'beeper_monitored': results[0].get('monitored', 0) if results else 0,
    'hub_tasks': results[1].get('tasks_pending', '?') if len(results) > 1 else '?',
    'hub_email': results[1].get('email_inbox', '?') if len(results) > 1 else '?',
}

print(json.dumps(summary))
PYEOF
    ;;
  *)
    echo "Usage: $0 {dashboard|check|read <chatID> [limit]|beeper|hub|ssh}"
    echo ""
    echo "Commands:"
    echo "  dashboard     Full dashboard, pre-formatted for glasses display"
    echo "  check         Diff-only monitoring (for background loop)"
    echo "  read <id>     Read messages from a specific chat"
    echo "  beeper        Beeper message diff check"
    echo "  hub           Hub/API task & email diff check"
    echo "  ssh           SSH intrusion check"
    exit 1
    ;;
esac
