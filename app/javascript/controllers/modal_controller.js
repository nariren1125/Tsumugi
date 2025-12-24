import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    const id = this.element.dataset.modalId || event.currentTarget.dataset.modalId
    const modal = document.getElementById(`modal-${id}`)

    if (!modal) return

    // ① モーダルを表示
    modal.classList.remove("hidden")

    // ② 中の swiper_controller を探す
    const swiperElement = modal.querySelector('[data-controller="swiper"]')

    if (swiperElement) {
      const controller = this.application.getControllerForElementAndIdentifier(
        swiperElement,
        "swiper"
      )

      controller?.init()
    }
  }

  close() {
    this.element.classList.add("hidden")
  }
}
