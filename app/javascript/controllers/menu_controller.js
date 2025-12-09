import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper/bundle"
import "swiper/css/bundle"

export default class extends Controller {
  static targets = []

  connect() {
    this.swipers = {}
  }

  open(event) {
    const id = event.currentTarget.dataset.modalId
    const modal = document.getElementById(`modal-${id}`)
    if (modal) {
      modal.classList.remove("hidden")

      // Swiper初期化
      if (!modal.dataset.swiperInitialized) {
        const swiper = new Swiper(`#modal-${id} .swiper`, {
          loop: false,
          pagination: {
            el: `#modal-${id} .swiper-pagination`,
            clickable: true
          }
        })

        this.swipers[id] = swiper

        swiper.on("slideChange", () => {
          this.updateSaveLink(id)
        })

        modal.dataset.swiperInitialized = true
      }

      this.updateSaveLink(id)
    } else {
      console.warn(`❌ modal-${id} が見つかりません`)
    }
  }

  close(event) {
    const modal = event.currentTarget.closest("[id^=modal-]")
    if (modal) modal.classList.add("hidden")
  }

  updateSaveLink(id) {
    const swiper = this.swipers[id]
    if (!swiper) return

    const activeSlide = swiper.slides[swiper.activeIndex]
    const img = activeSlide?.querySelector("img")
    const link = document.getElementById(`save-image-${id}`)

    if (img && link) {
      link.href = img.src
    }
  }
}
