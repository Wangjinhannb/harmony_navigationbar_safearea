# QA Checklist / 质量检查清单

Use this checklist before delivery. / 交付前逐项检查。

## Window and safe area / 窗口与安全区

- [ ] Edge-to-edge layout is enabled. / 已开启 edge-to-edge。
- [ ] Status and navigation system bars remain enabled as intended. / 系统状态栏与导航栏按设计保留。
- [ ] Top inset comes from system/cutout avoid areas, not a constant. / 顶部 inset 来自动态 avoid area，而不是常量。
- [ ] Bottom inset includes navigation-indicator/cutout avoid areas. / 底部 inset 包含手势指示器/挖孔避让。
- [ ] `avoidAreaChange` updates runtime values. / 运行时 avoid area 变化会更新。
- [ ] Editor/detail pages independently consume safe areas. / 编辑器/详情页独立处理 safe area。

## Bottom navigation / 底部导航

- [ ] Bar stays above the gesture indicator. / 底栏不压住手势区。
- [ ] Page content is not hidden behind the bar. / 页面内容不会被底栏遮挡。
- [ ] Upward browsing hides the bar only after threshold accumulation. / 上滑累计超过阈值后才隐藏。
- [ ] Downward browsing shows the bar only after threshold accumulation. / 下滑累计超过阈值后才显示。
- [ ] Returning to the top always shows the bar. / 回到顶部必定显示。
- [ ] Top/bottom spring rebound does not flicker the bar. / 上下回弹不会导致底栏闪烁。
- [ ] Hidden bar uses `HitTestMode.None`. / 隐藏底栏禁用命中测试。
- [ ] Tab switching resets visibility state. / 切 Tab 会重置显隐状态。

## Icons and interaction / 图标与交互

- [ ] Outline and filled icons have the same visual center. / outline 与 filled 视觉中心一致。
- [ ] Icons are crisp at 24 vp. / 24vp 下清晰。
- [ ] Press scale is subtle and returns on cancel. / 按压缩放克制，Cancel 时能恢复。
- [ ] Navigation contains no unnecessary labels or decoration. / 无多余文字和装饰。
- [ ] Dark/light theme contrast remains sufficient. / 深浅色对比度正常。

## Regression / 回归

- [ ] Existing business state is preserved. / 原业务状态不丢失。
- [ ] Back behavior is unchanged unless intentionally specified. / 返回逻辑未被意外修改。
- [ ] Nested pages do not leave the bar permanently hidden. / 子页面返回后底栏不会永久隐藏。
- [ ] Fast fling and repeated direction changes remain stable. / 快速 fling 与频繁反向滚动稳定。
- [ ] Keyboard/editor interactions do not overlap bottom controls. / 键盘和编辑器不会与底部控件重叠。
