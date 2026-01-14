import { Controller } from "@hotwired/stimulus"

// data-controller="person-tags"
export default class extends Controller {
  static targets = ["checkbox", "selectedList", "chip"]
  static values = { id: Number, name: String }

  connect() {
    // 編集画面など、既に選択済みのものがあればUIを初期化
    this.syncChipsFromCheckboxes()
    this.updateSelectedList()
  }

  // モーダル内のチップがクリックされたとき
  toggle(event) {
    const chip = event.currentTarget
    const id = chip.dataset.personTagsIdValue

    // 対応する hidden checkbox を探してON/OFF
    const checkbox = this.checkboxTargets.find(
      (cb) => cb.value === id
    )

    if (!checkbox) return

    checkbox.checked = !checkbox.checked

    // 見た目反映
    chip.classList.toggle("btn-outline", !checkbox.checked)
    chip.classList.toggle("btn-accent", checkbox.checked)
    chip.classList.toggle("text-base-100", checkbox.checked)

    this.updateSelectedList()
  }

  // 「完了する」押下時（今は表示更新だけだが、将来バリデーションなど足せる）
  apply() {
    this.updateSelectedList()
  }

  // hidden checkbox の状態から、チップの見た目を合わせる
  syncChipsFromCheckboxes() {
    this.chipTargets.forEach((chip) => {
      const id = chip.dataset.personTagsIdValue
      const checkbox = this.checkboxTargets.find(
        (cb) => cb.value === id
      )

      if (checkbox && checkbox.checked) {
        chip.classList.remove("btn-outline")
        chip.classList.add("btn-accent", "text-base-100")
      } else {
        chip.classList.add("btn-outline")
        chip.classList.remove("btn-accent", "text-base-100")
      }
    })
  }

  // フォーム側「選択された人」表示エリアを更新
  updateSelectedList() {
    const selected = this.checkboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => cb.dataset.name)

    this.selectedListTarget.innerHTML = ""

    if (selected.length === 0) {
      const span = document.createElement("span")
      span.className = "text-base-content/50"
      span.textContent = "まだ選択されていません"
      this.selectedListTarget.appendChild(span)
      return
    }

    selected.forEach((name) => {
      const tag = document.createElement("span")
      tag.className =
        "px-2 py-1 rounded-full bg-base-200 text-xs text-base-content"
      tag.textContent = name
      this.selectedListTarget.appendChild(tag)
    })
  }
}
