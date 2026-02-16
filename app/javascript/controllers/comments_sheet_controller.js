import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.onOpen = (e) => {
            console.log("[comments-sheet] open", e.detail)
            this.open()
        }
        this.onClose = () => this.close()

        // sheet要素に依存せず、documentで拾う（ズレに強い）
        document.addEventListener("comments:open", this.onOpen)
        document.addEventListener("comments:close", this.onClose)
    }

    disconnect() {
        document.removeEventListener("comments:open", this.onOpen)
        document.removeEventListener("comments:close", this.onClose)
    }

    open() {
        // 表示（ここをあなたのCSSに合わせて変更OK）
        this.element.classList.remove("hidden")
        this.element.classList.add("is-open")
    }

    close() {
        this.element.classList.remove("is-open")
        this.element.classList.add("hidden")
    }
}
