import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    reset(event) {
        // event/detailが無いときは何もしない
        if (!event?.detail?.success) return

        // form以外に付いてても落ちないように
        if (this.element instanceof HTMLFormElement) {
            this.element.reset()
        }
    }
}
