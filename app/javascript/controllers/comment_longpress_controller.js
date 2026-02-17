import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["deleteButton"]
    static values = {
        delay: { type: Number, default: 450 },
    }

    connect() {
        this.timer = null
        this.startX = 0
        this.startY = 0
        this.moved = false
        this.pointerId = null
    }

    pointerDown(event) {
        if (event.pointerType === "mouse" && event.button !== 0) return
        if (!this.hasDeleteButtonTarget) return

        this.moved = false
        this.startX = event.clientX
        this.startY = event.clientY
        this.pointerId = event.pointerId

        // 取りこぼし防止
        try { this.element.setPointerCapture(this.pointerId) } catch (_) { }

        this.clearTimer()
        this.timer = window.setTimeout(() => {
            if (this.moved) return
            this.showOnlyThis()
        }, this.delayValue)
    }

    pointerMove(event) {
        if (!this.timer) return

        const dx = Math.abs(event.clientX - this.startX)
        const dy = Math.abs(event.clientY - this.startY)

        // スクロール誤爆防止（少し緩め）
        if (dx > 18 || dy > 18) {
            this.moved = true
            this.clearTimer()
        }
    }

    pointerUp() {
        this.release()
        this.clearTimer()
    }

    pointerCancel() {
        this.release()
        this.clearTimer()
    }

    contextMenu(event) {
        if (!this.hasDeleteButtonTarget) return
        event.preventDefault()
        this.showOnlyThis()
    }

    showOnlyThis() {
        document
            .querySelectorAll("[data-comment-longpress-target='deleteButton']")
            .forEach((el) => el.classList.add("hidden"))

        this.deleteButtonTarget.classList.remove("hidden")
    }

    release() {
        if (this.pointerId == null) return
        try { this.element.releasePointerCapture(this.pointerId) } catch (_) { }
        this.pointerId = null
    }

    clearTimer() {
        if (this.timer) {
            window.clearTimeout(this.timer)
            this.timer = null
        }
    }
}
