// 写真プレビューコントローラー
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "preview",
    "nextButton",
    "form",
    "formInput"
  ]

  // =========================
  // 写真選択を開く
  // =========================
  openPicker() {
    this.inputTarget.click()
  }

  // 写真が選択されたときの処理
  handleFiles() {
    const files = this.inputTarget.files
    if (!files || files.length === 0) return

    const file = files[0]

    // プレビュー表示
    this.previewTarget.src = URL.createObjectURL(file)
    this.previewTarget.classList.remove("hidden")

    // 次へボタン有効化
    this.nextButtonTarget.disabled = false
  }

  // =========================
  // 次へ
  // =========================
  next() {
    // 選択されたファイルを hidden form にコピー
    this.formInputTarget.files = this.inputTarget.files

    // confirm_photos に POST
    this.formTarget.submit()
  }

  // =========================
  // キャンセル
  // =========================
  cancel() {
    history.back()
  }
}
