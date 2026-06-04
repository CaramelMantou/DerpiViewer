# Validation Report — derpiviewer

- **DESIGN.md:** `_bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/DESIGN.md`
- **EXPERIENCE.md:** `_bmad-output/planning-artifacts/ux-designs/ux-derpiviewer-2026-06-04/EXPERIENCE.md`
- **Run at:** 2026-06-04T08:00:00Z

## Overall verdict

这两份 spine 文档是对现有 Flutter 代码库的**诚实且全面的 brownfield 逆向工程记录**——它们准确描述了已构建的内容。但作为下游消费者的可执行合约，文档存在根本性结构问题：DESIGN.md 使用非标准的 frontmatter 格式（Dart 符号引用而非 hex 值、数组对象而非平面 token），无法被机械提取；EXPERIENCE.md 的 token 引用指向章节而非具体 token。Edge Case Hunter 揭示了代码库本身几乎不处理任何边缘情况——空状态、离线、权限拒绝、竞态条件均无防护。

**关键结论：** 文档忠实记录了现状的完整程度，但现状本身在关键 UX 健壮性方面存在严重缺口。作为"记录现有设计"的文档目标已达成；但如果目标是构成下游开发的可执行合约，需要重大结构性修改。

## Category verdicts (Rubric Walker)

| # | Category | Verdict |
|---|----------|---------|
| 1 | Flow Coverage | **broken** |
| 2 | Token Completeness | **broken** |
| 3 | Component Coverage | **broken** |
| 4 | State Coverage | **thin** |
| 5 | Visual Reference Coverage | **broken** |
| 6 | Bloat and Overspecification | **adequate** |
| 7 | Inheritance Discipline | **broken** |
| 8 | Shape Fit | **adequate** |

## Findings by severity

### Critical (13 total)

**Design.md Token Completeness** — 主色彩使用 Dart 符号引用（`Colors.blue`, `Colors.black54`, `Colors.grey[850]`）而非 hex 字符串。非 Flutter 消费者无法解析。(DESIGN.md frontmatter `colors`)
Fix: 替换为 hex 等价值（如 `Colors.grey[850]` → `'#303030'`）

**Design.md Token Completeness** — `colors` frontmatter 使用 `{name, value, role}` 对象数组而非规范要求的平面对象格式，`{path.to.token}` 解析不可行。(DESIGN.md frontmatter)
Fix: 重构为 `primary: '#2196F3'` 格式

**Design.md Token Completeness** — `components` frontmatter 使用 prose 描述和代码属性名（`barForegroundColor`）而非 token-mapped 对象。(DESIGN.md frontmatter `components`)
Fix: 替换为结构化 token map（如 `floating-action-button: { background: '{colors.primary}' }`）

**Design.md Inheritance** — EXPERIENCE.md 中使用 `{DESIGN.md.colors}`、`{DESIGN.md.typography}` 等章节级引用，不可解析到具体 token。(EXPERIENCE.md: Foundation)
Fix: 替换为单个 token 路径

**Component Coverage** — 5 个 DESIGN.md 组件（AppBar, FAB, Drawer, Switch, Dropdown）在 EXPERIENCE.md Component Patterns 中没有对应的行为规范。(Both spines)
Fix: 为这些组件补充行为条目

**Component Coverage** — EXPERIENCE.md 的 5 个模式（Infinite Scroll, Navigation, Image Loading, Bottom Sheet, Tag Display）在 DESIGN.md 中没有视觉规范。(Both spines)
Fix: 补充视觉规范或重命名以消除歧义

**Flow Coverage** — 零个 Key Flow 包含 failure path。下游开发者没有错误状态的行为指导。(EXPERIENCE.md: Key Flows)
Fix: 为每个 Flow 添加 `Failure:` 段落

**Empty/invalid search submission** — 空搜索词提交无验证守卫，可能推送空查询或无意义 API 请求。(review-edge-case-hunter.md)
Fix: 在输入为空时禁用搜索按钮，或在导航前验证

**Infinite scroll no termination** — 无 `hasMore` sentinel；API 耗尽后持续调用 `fetchMore()`，浪费配额和电量。(review-edge-case-hunter.md)
Fix: 追踪 `hasMore` 状态，当 API 返回少于页大小时停止

**Booru switch data pollution** — 切换 booru 时未取消进行中的 API 请求，新旧 booru 数据混合。(review-edge-case-hunter.md)
Fix: 切换时取消所有 pending 请求，清空网格，重新加载首页

**Favorite toggle race condition** — 快速切换收藏引起 UI/DB 不同步；toast 在异步写入完成前触发。(review-edge-case-hunter.md)
Fix: 防抖处理、队列写入、“写入中忽略新点击”、失败时回滚

**State Coverage** — 所有 surface 无空状态 UI；用户看到空白页面无任何消息或引导。(EXPERIENCE.md: State Patterns)
Fix: 为每个 surface 添加专用空状态

**State Coverage** — 无 surface 处理离线状态。全表格标记 `[NOT HANDLED]`。(EXPERIENCE.md: State Patterns)
Fix: 定义离线行为：至少被动提示 + 收藏的本地写入继续语义

### High (19 total)

**Flow Coverage** — `screens` 中 "Dialogs (×7)" 将 7 个对话框捆绑为不透明项；Flow 4 覆盖了其中一部分但未独立处理。(EXPERIENCE.md frontmatter)
Fix: 分别列出对话框或添加专门的对话框交互 Flow

