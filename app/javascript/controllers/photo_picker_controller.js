// 写真選択コントローラー
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "form"]
  static values = { maxFiles: { type: Number, default: 5 } }

  connect() {
    console.log("photo-picker connected")
  }

  openPicker() {
    if (!this.hasInputTarget) return
    this.inputTarget.click()
  }

  async handleFiles() {
    const maxFiles = this.maxFilesValue
    const files = Array.from(this.inputTarget.files || [])
    if (files.length === 0) return

    // 超過分をカット（最初の maxFiles 枚を固定）
    let trimmedFiles = files
    let droppedCount = 0

    if (files.length > maxFiles) {
      trimmedFiles = files.slice(0, maxFiles)
      droppedCount = files.length - maxFiles
    }

    // dropped_files_count を更新
    const droppedInput = this.formTarget.querySelector('input[name="dropped_files_count"]')
    if (droppedInput) droppedInput.value = droppedCount

    console.log(`Selected ${trimmedFiles.length} file(s). Starting manual direct uploads...`)

    try {
      // ✅ 手動で direct upload → signed_id を hidden inputs に詰める
      await this.uploadAll(trimmedFiles)

      console.log("All uploads finished. Submitting form...")
      this.formTarget.requestSubmit()
    } catch (e) {
      console.error(e)
      alert("アップロードに失敗しました。通信状況をご確認ください。")
    }
  }

  uploadAll(files) {
    const url = this.inputTarget.getAttribute("data-direct-upload-url")
    if (!url) throw new Error("data-direct-upload-url is missing on file input")

    // 既存の hidden signed_id をクリア（再選択時の事故防止）
    this.formTarget.querySelectorAll('input[type="hidden"][data-direct-upload-hidden="true"]').forEach((el) => el.remove())

    // ファイルinputは送信しない（2重送信防止）
    // ※confirm側では signed_id を受け取る想定
    this.inputTarget.disabled = true

    // すべてアップロード（並列）
    return Promise.all(files.map((file) => this.uploadOne(file, url)))
  }

  uploadOne(file, url) {
    return new Promise((resolve, reject) => {
      const upload = new DirectUpload(file, url)

      upload.create((error, blob) => {
        if (error) {
          reject(error)
          return
        }

        // ✅ 元の input name で signed_id を送る
        const hiddenField = document.createElement("input")
        hiddenField.type = "hidden"
        hiddenField.name = this.inputTarget.name
        hiddenField.value = blob.signed_id
        hiddenField.setAttribute("data-direct-upload-hidden", "true")

        this.formTarget.appendChild(hiddenField)
        resolve(blob)
      })
    })
  }
}
