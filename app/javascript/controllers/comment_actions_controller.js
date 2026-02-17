import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["deleteButton"]

    connect() {
        this.commentId = null
        this.destroyUrl = null

        this.onOpen = (e) => this.open(e)
        this.onClose = () => this.close()

        document.addEventListener("comment-actions:open", this.onOpen)
        document.addEventListener("comment-actions:close", this.onClose)
    }

    disconnect() {
        document.removeEventListener("comment-actions:open", this.onOpen)
        document.removeEventListener("comment-actions:close", this.onClose)
    }

    open(event) {
        const { commentId, destroyUrl, canDelete } = event.detail || {}
        if (!commentId) return

        this.commentId = commentId
        this.destroyUrl = destroyUrl || null

        // ✅ 権限に応じてボタンを出し分け
        if (this.hasDeleteButtonTarget) {
            this.deleteButtonTarget.classList.toggle("hidden", !canDelete)
        }


        this.element.classList.remove("hidden")
        document.body.classList.add("overflow-hidden")
    }

    close() {
        this.element.classList.add("hidden")
        document.body.classList.remove("overflow-hidden")

        // ✅ 次回のために必ず初期化
        this.commentId = null
        this.destroyUrl = null
    }

    delete() {
        if (!this.destroyUrl) return

        const form = document.createElement("form")
        form.method = "post"
        form.action = this.destroyUrl
        // form.dataset.turbo = "true" // 省略可（デフォルトでTurbo有効）

        const method = document.createElement("input")
        method.type = "hidden"
        method.name = "_method"
        method.value = "delete"
        form.appendChild(method)

        const token = document.querySelector("meta[name='csrf-token']")?.content
        if (token) {
            const csrf = document.createElement("input")
            csrf.type = "hidden"
            csrf.name = "authenticity_token"
            csrf.value = token
            form.appendChild(csrf)
        }

        document.body.appendChild(form)

        // ✅ Turboに拾わせるため requestSubmit を使う
        if (typeof form.requestSubmit === "function") {
            form.requestSubmit()
        } else {
            // requestSubmit未対応環境用（念のため）
            form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))
        }

        // submit直後に消すとTurboがフォームを見失うことがあるので、少し待つか
        // Turboが処理し終わったタイミングで消すのが理想だが、
        // 簡易的には requestSubmit は非同期で即座に戻るので、直後に remove しても
        // Turboが submit イベントを拾えていれば概ね動作する。
        // 安全策を取るなら setTimeout(() => form.remove(), 0)
        setTimeout(() => form.remove(), 0)

        this.close()
    }


}