**Shape Fit** — 缺失 Inspiration & Anti-patterns 章节；`.decision-log.md` 中的设计决策未在这里反映。(EXPERIENCE.md)
Fix: 添加 Inspiration & Anti-patterns，提炼决策日志内容

**Shape Fit** — DESIGN.md frontmatter 缺失必需的 `name` 和 `description` 字段。(DESIGN.md frontmatter)
Fix: 添加 `name: derpiviewer` 和 `description` 字段

**Inheritance** — 组件命名在两个 spine 不一致（"Gallery Toolbar" vs "Gallery Interaction"、"Fav Icon" vs "Favorite Toggle"）。(Both spines)
Fix: 统一所有组件名称，使用 DESIGN.md 名称作为规范列表

**Inheritance** — EXPERIENCE.md 使用 `source` (flat string) 而非 `sources` (array)，偏离规范要求的 metadata 结构。(EXPERIENCE.md frontmatter)
Fix: 改为 `sources` 数组，每个 source 一个条目

**Search results empty state** — 搜索返回 0 结果 = 空白 grid，无 "No results" 提示。(review-edge-case-hunter.md)
Fix: 居中显示 "No results for {query}" 消息 + 建议

**Favorites empty state** — 0 收藏 = 空白 grid，无引导信息。(review-edge-case-hunter.md)
Fix: 显示 "No favorites yet" + 操作引导

**Tag contrast dark mode** — body、general、official、spoiler 标签前景色在 `grey[850]` 背景上对比度不足 WCAG AA。(review-edge-case-hunter.md)
Fix: 定义暗黑模式专用标签前景色，对比度 ≥ 4.5:1

**Gallery toolbar icons invisible** — 固定白色无背景的图标在浅色图片上消失。(review-edge-case-hunter.md)
Fix: 添加半透明暗色背景或图标阴影

**Slideshow + video conflict** — 视频页不暂停 slideshow timer，用户永远看不到完整视频。(review-edge-case-hunter.md)
Fix: 检测视频页 → 暂停 timer / 跳过视频页 / 添加视频提示

**Infinite scroll loop** — 内容不足一屏时 `maxScrollExtent == 0`，条件永真 → 连续触发 fetch。(review-edge-case-hunter.md)
Fix: 添加 `_isFetching` guard 和 `maxScrollExtent > 0` 检查

**Hardcoded Chinese i18n** — 5 个 drawer 项硬编码中文，英文模式下显示中文。(review-edge-case-hunter.md)
Fix: 提取到 `.arb` 文件，添加英文翻译

**No cold-load state** — State Patterns 表直接从 "Loading" 开始，无首屏渲染状态。(EXPERIENCE.md: State Patterns)
Fix: 添加 Cold load 列/行（skeleton、cached content 或 splash）

**No focus states** — 所有交互组件（chips、switches、dropdowns）无视觉焦点处理。(EXPERIENCE.md: State Patterns)
Fix: 为每个交互组件添加 focus-state 条目

**Flow 2 navigation contradiction** — 描述用户在已进入 SearchPage 后从 HomePage drawer 调整搜索设置，但 Drawer 在 HomePage 上。(EXPERIENCE.md: Flow 2)
Fix: 重排 Flow 步骤以匹配实际导航路径

**Multiple slideshow timer instances** — 快速切换播放/暂停可能产生多个并发 `Timer.periodic`。(review-edge-case-hunter.md)
Fix: 在暂停分支 cancel 现有 timer，创建前确保旧的已 null

**Unbounded image memory** — 长时间浏览无缓存大小限制，低端设备可能 OOM。(review-edge-case-hunter.md)
Fix: 配置最大缓存大小（如 50 MB）和最大对象数（如 100 images）

**Video + preload memory pressure** — 幻灯片模式下 PageView 预加载 + 视频缓冲区可能堆叠。(review-edge-case-hunter.md)
Fix: 幻灯片模式禁用 PageView 预加载；释放离屏页面的视频控制器

**Infinite scroll data accumulation** — 无内存条目上限；30+ 分钟浏览可累积数千条目。(review-edge-case-hunter.md)
Fix: 限制内存条目数（如最近 200 条），或使用虚拟滚动

### Medium (17 total)

_Rubric Walker: 6 — Flow coverage dialog bundling, typography missing lineHeight/letterSpacing, component pattern format should use tables, loading state no skeleton, known gaps no prescriptions, DESIGN.md Do's/Don'ts mixes code and design rules._

_Edge Case Hunter: 11 — storage permission unchecked, date/number format not locale-aware, RTL not verified, stale FavouritePage snapshot, search history not per-booru, toast before async confirm, rapid download debouncing, 1-image slideshow timer, Hero jank with large images, dark mode no transition animation, scroll flick triggers duplicate fetchMore._

### Low (7 total)

_Rubric Walker: 3 — rounded values use prose not dimensions, spacing uses Flutter-specific names, DESIGN.md Do's/Don'ts code items dilute design rules._

_Edge Case Hunter: 4 — tag text overflow in chip, unbounded search history growth, drawer header not dark-adapted, semantic color parity in dark mode._

## Reviewer files

- `review-rubric.md` — 规范走查：8 个类别的结构化覆盖分析
- `review-edge-case-hunter.md` — 边缘案例猎手：7 个维度的边界条件系统性审查

---

_报告生成于 BMad UX Validation Pipeline | 2026-06-04_
