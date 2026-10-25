# Harmony Navigation Bar + Safe Area

A reusable ChatGPT Skill for HarmonyOS ArkUI edge-to-edge navigation shells: dynamic safe areas, bottom navigation, scroll-to-hide/show behavior, rebound filtering, and compact X-style monochrome tab interactions.

用于 HarmonyOS ArkUI 的可复用 ChatGPT Skill：沉浸式 edge-to-edge、动态安全区、底部导航、滚动显隐、回弹过滤，以及克制的 X 风格单色 Tab 交互。

## What it covers / 能做什么

- Dynamic status-bar, gesture-indicator, and cutout safe areas / 动态状态栏、手势区、挖孔安全区
- Edge-to-edge window setup / 沉浸式窗口
- Bottom navigation with outline/filled icon states / outline/filled 双态底栏图标
- Scroll up to hide, scroll down to show / 上滑隐藏、下滑显示
- Overscroll and spring-rebound filtering / 过度滚动与回弹过滤
- Safe insets for editor/detail pages / 编辑器与详情页 safe area
- Minimal-change integration into existing HarmonyOS projects / 最小改动迁移到已有鸿蒙项目

## Skill layout / Skill 结构

```text
SKILL.md
agents/openai.yaml
references/implementation.md
references/qa-checklist.md
assets/BottomBarScrollController.ets
assets/ScrollBoundaryGuard.ets
```

## Example prompts / 示例提示词

- `Use this skill to make my HarmonyOS bottom navigation edge-to-edge and safe-area aware.`
- `把这个鸿蒙项目的底部导航改成上滑隐藏、下滑出现，并正确处理手势区 safe area。`
- `Port the navigation behavior from this reference HarmonyOS project without changing my business logic.`
- `照参考项目迁移导航栏交互和 safe area，但不要动现有业务逻辑。`

## Design baseline / 设计基线

- 24 vp monochrome icons / 24vp 单色图标
- 38-40 vp navigation content height / 38-40vp 底栏内容高度
- Outline/filled cross-fade / outline/filled 交叉淡入
- 0.94 press scale / 0.94 按压缩放
- Hide threshold ~24, show threshold ~16 / 隐藏阈值约 24，显示阈值约 16

## Notes / 说明

The templates are starting points. A correct implementation must adapt to the target project's theme, routing, state, and page structure instead of blindly replacing files.

模板只是起点。正确实现必须适配目标项目的主题、路由、状态和页面结构，而不是机械覆盖文件。
