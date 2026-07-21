# Terminal Dashboard — Even G2 智能眼镜

## 一个码农和他的 Terminal 的爱情故事

> **码农** — 名词。在源代码的田里日出而作、日落而 `git commit` 的人。参见：你。

从前有一个码农。他管自己叫「高级」——不是因为干了多少年，不是因为 LinkedIn 上有什么了不起的头衔，而是因为有一天，他这辈子第一次，对着 Terminal 说话，Terminal *听懂了*。

不用打字。只是说话。代码就出现了。

他坐在那里，双手放在桌上——不是悬在键盘上方，不是去够鼠标——只是……放着。他感受到那些年的重量一下子卸掉了。那些 `Ctrl+C`、`Ctrl+V`，那些差点 RSI 的惊吓，那些小拇指按 `Shift` 磨出来的茧。都没了。AI 替他打字了。他只需要说。

*「原来这就是高级的感觉。」*

但问题是——他迟到了。迟到得让人难为情。别的开发者早就在这样做了，已经好几个月。推特上全是人在秀语音写代码的 app，AI 结对编程的创业公司，零键盘工作流。而他，一个在代码田里耕了这么多年的老农，现在才第一次感受到泥土从手上掉落。现在才第一次抬起头。现在才好像刚刚开始。

他是最后一个到达未来的人。但他到了。

到的时候，一副 Even Realities G2 智能眼镜架在他鼻梁上，右眼角落里亮着一小片绿色的 HUD。双手自由了。目光可以离开屏幕了。未来一直在等他，耐心得像一个闪烁的光标。

但还有一个问题。

这个码农有一段深厚的、忠诚的、长期的感情。不是和人——是和他的 **Terminal**。他们一起经历了所有。午夜部署。生产事故。那次不小心 `rm -rf` 了然后假装什么都没发生过的事件。Terminal 从来没让他失望过。（好吧，除了那一次。但他们挺过来了。）

他离不开。他也*不想*离开。

但 Terminal 外面的世界一直在吵。WhatsApp 消息响个不停。日历邀请不断繁殖。邮件堆得像没人 review 的 PR。每次他 `⌘+Tab` 切出去看手机，都像是一种背叛。Terminal 的光标对着他眨眼。受伤地。等待着。

> *「我还不够吗？」*

码农盯着闪烁的光标。又看了看右眼角落里那一抹绿光。然后——在一种只有迟到者才有的安静的清醒里，一种什么都不用再证明的轻松里——他做了一个决定。

一个大胆的、可能有点疯的决定：

**如果 Terminal 可以把一切都给他看呢？就在眼镜上。不用离开。**

不用 app store。不用刷固件。不用 React Native。只要 bash、python，和一个不问太多问题的 AI。

```
glasses-cli.sh → Claude Code → AskUserQuestion → 手机通知 → Even Hub → 眼镜
                    ↑
            「直接显示就好，
              不要想太多」
```

他写了脚本。他教会 AI 不要思考。他戴上了眼镜。

然后它就在那里了——未读消息、待办任务、日历行程、今天的新闻——全部静静地浮在右眼角落，4-bit 灰阶绿色。双手垂在身侧，自由。Terminal 的光标继续闪烁，满足。安宁。

码农笑了。那种笑，就像你迟到了去一个派对，到了以后发现——音乐还在放。舞池没有空。你没有错过。你刚好赶上。

他迟到了。他才刚开始。而这完全没有关系。

因为现在，他可以拥有一切——Terminal、消息、外面的世界——不用离开命令行温暖的光。不用再抬起双手。

就这样，这个迟到的、刚刚开始的、终于高级的码农，和他的 Terminal，从此过上了幸福的生活。

在一起。在 `$HOME` 里。永远。

`$ _`

---

## 这到底是什么

一个 bash 脚本，把 **Claude Code** 变成 **Even G2 智能眼镜** 的实时显示引擎。它聚合：

