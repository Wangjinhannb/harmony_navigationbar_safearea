# Implementation Reference / 实现参考

## 1. Recommended architecture / 推荐架构

```text
UIAbility
  -> edge-to-edge window
  -> AppStorage(topAvoidHeight, bottomAvoidHeight)

Root Index
  -> current tab page
  -> shared BottomBarScrollController
  -> BottomNavigation overlay

Each scrollable tab page
  -> ScrollBoundaryGuard
  -> onDidScroll / onReachStart / onReachEnd
  -> onContentScroll(offset, atTop)
```

```text
UIAbility
  -> 沉浸式窗口
  -> AppStorage(topAvoidHeight, bottomAvoidHeight)

根页面 Index
  -> 当前 Tab 页面
  -> 共享 BottomBarScrollController
  -> BottomNavigation 叠层

每个可滚动 Tab 页面
  -> ScrollBoundaryGuard
  -> onDidScroll / onReachStart / onReachEnd
  -> onContentScroll(offset, atTop)
```

## 2. Window avoid-area pattern / 窗口安全区模式

Use this pattern in the main `UIAbility`:

```ts
AppStorage.setOrCreate<number>('topAvoidHeight', 0)
AppStorage.setOrCreate<number>('bottomAvoidHeight', 0)

await mainWindow.setWindowLayoutFullScreen(true)
await mainWindow.setWindowSystemBarEnable(['status', 'navigation'])

const systemArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
const navigationArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
const cutoutArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT)

const topHeight = Math.max(systemArea.topRect.height, cutoutArea.topRect.height)
const bottomHeight = Math.max(
  systemArea.bottomRect.height,
  navigationArea.bottomRect.height,
  cutoutArea.bottomRect.height
)

AppStorage.setOrCreate<number>('topAvoidHeight', topHeight)
AppStorage.setOrCreate<number>('bottomAvoidHeight', bottomHeight)
```

Also update these values from `mainWindow.on('avoidAreaChange', ...)` when the type is system, navigation indicator, or cutout.

同时监听 `avoidAreaChange`，当类型为 system、navigation indicator 或 cutout 时重新计算。

## 3. Root-page contracts / 根页面接口

Recommended state:

```ts
@State currentTab: number = 0
@State bottomBarVisible: boolean = true
@StorageLink('topAvoidHeight') topAvoidHeight: number = 0
@StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 0
```

Recommended helpers:

```ts
private getTopSafeAreaVp(): number {
  return this.topAvoidHeight > 0 ? this.getUIContext().px2vp(this.topAvoidHeight) : 0
}

private getBottomSafeAreaVp(): number {
  return this.bottomAvoidHeight > 0 ? this.getUIContext().px2vp(this.bottomAvoidHeight) : 0
}

private getBottomBarHiddenOffset(): number {
  return this.bottomBarContentHeight + this.getBottomSafeAreaVp()
}

private getContentBottomInset(): number {
  return this.bottomBarContentHeight + this.getBottomSafeAreaVp() + this.bottomContentGap
}
```

For each tab page, pass:

```ts
topContentInset: this.getTopSafeAreaVp()
bottomContentInset: this.getContentBottomInset()
onContentScroll: (offset: number, atTop: boolean) => this.handleContentScroll(offset, atTop)
```

每个 Tab 页面都应接收顶部 inset、底部 inset 和滚动回调。

## 4. Scroll visibility controller / 滚动显隐控制器

Baseline behavior:

```ts
export class BottomBarScrollController {
  private readonly HIDE_THRESHOLD: number = 24
  private readonly SHOW_THRESHOLD: number = 16
  private lastDirection: number = 0
  private hideDistance: number = 0
  private showDistance: number = 0

  public reset(): void {
    this.lastDirection = 0
    this.hideDistance = 0
    this.showDistance = 0
  }

  public handleScroll(offset: number, atTop: boolean, visible: boolean): boolean | undefined {
    if (atTop) {
      this.reset()
      return visible ? undefined : true
    }
    if (offset === 0) return undefined

    const direction = offset > 0 ? 1 : -1
    if (direction !== this.lastDirection) {
      this.lastDirection = direction
      this.hideDistance = 0
      this.showDistance = 0
    }

    if (direction > 0) {
      this.showDistance = 0
      if (!visible) return undefined
      this.hideDistance += offset
      if (this.hideDistance >= this.HIDE_THRESHOLD) {
        this.hideDistance = 0
        return false
      }
      return undefined
    }

    this.hideDistance = 0
    if (visible) return undefined
    this.showDistance += Math.abs(offset)
    if (this.showDistance >= this.SHOW_THRESHOLD) {
      this.showDistance = 0
      return true
    }
    return undefined
  }
}
```

