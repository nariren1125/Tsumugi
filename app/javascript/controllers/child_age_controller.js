
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modalChild", "modalAge", "hiddenChild", "hiddenAge", "preview"]
  static values = { children: Object }

  connect() {
    this.syncPreviewFromHidden()
  
    this._onReset = () => this.clear()
    document.addEventListener("search:reset", this._onReset)
  }
  
  disconnect() {
    document.removeEventListener("search:reset", this._onReset)
  }

  apply() {
    console.log("✅ child-age apply fired")

    // モーダルの選択値を hidden（送信用）へ反映
    this.hiddenChildTarget.value = this.modalChildTarget.value
    this.hiddenAgeTarget.value = this.modalAgeTarget.value

    // プレビュー更新
    this.syncPreviewFromHidden()

    // モーダルを閉じる
    const toggle = document.getElementById("child-age-modal")
    if (toggle) toggle.checked = false
  }

  clear() {
    this.hiddenChildTarget.value = ""
    this.hiddenAgeTarget.value = ""
    this.syncPreviewFromHidden()
  }  

  syncPreviewFromHidden() {
    const childId = this.hiddenChildTarget.value
    const age = this.hiddenAgeTarget.value

    if (childId && age !== "") {
      const name = this.childrenValue?.[childId] || "子ども"
      this.previewTarget.textContent = `${name} / ${age}歳`
      this.previewTarget.classList.remove("text-base-content/50")
    } else {
      this.previewTarget.textContent = "未選択"
      this.previewTarget.classList.add("text-base-content/50")
    }
  }
}
