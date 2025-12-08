import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    console.log("✅ modal#open 発火しました")
    const id = event.currentTarget.dataset.modalId
    const modal = document.getElementById(`modal-${id}`)
    if (modal) {
      modal.classList.remove("hidden")
    } else {
      console.warn(`❌ モーダル modal-${id} が見つかりません`)
    }
  }

  close(event) {
    const modal = event.currentTarget.closest(".modal")
    if (modal) {
      modal.classList.add("hidden")
    }
  }
}
