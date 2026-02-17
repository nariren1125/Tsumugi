import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        commentId: Number,
        destroyUrl: String,
        canDelete: Boolean,
        canDelete: Boolean,
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
        if (!this.hasCommentIdValue) return

        this.moved = false
        this.startX = event.clientX
        this.startY = event.clientY
        this.pointerId = event.pointerId

        // 取りこぼし防止
        try { this.element.setPointerCapture(this.pointerId) } catch (_) { }

        this.clearTimer()
        this.timer = window.setTimeout(() => {
            if (this.moved) return
            this.openActions()
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
        if (!this.hasCommentIdValue) return
        event.preventDefault()
        this.openActions()
    }

    // ✅ Instagram風アクションモーダルを開く
    openActions() {
        document.dispatchEvent(
            new CustomEvent("comment-actions:open", {
                detail: {
                    commentId: this.commentIdValue,
                    destroyUrl: this.hasDestroyUrlValue ? this.destroyUrlValue : null,
                    canDelete: this.hasCanDeleteValue ? this.canDeleteValue : false,
                },
            })
        )
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
