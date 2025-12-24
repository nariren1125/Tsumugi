import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  init() {
    if (this.swiper) return

    this.swiper = new window.Swiper(this.element, {
      loop: false,
      pagination: {
        el: this.element.querySelector(".swiper-pagination"),
        clickable: true,
      },
      slidesPerView: 1,
      spaceBetween: 10,
      centeredSlides: true,
    })
  }
}
