export class ScrollBoundaryGuard {
  private atTop: boolean = true
  private atBottom: boolean = false

  public reset(): void {
    this.atTop = true
    this.atBottom = false
  }

  public reachStart(): void {
    this.atTop = true
    this.atBottom = false
  }

  public reachEnd(): void {
    this.atTop = false
    this.atBottom = true
  }

  public consume(scrollOffset: number, scrollState: ScrollState): number | undefined {
    if (scrollOffset === 0 || scrollState === ScrollState.Idle) return undefined

    if (this.atTop) {
      if (scrollOffset <= 0 || scrollState === ScrollState.Fling) return undefined
      this.atTop = false
    }

    if (this.atBottom) {
      if (scrollOffset >= 0 || scrollState === ScrollState.Fling) return undefined
      this.atBottom = false
    }

    return scrollOffset
  }
}
