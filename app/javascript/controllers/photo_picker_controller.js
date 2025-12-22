
// 写真選択コントローラー
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "nextButton", "form"]

  connect() {
    console.log("photo-picker connected")

    // 🔑 画面表示後に自動でファイルピッカーを開く
    requestAnimationFrame(() => {
      this.openPicker()
    })
  }

  openPicker() {
    this.inputTarget.click()
  }

  handleFiles() {
    const files = this.inputTarget.files
    if (!files || files.length === 0) return

    const file = files[0]

    this.previewTarget.src = URL.createObjectURL(file)
    this.previewTarget.classList.remove("hidden")

    this.nextButtonTarget.disabled = false
  }

  next() {
    this.formTarget.submit()
  }

  cancel() {
    history.back()
  }
}
