import { Controller } from "@hotwired/stimulus"

// data-controller="child-age"
export default class extends Controller {
  static targets = ["childSelect", "ageSelect", "childHidden", "ageHidden", "selectedLabel"]

  connect() {
    this.childSelectTarget.value = this.childHiddenTarget.value || ""
    this.ageSelectTarget.value = this.ageHiddenTarget.value || ""
    this.updateLabel()
  }

  open() {
    this.childSelectTarget.value = this.childHiddenTarget.value || ""
    this.ageSelectTarget.value = this.ageHiddenTarget.value || ""
  }

  apply() {
    this.childHiddenTarget.value = this.childSelectTarget.value || ""
    this.ageHiddenTarget.value = this.ageSelectTarget.value || ""
    this.updateLabel()
  }

  cancel() {
    this.childSelectTarget.value = this.childHiddenTarget.value || ""
    this.ageSelectTarget.value = this.ageHiddenTarget.value || ""
  }

  updateLabel() {
    const childId = this.childHiddenTarget.value
    const age = this.ageHiddenTarget.value

    this.selectedLabelTarget.innerHTML = ""

    // 未選択表示
    if (!childId || !age) {
      const span = document.createElement("span")
      span.className = "text-base-content/50"
      span.textContent = "まだ選択されていません"
      this.selectedLabelTarget.appendChild(span)
      return
    }

    // 子ども名＋色（optionのdata属性から取得）
    const opt = Array.from(this.childSelectTarget.options).find((o) => o.value === childId)
    const childName = opt ? opt.textContent : ""
    const color = opt?.dataset?.color || "" // 例: "#C07A5B" など

    const span = document.createElement("span")
    span.className = "text-sm font-medium"
    if (color) span.style.color = color

    // Tsumugiっぽい文言に
    span.textContent = `${childName}（${age}歳のころ）`

    this.selectedLabelTarget.appendChild(span)
  }
}
