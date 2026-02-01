import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    document.addEventListener("click", this.closeOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const opened = this.menuTarget.classList.contains("pointer-events-auto")
    if (opened) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("opacity-0", "scale-95", "pointer-events-none")
    this.menuTarget.classList.add("opacity-100", "scale-100", "pointer-events-auto")
  }

  close() {
    this.menuTarget.classList.add("opacity-0", "scale-95", "pointer-events-none")
    this.menuTarget.classList.remove("opacity-100", "scale-100", "pointer-events-auto")
  }

  closeOnOutsideClick = (event) => {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}
