import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { postId: Number }

    open(event) {
        alert("🟢 ボタンのタップを検知しました！");
        console.log("postId:", this.hasPostIdValue, this.postIdValue)
        const sheet = document.getElementById("comments-sheet")
        const frame = document.getElementById("comments_sheet_frame")
        if (!sheet || !frame) {
            alert("🔴 シートまたはフレームが見つかりません");
            return
        }

        if (!this.hasPostIdValue) {
            alert("🔴 postId がありません");
            console.warn("[comments-sheet-opener] postId missing", this.element)
            return
        }

        frame.innerHTML = `<div class="px-4 py-6 text-sm opacity-60">読み込み中...</div>`

        const url = `/posts/${this.postIdValue}/comments/sheet`
        // 属性よりプロパティの方が素直
        frame.src = url

        // iOS Safari では特定の条件下でカスタムイベントの bubbles: true が document まで到達しないバグ等があるため、直接 document に対して発火させます
        document.dispatchEvent(
            new CustomEvent("comments:open", {
                detail: { postId: this.postIdValue },
            })
        )
    }
}