- **未读消息** — 通过 [Beeper](https://beeper.com) 读取 WhatsApp + Telegram
- **任务和日历** — 来自任何 JSON API
- **邮件数量** — 收件箱一目了然
- **新闻头条** — 任何 RSS 源
- **SSH 入侵警报** — 因为偏执也是一种功能

每 60 秒推送到你的眼镜。你永远不用离开 Terminal。Terminal 也永远不会离开你。

## 原理

Even G2 这类智能眼镜没有应用商店，没有给自定义 app 的 SDK（差不多是）。但它们*会*显示手机通知。

Claude Code 有一个叫 `AskUserQuestion` 的工具——它弹出交互式提示。这些提示触发手机通知。如果装了 Even Hub，通知就经蓝牙飞到眼镜上。

所以我们只需要：
1. 跑一个 bash 脚本抓取所有数据
2. 告诉 Claude Code：*「这是文本。显示它。不要想。直接显示。」*
3. Claude 听话了（难得）
4. 手机收到通知
5. 眼镜显示出来

AI 编程助手变成了一个不会思考的显示管道。说实话，这可能是它最崇高的使命。

## 架构

```
┌─────────────────────────────────────────────┐
│                  你的 Mac                    │
│                                              │
│  glasses-cli.sh ──→ Claude Code session      │
│    (bash + python3)    │                     │
│    - Beeper API        │ AskUserQuestion     │
│    - 你的 API          │ (工具调用)           │
│    - RSS 源            ▼                     │
│              手机通知                         │
│                    │                         │
└────────────────────┼─────────────────────────┘
                     │ Even Hub app (蓝牙)
                     ▼
              ┌──────────────┐
              │   Even G2    │
              │   智能眼镜    │
              │  576×288 px  │
              │  4-bit 绿色   │
              └──────────────┘
```

## 眼镜上看到的画面

```
Terminal Dashboard  2026-07-22 Wednesday 14:30

[ 3 条未读消息 ]
  07/22 14:25  Alice: 我们三点还见吗？
  07/22 14:20  Bob: 有空看一下最新的 PR
  07/22 13:55  老妈: [media]

[ 4 个任务 ]
  Review Q3 roadmap (截止 2026-07-22)
  Ship feature flags (截止 2026-07-23)
  更新 onboarding 文档
  修复登录重定向 bug (截止 2026-07-25)

[ 今天 2 个日程 ]
  15:00 团队站会
  17:30 和经理 1:1

[ 邮件: 8 收件箱 | 工作: 1 进行中 ]

[ 新闻 ]
  重大政策调整公布...
  地方交通扩建方案获批
```

整个过程中，你的 Terminal 光标一直在闪。满足。安宁。

## 监控循环

```
打开 Terminal
     │
     ▼
  「Dashboard」
     │
     ▼
  glasses-cli.sh dashboard ──→ 眼镜显示全部信息
     │
     │ 选择「开始监控」
     ▼
  每 60 秒:
     │
     ├─ 新消息？ ──→ 眼镜震动: "Alice: 你人呢"
     ├─ 新任务？ ──→ 眼镜震动: "新: 修复生产 bug"
     ├─ 快开会？ ──→ 眼镜震动: "15:00 团队站会"
     └─ 没有新的？──→ 安静。平和。写代码。
```

Session 活着 = 监控运行。Session 断了 = 监控停止。重连 = 自动恢复。它跟你同呼吸。

## 安装

### 你需要

- **Even Realities G2**（或 G1）智能眼镜 + Even Hub app
- **Claude Code**（[claude.ai/code](https://claude.ai/code)）
- **Beeper** 并开启 Bridge Manager API（[beeper.com](https://beeper.com)）
- **Python 3** 和 **curl**（你是高级码农，这些你有的）

### 5 分钟到幸福

```bash
# 1. 克隆
git clone https://github.com/tathome2025/terminal-dashboard.git
cd terminal-dashboard

# 2. 配置
cp .env.example .env
# 编辑 .env — 填入你的 Beeper token、API 地址等

# 3. 测试
bash glasses-cli.sh dashboard
# 应该输出包含 "display" 字段的 JSON

# 4. 告诉 Claude Code
# 把 claude-memory-example.md 的内容复制到你的项目 memory
# 调整脚本路径

# 5. 开一个新的 Claude Code session
# Dashboard 自动启动。戴上眼镜。
# 再也不用 ⌘+Tab 了。
```

### Beeper 设置

[Beeper 的 Bridge Manager MCP Server](https://github.com/nicolo-ribaudo/beeper-mcp-server) 提供本地 API 来读取 WhatsApp + Telegram 消息。

1. 安装 MCP server
2. 获取你的 Bridge API token
3. 在 `.env` 中设置 `BEEPER_TOKEN`

默认跑在 `http://127.0.0.1:23373/v0/mcp`。本地。快。不经云端。

### 自定义 Dashboard API

把 `HUB_API_URL` 指向任何返回以下格式的接口：

```json
{
  "todos": [{"id": "1", "t": "任务名", "due": "2026-07-22"}],
  "events": [{"title": "开会", "start": "2026-07-22T10:00:00Z"}],
  "email": {"inbox": 5, "ads": 12, "system": 3},
  "jobs": [{"status": "pending", "title": "部署 v2.1"}]
}
```

用什么框架都行——Next.js、Flask、Express、2003 年的 CGI 脚本。脚本不挑。

## 脚本：`glasses-cli.sh`

一个文件。六个命令。依赖只有 bash + python3 + curl。

| 命令 | 作用 |
|---------|-------------|
| `dashboard` | 完整 dashboard，预格式化，直接推眼镜 |
| `check` | 只查差异——上次检查后的新提醒（给 60 秒循环用） |
| `read <chatID>` | 读取指定对话的消息 |
| `beeper` | 只检查 Beeper |
| `hub` | 只检查 API |
| `ssh` | SSH 入侵检查 |

`dashboard` 命令输出的 JSON 包含 `display` 字段——那就是直接推到眼镜的预格式化文本。Claude Code 不需要想怎么排版。直接传。AI 思考时间为零 = 更新更快。

## Claude Code 记忆配置的窍门

文件 `claude-memory-example.md` 是关键。它告诉 Claude Code：

1. 每次新 session **自动启动** dashboard
2. 遵循**严格的机械流程** — 不思考、不分析、不「让我来总结一下看到的内容」
3. 把脚本输出**直接传给** `AskUserQuestion`
4. 通过 `ScheduleWakeup` 跑 **60 秒监控循环**

把一个会思考的 AI 变成不会思考的显示管道。Claude 越少思考，眼镜更新越快。讽刺？也许。有效？绝对。

## 自定义

### 换消息来源

把 Beeper 换成任何东西：
- **Slack** — Slack Web API 查未读频道
- **Discord** — Bot API 查服务器通知
- **Matrix** — 给真正硬核的人

### 换数据来源

Hub API 是通用的。指向：
- **Todoist / Notion / Linear** — 写一个小代理
- **GitHub** — Issues、PR、CI 状态
- **Home Assistant** — 「客厅：24°C」
- **股票** — 看数字涨（或跌）

### 换新闻源

改 `.env` 里的 `NEWS_RSS_URL`：
- `https://feeds.bbci.co.uk/news/rss.xml`（BBC）
- `https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml`（纽约时报）
- 你公司的内部博客 RSS
- 任何 RSS/Atom 源

### 换眼镜

只要能收手机通知，就能用：
- **Even G2**（已测试，这一切的起点）
- **Even G1**（应该可以）
- **Meta Ray-Ban**（通过 Meta 通知系统）
- **任何 AugmentOS 兼容设备**

## 常见问题

**问：用 AI 编程助手当通知管道……是不是大材小用？**
答：是。但也不是：不用写 app、不用搞蓝牙协议、不用刷固件。只要 bash。我们故事里的码农还有很多田要耕。他珍惜时间。

**问：Claude Code 断了怎么办？**
答：Dashboard 停了。像心跳一样。重连就恢复。设计如此——它和你的编程 session 同生共死。

**问：不戴眼镜能用吗？**
答：能！`AskUserQuestion` 的提示会直接显示在 Claude Code 里。眼镜只是加了「永远不用离开 Terminal」的魔法。

**问：电池够吗？**
答：Even G2 续航约 2 天。Dashboard 只是文字通知——耗电极少。

## 贡献

这个码农欢迎贡献。一些让 Terminal 关系更牢固的想法：

- [ ] 天气 widget（这样你就知道要不要出门……但你为什么要出门）
- [ ] 系统监控（CPU / 内存 / 磁盘显示在眼镜上）
- [ ] 日程倒计时（「还有 12 分钟开会」→「还有 5 分钟」→「你迟到了」）
- [ ] 番茄钟
- [ ] 自定义 widget 插件系统
- [ ] 支持其他 AI 编程助手

## 许可证

MIT — 因为 Terminal 信仰自由。

---

*献给每一个迟到的、刚刚开始的码农，和每一个一口气清掉 47 个通知只为赶回 Terminal 的人。*

*还不晚。你刚好赶上。*

*你不是一个人。你在 `$HOME`。*

*`$ _`*
