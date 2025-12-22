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
    const maxFiles = this.maxFilesValue
    const files = Array.from(this.inputTarget.files)
    if (files.length === 0) return

    // 超過分をカット（最初の5枚を固定）
    let trimmedFiles = files
    let droppedCount = 0

    if (files.length > maxFiles) {
      trimmedFiles = files.slice(0, maxFiles)
      droppedCount = files.length - maxFiles
    }

    const dt = new DataTransfer()
    trimmedFiles.forEach(file => dt.items.add(file))
    this.inputTarget.files = dt.files

    this.formTarget.querySelector(
      'input[name="dropped_files_count"]'
    ).value = droppedCount

    this.formTarget.submit()
  }
}
