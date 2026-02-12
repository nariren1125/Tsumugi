import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["panel", "backdrop"]

    connect() {
        this.dragging = false
        this.startY = 0
        this.currentY = 0
        this.lastDelta = 0
    }

    open() {
        console.log("comments-sheet open")
        this.element.classList.remove("hidden")
        document.body.classList.add("overflow-hidden")

        // 初期位置を下に
        this.panelTarget.style.transition = "none"
        this.panelTarget.style.transform = "translateY(120%)"

        // 背景リセット
        if (this.hasBackdropTarget) {
            this.backdropTarget.style.backgroundColor = "rgba(0,0,0,0.6)"
        }

        requestAnimationFrame(() => {
            this.panelTarget.style.transition = "transform 220ms ease"
            this.panelTarget.style.transform = "translateY(0px)"
        })
    }

    close() {
        this.panelTarget.style.transition = "transform 200ms ease"
        this.panelTarget.style.transform = "translateY(120%)"

        if (this.hasBackdropTarget) {
            this.backdropTarget.style.transition = "background-color 200ms ease"
            this.backdropTarget.style.backgroundColor = "rgba(0,0,0,0)"
        }

        window.setTimeout(() => {
            this.element.classList.add("hidden")
            document.body.classList.remove("overflow-hidden")
            this.panelTarget.style.transform = "translateY(0px)"
        }, 180)
    }

    start(event) {
        this.dragging = true
        this.startY = event.clientY
        this.currentY = 0
        this.lastDelta = 0

        this.panelTarget.style.transition = "none"
    }

    move(event) {
        if (!this.dragging) return

        const delta = event.clientY - this.startY
        const clamped = Math.max(-20, delta)

        this.lastDelta = clamped
        this.panelTarget.style.transform = `translateY(${clamped}px)`

        // 背景フェード
        if (this.hasBackdropTarget) {
            const opacity = Math.max(0, 0.6 - (Math.max(0, clamped) / 400))
            this.backdropTarget.style.backgroundColor = `rgba(0,0,0,${opacity})`
        }
    }

    end() {
        if (!this.dragging) return
        this.dragging = false

        const shouldClose = this.lastDelta > 120

        this.panelTarget.style.transition = "transform 200ms ease"

        if (shouldClose) {
            this.close()
        } else {
            this.panelTarget.style.transform = "translateY(0px)"

            if (this.hasBackdropTarget) {
                this.backdropTarget.style.transition = "background-color 200ms ease"
                this.backdropTarget.style.backgroundColor = "rgba(0,0,0,0.6)"
            }
        }
    }
}
