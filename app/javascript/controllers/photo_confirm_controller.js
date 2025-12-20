import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter"]

  connect() {
    const swiperEl = this.element.querySelector(".swiper")

    this.swiper = new Swiper(swiperEl, {
      loop: false,

      // 👇 ここが重要
      resistance: false,
      resistanceRatio: 0,

      on: {
        init: (swiper) => {
          this.updateCounter(swiper)
        },
        slideChange: (swiper) => {
          this.updateCounter(swiper)
        }
      }
    })
  }

  updateCounter(swiper) {
    const current = swiper.activeIndex + 1
    const total = swiper.slides.length

    this.counterTarget.textContent = `${current} / ${total}`
  }
}