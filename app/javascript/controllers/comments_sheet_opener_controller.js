import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { postId: Number }

    open(event) {
        // click と touchstart が両方発火してシートが開閉するのを防ぐ
        if (event.type === 'touchstart') {
            // touchstart で発火した場合は直後の click を無視するためのフラグを立てる
            this.touchHandled = true
        } else if (event.type === 'click' && this.touchHandled) {
            this.touchHandled = false
            return
        }

        console.log("postId:", this.hasPostIdValue, this.postIdValue)
        const sheet = document.getElementById("comments-sheet")
        const frame = document.getElementById("comments_sheet_frame")
        if (!sheet || !frame) {
            return
        }

        if (!this.hasPostIdValue) {
            console.warn("[comments-sheet-opener] postId missing", this.element)
            return
        }

        frame.innerHTML = `<div class="px-4 py-6 text-sm opacity-60">読み込み中...</div>`

        const url = `/posts/${this.postIdValue}/comments/sheet`
        // 属性よりプロパティの方が素直
        frame.src = url

        // setTimeoutでイベント発火を非同期にし、メインスレッドのブロックやTurboの競合を防ぎます
        setTimeout(() => {
            document.dispatchEvent(
                new CustomEvent("comments:open", {
                    detail: { postId: this.postIdValue },
                })
            )
        }, 10)
    }
}
