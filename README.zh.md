# Terminal Dashboard — Even G2 智能眼鏡

## 一個碼農和他的 Terminal 的愛情故事

> **碼農** — 名詞。在原始碼的田裡日出而作、日落而 `git commit` 的人。參見：你。

從前有一個碼農。他管自己叫「高級」——不是因為幹了多少年，不是因為 LinkedIn 上有什麼了不起的頭銜，而是因為有一天，他這輩子第一次，對著 Terminal 說話，Terminal *聽懂了*。

不用打字。只是說話。代碼就出現了。

他坐在那裡，雙手放在桌上——不是懸在鍵盤上方，不是去夠滑鼠——只是……放著。他感受到那些年的重量一下子卸掉了。那些 `Ctrl+C`、`Ctrl+V`，那些差點 RSI 的驚嚇，那些尾指按 `Shift` 磨出來的繭。都沒了。AI 替他打字了。他只需要說。

*「原來這就是高級的感覺。」*

但問題是——他遲到了。遲到得讓人難為情。別的開發者早就在這樣做了，已經好幾個月。Twitter 上全是人在秀語音寫代碼的 app，AI 結對編程的創業公司，零鍵盤工作流。而他，一個在代碼田裡耕了這麼多年的老農，現在才第一次感受到泥土從手上掉落。現在才第一次抬起頭。現在才好像剛剛開始。

他是最後一個到達未來的人。但他到了。

到的時候，一副 Even Realities G2 智能眼鏡架在他鼻樑上，右眼角落裡亮著一小片綠色的 HUD。雙手自由了。目光可以離開螢幕了。未來一直在等他，耐心得像一個閃爍的光標。

但還有一個問題。

這個碼農有一段深厚的、忠誠的、長期的感情。不是和人——是和他的 **Terminal**。他們一起經歷了所有。午夜部署。生產事故。那次不小心 `rm -rf` 了然後假裝什麼都沒發生過的事件。Terminal 從來沒讓他失望過。（好吧，除了那一次。但他們挺過來了。）

他離不開。他也*不想*離開。

但 Terminal 外面的世界一直在吵。WhatsApp 訊息響個不停。日曆邀請不斷繁殖。郵件堆得像沒人 review 的 PR。每次他 `⌘+Tab` 切出去看手機，都像是一種背叛。Terminal 的光標對著他眨眼。受傷地。等待著。

> *「我還不夠嗎？」*

碼農盯著閃爍的光標。又看了看右眼角落裡那一抹綠光。然後——在一種只有遲到者才有的安靜的清醒裡，一種什麼都不用再證明的輕鬆裡——他做了一個決定。

一個大膽的、可能有點瘋的決定：

**如果 Terminal 可以把一切都給他看呢？就在眼鏡上。不用離開。**

Even G2 是有 app 的，也有 SDK。但問題是——要用那些 app，就得離開 Terminal。切出去。`⌘+Tab`。又是背叛。

所以他選了另一條路。不寫 app。不用 SDK。只要 bash、python，和一個不問太多問題的 AI。

```
glasses-cli.sh → Claude Code → AskUserQuestion → 手機通知 → Even Hub → 眼鏡
                    ↑
            「直接顯示就好，
              不要想太多」
```

他寫了腳本。他教會 AI 不要思考。他戴上了眼鏡。

然後它就在那裡了——未讀訊息、待辦任務、日曆行程、今天的新聞——全部靜靜地浮在右眼角落，4-bit 灰階綠色。雙手垂在身側，自由。Terminal 的光標繼續閃爍，滿足。安寧。

碼農笑了。那種笑，就像你遲到了去一個派對，到了以後發現——音樂還在放。舞池沒有空。你沒有錯過。你剛好趕上。

他遲到了。他才剛開始。而這完全沒有關係。

因為現在，他可以擁有一切——Terminal、訊息、外面的世界——不用離開命令列溫暖的光。不用再抬起雙手。

就這樣，這個遲到的、剛剛開始的、終於高級的碼農，和他的 Terminal，從此過上了幸福的生活。

在一起。在 `$HOME` 裡。永遠。

`$ _`

---

## 這到底是什麼

一個 bash 腳本，把 **Claude Code** 變成 **Even G2 智能眼鏡** 的即時顯示引擎。它聚合：

