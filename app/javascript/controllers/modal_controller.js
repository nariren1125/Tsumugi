import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {

    const id = event.currentTarget.dataset.modalId
    const modal = document.getElementById(`modal-${id}`)

    if (modal) {
      modal.classList.remove("hidden")

      // Swiperの初期化（初回のみ）
      if (!modal.dataset.swiperInitialized) {
        // 👇 window.Swiper を使う
        new window.Swiper(`#modal-${id} .swiper`, {
          loop: false,
          pagination: {
            el: `#modal-${id} .swiper-pagination`,
            clickable: true,
          },
        })

        modal.dataset.swiperInitialized = true
      }
    } else {
      console.warn(`❌ モーダル modal-${id} が見つかりません`)
    }
  }

  close(event) {
    const modal = event.currentTarget.closest("[id^=modal-]")
    if (modal) {
      modal.classList.add("hidden")
    }
  }
}
