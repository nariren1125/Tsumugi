import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { postId: Number }

    open() {
        const sheet = document.getElementById("comments-sheet")
        const frame = document.getElementById("comments_sheet_frame")
        if (!sheet || !frame) return

        frame.setAttribute("src", `/posts/${this.postIdValue}/comments/sheet`)
        frame.reload()

        const controller = this.application.getControllerForElementAndIdentifier(sheet, "comments-sheet")
        controller?.open()
    }
}
