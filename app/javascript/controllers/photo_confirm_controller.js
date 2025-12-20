import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter"]

  connect() {
    this.swiper = new Swiper(this.element, {
      loop: false,
      resistance: false,
      resistanceRatio: 0,

      on: {
        init: (swiper) => {
          this.updateCounter(swiper)
          this.updateSwipeLock(swiper)
        },
        slideChange: (swiper) => {
          this.updateCounter(swiper)
          this.updateSwipeLock(swiper)
        }
      }
    })
  }

  updateCounter(swiper) {
    const current = swiper.activeIndex + 1
    const total = swiper.slides.length
    this.counterTarget.textContent = `${current} / ${total}`
  }

  updateSwipeLock(swiper) {
    swiper.allowSlidePrev = !swiper.isBeginning
    swiper.allowSlideNext = !swiper.isEnd
  }
}
