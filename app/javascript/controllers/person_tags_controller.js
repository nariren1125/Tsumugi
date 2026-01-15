import { Controller } from "@hotwired/stimulus"

// data-controller="person-tags"
export default class extends Controller {
  static targets = ["checkbox", "selectedList", "chip"]

  connect() {
    console.log("✅ person-tags controller connected")

    // 「確定済み」= hidden checkbox の状態
    this.committedIds = new Set(this.checkedIdsFromCheckboxes())
    // 「下書き」= モーダル内で一時的に選ぶ状態
    this.draftIds = new Set(this.committedIds)

    // 初期UI
    this.syncChipsFromIdSet(this.committedIds)
    this.updateSelectedListFromIdSet(this.committedIds)
  }

  // ===== モーダルを開くときに呼ぶ（推奨） =====
  // data-action="click->person-tags#open" を「選択する」ボタン等に付ける
  open() {
    this.committedIds = new Set(this.checkedIdsFromCheckboxes())
    this.draftIds = new Set(this.committedIds)
    this.syncChipsFromIdSet(this.draftIds)
  }

  // モーダル内の名前ボタンが押されたとき（下書きだけ更新）
  // data-action="click->person-tags#toggle"
  toggle(event) {
    event.preventDefault()

    const chip = event.currentTarget
    const id = String(chip.dataset.personTagsIdValue || "")
    if (!id) return

    if (this.draftIds.has(id)) {
      this.draftIds.delete(id)
      this.updateChipStyle(chip, false)
    } else {
      this.draftIds.add(id)
      this.updateChipStyle(chip, true)
    }

    // ★ここが重要：フォーム（checkbox/selectedList）は更新しない
  }

  // 「完了する」押下時（ここで初めてフォームに反映）
  // data-action="click->person-tags#apply"
  apply() {
    this.committedIds = new Set(this.draftIds)
    this.applyIdSetToCheckboxes(this.committedIds)
    this.updateSelectedListFromIdSet(this.committedIds)
    // closeModal() は不要（labelが閉じる）
  }

  // 「キャンセル」押下時（確定済みに戻す）
  // data-action="click->person-tags#cancel"
  cancel() {
    this.draftIds = new Set(this.committedIds)
    this.syncChipsFromIdSet(this.committedIds)
    // closeModal() は不要（labelが閉じる）
  }

  // ===== 内部処理 =====
  checkedIdsFromCheckboxes() {
    return this.checkboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => String(cb.value))
  }

  applyIdSetToCheckboxes(idSet) {
    this.checkboxTargets.forEach((cb) => {
      cb.checked = idSet.has(String(cb.value))
    })
  }

  // 既にチェック済みのものがあればUIを同期（※Set版）
  syncChipsFromIdSet(idSet) {
    this.chipTargets.forEach((chip) => {
      const id = String(chip.dataset.personTagsIdValue || "")
      this.updateChipStyle(chip, idSet.has(id))
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

  // フォーム側の表示（selectedList）は committed だけを表示する
  updateSelectedListFromIdSet(idSet) {
    const selectedNames = this.checkboxTargets
      .filter((cb) => idSet.has(String(cb.value)))
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
      tag.className = "px-2 py-1 rounded-full bg-base-200 text-xs text-base-content"
      tag.textContent = name
      this.selectedListTarget.appendChild(tag)
    })
  }

  // 既存互換（connectから呼んでいる場合のため残すなら）
  syncChipsFromCheckboxes() {
    this.syncChipsFromIdSet(new Set(this.checkedIdsFromCheckboxes()))
  }

  updateSelectedList() {
    this.updateSelectedListFromIdSet(new Set(this.checkedIdsFromCheckboxes()))
  }
}
