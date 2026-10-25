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

  public handleScroll(scrollOffset: number, atTop: boolean,
    currentlyVisible: boolean): boolean | undefined {
    if (atTop) {
      this.reset()
      return currentlyVisible ? undefined : true
    }
    if (scrollOffset === 0) return undefined

    const direction: number = scrollOffset > 0 ? 1 : -1
    if (direction !== this.lastDirection) {
      this.lastDirection = direction
      this.hideDistance = 0
      this.showDistance = 0
    }

    if (direction > 0) {
      this.showDistance = 0
      if (!currentlyVisible) return undefined
      this.hideDistance += scrollOffset
      if (this.hideDistance >= this.HIDE_THRESHOLD) {
        this.hideDistance = 0
        return false
      }
      return undefined
    }

    this.hideDistance = 0
    if (currentlyVisible) return undefined
    this.showDistance += Math.abs(scrollOffset)
    if (this.showDistance >= this.SHOW_THRESHOLD) {
      this.showDistance = 0
      return true
    }
    return undefined
  }
}
