---
name: harmony-navigationbar-safearea
description: "Reusable HarmonyOS ArkUI navigation and safe-area workflow for edge-to-edge apps. Use when ChatGPT needs to create, port, review, or repair a HarmonyOS bottom navigation shell with dynamic status/navigation avoid areas, scroll-triggered hide/show behavior, overscroll filtering, tab state reset, or X/Twitter-like monochrome outline/filled icon interactions. Also use when adapting these patterns from a reference HarmonyOS project into another project without breaking existing page logic. / 用于鸿蒙 ArkUI 底部导航、沉浸式 safe area、滚动显隐和参考项目迁移。"
---

# Harmony Navigation Bar + Safe Area / 鸿蒙导航栏与安全区

## Goal / 目标

Build or port a production-grade HarmonyOS ArkUI app shell with edge-to-edge layout, dynamic safe areas, a compact icon-only bottom navigation bar, and stable scroll-driven visibility behavior.

构建或迁移一套可用于实际项目的 HarmonyOS ArkUI 外壳：沉浸式 edge-to-edge、动态安全区、精简纯图标底部导航，以及稳定的滚动显隐交互。

## Workflow / 工作流

1. **Inspect before editing / 修改前先检查**
   - Identify the entry `UIAbility`, root page, all tab pages, each page's scroll container, current bottom navigation component, theme/color source, and any editor/detail pages.
   - Do not rewrite business logic just to add navigation or safe-area behavior.
   - 先定位 `UIAbility`、根页面、各 Tab 页面、滚动容器、现有底栏、主题颜色来源，以及编辑器/详情页。不要为了接入导航和安全区而重写业务逻辑。

2. **Make the window edge-to-edge / 开启沉浸式窗口**
   - In the main `UIAbility`, enable full-screen layout and system bars.
   - Store top and bottom avoid-area heights in `AppStorage`.
   - Read `TYPE_SYSTEM`, `TYPE_NAVIGATION_INDICATOR`, and `TYPE_CUTOUT` avoid areas.
   - Update values on `avoidAreaChange`.
   - Never hard-code status-bar or gesture-indicator heights.
   - 在主 `UIAbility` 开启全屏布局并保留系统栏；把顶部和底部避让高度写入 `AppStorage`；读取系统栏、手势指示器和挖孔区域，并监听变化。禁止写死状态栏/手势区高度。

3. **Build the root shell / 构建根页面壳层**
   - Use a bottom-aligned `Stack` containing the current page plus the bottom navigation.
   - Convert stored avoid heights from px to vp at the UI layer.
   - Pass `topContentInset`, `bottomContentInset`, and an `onContentScroll` callback into tab pages.
   - Compute content bottom inset as `barContentHeight + bottomSafeArea + contentGap`.
   - Compute hidden translation as `barContentHeight + bottomSafeArea`.
   - 使用底部对齐 `Stack` 叠放当前页面和底部导航；在 UI 层把 px 转成 vp；向页面传入顶部/底部 inset 与滚动回调；内容底部 inset = 底栏内容高度 + 底部 safe area + 间隔；隐藏位移 = 底栏内容高度 + 底部 safe area。

4. **Filter scroll rebound / 过滤回弹滚动**
   - Use a boundary guard before the shared bottom-bar visibility controller.
   - Treat positive `Scroll.onDidScroll` `offsetY` as content moving upward and negative as content moving downward.
   - Ignore top/bottom overscroll and spring rebound frames, especially `Fling` frames at an edge.
   - Call the shared handler only with real browsing movement.
   - 在共享底栏显隐控制器之前加入边界过滤；`offsetY > 0` 表示内容向上移动，`offsetY < 0` 表示内容向下移动；忽略顶部/底部过度滚动与弹簧回弹，尤其是边缘处的 `Fling` 帧。

5. **Control bottom-bar visibility / 控制底栏显隐**
   - Accumulate upward movement before hiding and downward movement before showing; do not toggle on every frame.
   - Recommended baseline: hide after about 24 vp-equivalent scroll distance, show after about 16.
   - Reaching the top must force the bar visible.
   - Switching tabs, opening a nested section, or returning from a nested section must reset the controller and show the bar.
   - 上滑累计到约 24 再隐藏，下滑累计到约 16 再显示；不要每帧切换。回到顶部必须显示底栏。切换 Tab、进入/退出子页面时重置控制器并显示底栏。

6. **Use compact X-like interaction language / 使用克制的 X 风格交互语言**
   - Prefer icon-only tabs with no labels when the app structure is obvious.
   - Use paired outline/filled icons and cross-fade opacity for selection.
   - Baseline icon size: 24 vp. Keep the touch target larger than the visible icon.
   - On press, use a subtle circular background and about `0.94` scale; release immediately on `Up` or `Cancel`.
   - Keep icons monochrome, geometric, balanced, and visually centered. Avoid decorative gradients or oversized strokes inside the navigation bar.
   - 在结构清晰时优先使用无文字纯图标；选中态使用 outline/filled 两套图标交叉淡入；图标约 24vp，触控区应更大；按压使用轻微圆形底色和约 `0.94` 缩放；图标保持单色、几何、视觉居中，避免花哨渐变和粗重笔画。

7. **Handle editors and non-tab pages / 处理编辑器和非 Tab 页面**
   - Any full-screen editor/detail page must consume the same dynamic top/bottom avoid areas.
   - Do not assume the root bottom inset protects a routed page.
   - 全屏编辑器/详情页也必须独立消费动态顶部/底部安全区，不能假设根页面的 inset 会自动保护路由页面。

8. **Verify before delivery / 交付前验证**
   - Check gesture navigation, status bar, cutout devices, dark/light themes, tab switching, fast flings, top/bottom rebound, and nested navigation.
   - Ensure hidden navigation uses `HitTestMode.None` so invisible controls cannot intercept taps.
   - Confirm existing business state and back behavior remain intact.
   - 检查手势导航、状态栏、挖孔屏、深浅色、Tab 切换、快速 fling、上下回弹和子页面导航；隐藏底栏必须禁用命中测试；确认原有业务状态和返回逻辑未被破坏。

## Required implementation references / 必看实现参考

Read [`references/implementation.md`](references/implementation.md) when writing or modifying ArkTS code. It contains the recommended component contracts, avoid-area pattern, scroll controller, boundary guard, and navigation animation values.

编写或修改 ArkTS 时读取 [`references/implementation.md`](references/implementation.md)，其中包含组件接口、安全区模式、滚动控制器、边界过滤器和导航动画参数。

Read [`references/qa-checklist.md`](references/qa-checklist.md) before declaring the work complete.

交付前读取 [`references/qa-checklist.md`](references/qa-checklist.md)。

## Reusable assets / 可复用资源

Use the templates in `assets/` as starting points, then adapt imports, theme colors, resource names, and callbacks to the target project rather than blindly replacing project files.

可使用 `assets/` 中的模板作为起点，但必须根据目标项目调整 import、主题颜色、资源名和回调，不要机械覆盖现有文件。

## Output rules / 输出规则

- Prefer the smallest safe patch. Preserve existing page structure and business logic.
- When the user asks for a replacement package, include only changed/new files while preserving relative paths.
- If the target project uses a different theme system, map the navigation colors to that system instead of introducing a second theme layer.
- Explain any unavoidable behavior change explicitly.
- 优先最小安全补丁，保留现有页面结构和业务逻辑。
- 用户要求覆盖包时，只交付新增/修改文件并保持相对路径。
- 如果目标项目已有主题系统，导航颜色必须接入现有主题，不新增第二套主题。
- 不可避免的行为变化必须明确说明。