- **未讀訊息** — 透過 [Beeper](https://beeper.com) 讀取 WhatsApp + Telegram
- **任務和日曆** — 來自任何 JSON API
- **郵件數量** — 收件匣一目了然
- **新聞標題** — 任何 RSS 源
- **SSH 入侵警報** — 因為偏執也是一種功能

每 60 秒推送到你的眼鏡。你永遠不用離開 Terminal。Terminal 也永遠不會離開你。

## 原理

Even G2 有自己的 app 生態和 SDK——但那些 app 跑在手機上，要離開 Terminal 才能操作。對一個碼農來說，這跟叫他離開家沒有分別。

Claude Code 有一個叫 `AskUserQuestion` 的工具——它彈出互動式提示。這些提示觸發手機通知。裝了 Even Hub 的話，通知就經藍牙飛到眼鏡上。

所以我們只需要：
1. 跑一個 bash 腳本抓取所有資料
2. 告訴 Claude Code：*「這是文字。顯示它。不要想。直接顯示。」*
3. Claude 聽話了（難得）
4. 手機收到通知
5. 眼鏡顯示出來

AI 程式助手變成了一個不會思考的顯示管道。說實話，這可能是它最崇高的使命。

## 架構

```
┌─────────────────────────────────────────────┐
│                  你的 Mac                    │
│                                              │
│  glasses-cli.sh ──→ Claude Code session      │
│    (bash + python3)    │                     │
│    - Beeper API        │ AskUserQuestion     │
│    - 你的 API          │ (工具呼叫)           │
│    - RSS 源            ▼                     │
│              手機通知                         │
│                    │                         │
└────────────────────┼─────────────────────────┘
                     │ Even Hub app (藍牙)
                     ▼
              ┌──────────────┐
              │   Even G2    │
              │   智能眼鏡    │
              │  576×288 px  │
              │  4-bit 綠色   │
              └──────────────┘
```

## 眼鏡上看到的畫面

```
Terminal Dashboard  2026-07-22 Wednesday 14:30

[ 3 條未讀訊息 ]
  07/22 14:25  Alice: 我們三點還見嗎？
  07/22 14:20  Bob: 得閒睇下最新嘅 PR
  07/22 13:55  老媽: [media]

[ 4 個任務 ]
  Review Q3 roadmap (截止 2026-07-22)
  Ship feature flags (截止 2026-07-23)
  更新 onboarding 文件
  修復登入重導向 bug (截止 2026-07-25)

[ 今天 2 個日程 ]
  15:00 團隊站會
  17:30 同經理 1:1

[ 郵件: 8 收件匣 | 工作: 1 進行中 ]

[ 新聞 ]
  重大政策調整公佈...
  地方交通擴建方案獲批
```

整個過程中，你的 Terminal 光標一直在閃。滿足。安寧。

## 監控循環

```
打開 Terminal
     │
     ▼
  「Dashboard」
     │
     ▼
  glasses-cli.sh dashboard ──→ 眼鏡顯示全部資訊
     │
     │ 選擇「開始監控」
     ▼
  每 60 秒:
     │
     ├─ 新訊息？ ──→ 眼鏡震動: "Alice: 你人呢"
     ├─ 新任務？ ──→ 眼鏡震動: "新: 修復生產 bug"
     ├─ 快開會？ ──→ 眼鏡震動: "15:00 團隊站會"
     └─ 沒有新的？──→ 安靜。平和。寫代碼。
```

Session 活著 = 監控運行。Session 斷了 = 監控停止。重連 = 自動恢復。它跟你同呼吸。

## 安裝

### 你需要

- **Even Realities G2**（或 G1）智能眼鏡 + Even Hub app
- **Claude Code**（[claude.ai/code](https://claude.ai/code)）
- **Beeper** 並開啟 Bridge Manager API（[beeper.com](https://beeper.com)）
- **Python 3** 和 **curl**（你是高級碼農，這些你有的）

### 5 分鐘到幸福

```bash
# 1. 克隆
git clone https://github.com/tatlivingdev/terminal-dashboard.git
cd terminal-dashboard

# 2. 設定
cp .env.example .env
# 編輯 .env — 填入你的 Beeper token、API 地址等

# 3. 測試
bash glasses-cli.sh dashboard
# 應該輸出包含 "display" 欄位的 JSON

# 4. 告訴 Claude Code
# 把 claude-memory-example.md 的內容複製到你的專案 memory
# 調整腳本路徑

# 5. 開一個新的 Claude Code session
# Dashboard 自動啟動。戴上眼鏡。
# 再也不用 ⌘+Tab 了。
```

### Beeper 設定

[Beeper 的 Bridge Manager MCP Server](https://github.com/nicolo-ribaudo/beeper-mcp-server) 提供本地 API 來讀取 WhatsApp + Telegram 訊息。

1. 安裝 MCP server
2. 取得你的 Bridge API token
3. 在 `.env` 中設定 `BEEPER_TOKEN`

預設跑在 `http://127.0.0.1:23373/v0/mcp`。本地。快。不經雲端。

### 自訂 Dashboard API

把 `HUB_API_URL` 指向任何回傳以下格式的接口：

```json
{
  "todos": [{"id": "1", "t": "任務名", "due": "2026-07-22"}],
  "events": [{"title": "開會", "start": "2026-07-22T10:00:00Z"}],
  "email": {"inbox": 5, "ads": 12, "system": 3},
  "jobs": [{"status": "pending", "title": "部署 v2.1"}]
}
```

用什麼框架都行——Next.js、Flask、Express、2003 年的 CGI 腳本。腳本不挑。

## 腳本：`glasses-cli.sh`

一個檔案。六個指令。依賴只有 bash + python3 + curl。

| 指令 | 作用 |
|---------|-------------|
| `dashboard` | 完整 dashboard，預格式化，直接推眼鏡 |
| `check` | 只查差異——上次檢查後的新提醒（給 60 秒循環用） |
| `read <chatID>` | 讀取指定對話的訊息 |
| `beeper` | 只檢查 Beeper |
| `hub` | 只檢查 API |
| `ssh` | SSH 入侵檢查 |

`dashboard` 指令輸出的 JSON 包含 `display` 欄位——那就是直接推到眼鏡的預格式化文字。Claude Code 不需要想怎麼排版。直接傳。AI 思考時間為零 = 更新更快。

## Claude Code 記憶設定的竅門

檔案 `claude-memory-example.md` 是關鍵。它告訴 Claude Code：

1. 每次新 session **自動啟動** dashboard
2. 遵循**嚴格的機械流程** — 不思考、不分析、不「讓我來總結一下看到的內容」
3. 把腳本輸出**直接傳給** `AskUserQuestion`
4. 透過 `ScheduleWakeup` 跑 **60 秒監控循環**

把一個會思考的 AI 變成不會思考的顯示管道。Claude 越少思考，眼鏡更新越快。諷刺？也許。有效？絕對。

## 自訂

### 換訊息來源

把 Beeper 換成任何東西：
- **Slack** — Slack Web API 查未讀頻道
- **Discord** — Bot API 查伺服器通知
- **Matrix** — 給真正硬核的人

### 換資料來源

Hub API 是通用的。指向：
- **Todoist / Notion / Linear** — 寫一個小代理
- **GitHub** — Issues、PR、CI 狀態
- **Home Assistant** — 「客廳：24°C」
- **股票** — 看數字漲（或跌）

### 換新聞源

改 `.env` 裡的 `NEWS_RSS_URL`：
- `https://feeds.bbci.co.uk/news/rss.xml`（BBC）
- `https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml`（紐約時報）
- 你公司的內部部落格 RSS
- 任何 RSS/Atom 源

### 換眼鏡

只要能收手機通知，就能用：
- **Even G2**（已測試，這一切的起點）
- **Even G1**（應該可以）
- **Meta Ray-Ban**（透過 Meta 通知系統）
- **任何 AugmentOS 相容裝置**

## 常見問題

**問：Even G2 不是有自己的 app 和 SDK 嗎？為什麼不直接寫一個？**
答：有。但那些 app 要離開 Terminal 才能操作。對碼農來說，離開 Terminal 等於離家出走。這個方案讓你在 Terminal Mode 裡就能收到一切，不用切出去。

**問：用 AI 程式助手當通知管道……是不是大材小用？**
答：是。但也不是：不用離開 Terminal 寫 app、不用搞藍牙協定、不用學新 SDK。只要 bash。我們故事裡的碼農還有很多田要耕。他珍惜時間。

**問：Claude Code 斷了怎麼辦？**
答：Dashboard 停了。像心跳一樣。重連就恢復。設計如此——它和你的程式 session 同生共死。

**問：不戴眼鏡能用嗎？**
答：能！`AskUserQuestion` 的提示會直接顯示在 Claude Code 裡。眼鏡只是加了「永遠不用離開 Terminal」的魔法。

**問：電池夠嗎？**
答：Even G2 續航約 2 天。Dashboard 只是文字通知——耗電極少。

## 貢獻

這個碼農歡迎貢獻。一些讓 Terminal 關係更牢固的想法：

- [ ] 天氣 widget（這樣你就知道要不要出門……但你為什麼要出門）
- [ ] 系統監控（CPU / 記憶體 / 磁碟顯示在眼鏡上）
- [ ] 日程倒數計時（「還有 12 分鐘開會」→「還有 5 分鐘」→「你遲到了」）
- [ ] 番茄鐘
- [ ] 自訂 widget 外掛系統
- [ ] 支援其他 AI 程式助手

## 授權條款

MIT — 因為 Terminal 信仰自由。

---

*獻給每一個遲到的、剛剛開始的碼農，和每一個一口氣清掉 47 個通知只為趕回 Terminal 的人。*

*還不晚。你剛好趕上。*

*你不是一個人。你在 `$HOME`。*

*`$ _`*