Use `animateTo` around the actual state change. A good baseline is ~200 ms to hide and ~250 ms to show.

实际切换 `bottomBarVisible` 时使用 `animateTo`；隐藏约 200ms，显示约 250ms 是合适基线。

## 5. Boundary guard / 滚动边界过滤

Without a guard, spring rebound can immediately undo the intended visibility state.

如果不做边界过滤，列表回弹可能立刻反向触发底栏显隐。

```ts
export class ScrollBoundaryGuard {
  private atTop: boolean = true
  private atBottom: boolean = false

  public reachStart(): void {
    this.atTop = true
    this.atBottom = false
  }

  public reachEnd(): void {
    this.atTop = false
    this.atBottom = true
  }

  public consume(offset: number, state: ScrollState): number | undefined {
    if (offset === 0 || state === ScrollState.Idle) return undefined

    if (this.atTop) {
      if (offset <= 0 || state === ScrollState.Fling) return undefined
      this.atTop = false
    }

    if (this.atBottom) {
      if (offset >= 0 || state === ScrollState.Fling) return undefined
      this.atBottom = false
    }

    return offset
  }
}
```

Page wiring:

```ts
.onDidScroll((offsetX: number, offsetY: number, scrollState: ScrollState) => {
  const filtered = this.scrollBoundaryGuard.consume(offsetY, scrollState)
  if (filtered !== undefined) this.onContentScroll(filtered, false)
})
.onReachStart(() => {
  this.scrollBoundaryGuard.reachStart()
  this.onContentScroll(0, true)
})
.onReachEnd(() => {
  this.scrollBoundaryGuard.reachEnd()
})
```

## 6. Bottom navigation interaction / 底部导航交互

Recommended baseline values:

| Property / 属性 | Baseline / 基线 |
|---|---:|
| Visible icon / 可见图标 | 24 vp |
| Touch target / 触控区 | 28-32 vp |
| Bar content height / 底栏内容高度 | 38-40 vp |
| Selection cross-fade / 选中淡入 | 150-160 ms |
| Press animation / 按压动画 | 110-120 ms |
| Press scale / 按压缩放 | 0.94 |

Use two images per tab:

```ts
Image(outlineIcon).opacity(selected ? 0 : 1)
Image(filledIcon).opacity(selected ? 1 : 0)
```

When hidden:

```ts
.translate({ y: visible ? 0 : hiddenOffset })
.opacity(visible ? 1 : 0)
.hitTestBehavior(visible ? HitTestMode.Default : HitTestMode.None)
```

隐藏时必须同时位移、透明并关闭命中测试，否则不可见底栏仍可能拦截点击。

## 7. Icon design rules / 图标设计规则

- Use a consistent 24×24 vector viewport.
- Keep outline and filled versions optically aligned.
- Prefer 1.7-2.0 equivalent stroke weight for outline icons.
- Avoid tiny decorative details that blur at 24 vp.
- Center by optical mass, not only by bounding box.
- Keep the navigation monochrome; let state, not color variety, carry emphasis.

- 统一使用 24×24 矢量视口。
- outline 与 filled 必须光学校准。
- outline 线宽可按约 1.7-2.0 的视觉重量设计。
- 避免 24vp 下会糊掉的小装饰。
- 以视觉重心居中，不只看几何包围盒。
- 导航保持单色，用状态变化而不是多彩颜色表达强调。

## 8. Integration rule / 集成规则

Do not replace an existing theme, router, repository, or business state layer merely to introduce this shell. Adapt names and callbacks to the target project.

不要为了引入这套壳层而替换项目已有的主题、路由、数据仓库或业务状态层；应做适配而不是重构。
