// 写真選択コントローラー
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    console.log("photo-picker connected")
  }

  openPicker() {
    if (!this.hasInputTarget) return
    this.inputTarget.click()
  }

  handleFiles() {
    const files = this.inputTarget.files
    if (!files || files.length === 0) return

    // ✅ 写真が選ばれたら即 confirm へ
    this.formTarget.submit()
  }

}
