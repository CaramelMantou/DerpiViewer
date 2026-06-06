---
title: 'Fix search page dark mode foreground colors'
type: 'bugfix'
created: '2026-06-06'
status: 'done'
baseline_commit: '19515cae3a9d0619f18662a12fbae490e75cdd5b'
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** 搜索页面的搜索按钮（放大镜图标）和「常用标签」头部提示文本使用 `Theme.of(context).disabledColor` 作为前景色，但该颜色在 `AppTheme._buildTheme()` 中未被显式定义，依赖 Flutter 默认值，在夜间模式下要么与背景对比度不足，要么视觉上与日间模式无明显差异，导致切换夜间模式后这些控件颜色不正常。

**Approach:** 将两处 `disabledColor` 替换为根据主题亮度正确适配的颜色——搜索按钮禁用态使用 `iconTheme.color` 降低不透明度，头部文本直接使用 TextTheme 已有的 `foregroundColor`，确保日间/夜间模式切换时颜色正确响应。

## Boundaries & Constraints

**Always:**
- 只修改 `lib/pages/search_page.dart`，不改动 `lib/style/theme.dart`
- 保持日间模式的现有视觉效果不变
- 使用 `Theme.of(context)` 动态获取颜色（不硬编码色值）
- 修改后的颜色必须与 AppBar 背景（日间 `Colors.blue` / 夜间 `Colors.blueGrey`）和 scaffold 背景（日间 `Colors.white` / 夜间 `Colors.grey[850]`）有足够对比度

**Ask First:**
- 无

**Never:**
- 不新增主题颜色常量
- 不修改 MaterialApp 的 themeMode 或 theme 绑定逻辑
- 不影响其他页面的颜色

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| 日间模式 — 搜索框为空 | `_isSearchEnabled=false`, `ThemeMode.light` | 搜索图标可见，颜色为日间主题的 subdued 色 | N/A |
| 日间模式 — 搜索框有文本 | `_isSearchEnabled=true`, `ThemeMode.light` | 搜索图标可见，颜色为 AppBar 前景色（white） | N/A |
| 夜间模式 — 搜索框为空 | `_isSearchEnabled=false`, `ThemeMode.dark` | 搜索图标可见，颜色适配夜间主题（非 `disabledColor` 默认值） | N/A |
| 夜间模式 — 搜索框有文本 | `_isSearchEnabled=true`, `ThemeMode.dark` | 搜索图标可见，颜色为 AppBar 前景色（white） | N/A |
| 夜间模式 — 有常用标签 | `ThemeMode.dark`, `_favoriteTags` 非空 | 头部文本「常用标签」颜色适配夜间主题 | N/A |
| 运行时切换主题 | 从任一模式切换到另一模式 | 搜索图标禁用态颜色和头部文本颜色随主题实时更新 | N/A |

</frozen-after-approval>

## Code Map

- `lib/pages/search_page.dart:196-197` — 搜索图标的 disabled 状态颜色，使用 `Theme.of(context).disabledColor`
- `lib/pages/search_page.dart:231` — 「常用标签」头部文本颜色，使用 `Theme.of(context).disabledColor`
- `lib/style/theme.dart:15-83` — `AppTheme._buildTheme()`，定义主题结构但未显式设置 `disabledColor`；`iconTheme.color` 和 `textTheme.*` 的 `foregroundColor` 在日间/夜间间正确切换

## Tasks & Acceptance

**Execution:**
- [x] `lib/pages/search_page.dart` — 将搜索图标禁用态颜色从 `Theme.of(context).disabledColor` 改为 `Theme.of(context).iconTheme.color?.withOpacity(0.38)` — 使用主题感知的 subdued 色替代未定义的 disabledColor
- [x] `lib/pages/search_page.dart` — 将「常用标签」头部文本颜色从 `Theme.of(context).disabledColor` 改为直接使用 `Theme.of(context).textTheme.bodySmall?.color` — 使用主题已定义的 foregroundColor，在日间/夜间间自动切换

**Acceptance Criteria:**
- Given 夜间模式已激活，when 搜索框为空（搜索按钮处于禁用态），then 搜索（放大镜）图标在 AppBar 上清晰可见，颜色与日间模式的禁用态有明显差异
- Given 夜间模式已激活且常用标签列表非空，when 查看搜索页面 body，then「常用标签」头部文本清晰可见，颜色与日间模式有明显差异
- Given 任意主题模式，when 从日间切换到夜间（或反之），then 搜索按钮禁用态颜色和头部文本颜色应实时跟随主题变化

## Spec Change Log

## Verification

**Commands:**
- `flutter analyze lib/pages/search_page.dart` — expected: no issues found
- `flutter test` — expected: all existing tests pass

**Manual checks (if no CLI):**
- 在日间模式下打开搜索页面，确认搜索按钮和「常用标签」文本正常显示
- 切换到夜间模式，确认以上两处颜色自适应变化、清晰可见

## Suggested Review Order

- Entry point — disabled search icon now uses theme-aware `iconTheme.color` at 38% alpha instead of undefined `disabledColor`; enabled state unchanged
  [`search_page.dart:195`](../../../lib/pages/search_page.dart#L195)

- Header text drops `disabledColor` override in favor of TextTheme's `bodySmall.color` which carries the theme-defined `foregroundColor` that switches between light/dark
  [`search_page.dart:231`](../../../lib/pages/search_page.dart#L231)
