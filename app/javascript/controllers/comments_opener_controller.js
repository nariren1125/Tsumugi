import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { targetId: String }

    open() {
        const el = document.getElementById(this.targetIdValue)
        if (!el) return

        const controller = this.application.getControllerForElementAndIdentifier(el, "comments-sheet")
        controller?.open()
    }
}
