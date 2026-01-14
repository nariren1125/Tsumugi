import { Controller } from "@hotwired/stimulus"

// data-controller="person-tags"
export default class extends Controller {
  static targets = ["checkbox", "selectedList", "chip"]

  connect() {
    console.log("✅ person-tags controller connected")
    this.syncChipsFromCheckboxes()
    this.updateSelectedList()
  }

  // モーダル内の名前ボタンが押されたとき
  toggle(event) {
    const chip = event.currentTarget
    const id = chip.dataset.personTagsIdValue   // ★ HTMLと合わせる

    const checkbox = this.checkboxTargets.find((cb) => cb.value === id)
    if (!checkbox) return

    checkbox.checked = !checkbox.checked
    this.updateChipStyle(chip, checkbox.checked)
    this.updateSelectedList()
  }

  // 「完了する」押下時
  apply() {
    this.updateSelectedList()
  }

  // 既にチェック済みのものがあればUIを同期
  syncChipsFromCheckboxes() {
    this.chipTargets.forEach((chip) => {
      const id = chip.dataset.personTagsIdValue
      const checkbox = this.checkboxTargets.find((cb) => cb.value === id)
      const checked = checkbox && checkbox.checked
      this.updateChipStyle(chip, checked)
    })
  }

  updateChipStyle(chip, checked) {
    if (checked) {
      chip.classList.remove("btn-outline")
      chip.classList.add("btn-accent", "text-base-100")
    } else {
      chip.classList.add("btn-outline")
      chip.classList.remove("btn-accent", "text-base-100")
    }
  }

  updateSelectedList() {
    const selectedNames = this.checkboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => cb.dataset.name)

    this.selectedListTarget.innerHTML = ""

    if (selectedNames.length === 0) {
      const span = document.createElement("span")
      span.className = "text-base-content/50"
      span.textContent = "まだ選択されていません"
      this.selectedListTarget.appendChild(span)
      return
    }

    selectedNames.forEach((name) => {
      const tag = document.createElement("span")
      tag.className =
        "px-2 py-1 rounded-full bg-base-200 text-xs text-base-content"
      tag.textContent = name
      this.selectedListTarget.appendChild(tag)
    })
  }
}
