import { Controller } from "@hotwired/stimulus"

// data-controller="child-age"
export default class extends Controller {
  static targets = ["childSelect", "ageSelect", "childHidden", "ageHidden", "selectedLabel"]
  static values = { agesByChild: Object }

  connect() {
    // hidden値（paramsの初期値）をselectへ反映
    this.childSelectTarget.value = this.childHiddenTarget.value || ""

    // 子どもに応じた年齢候補を先に作る
    this.refreshAgeOptions()

    // hiddenの年齢をselectに反映（候補に無ければ空へ）
    this.ageSelectTarget.value = this.ageHiddenTarget.value || ""
    if (!this.optionExists(this.ageSelectTarget, this.ageSelectTarget.value)) {
      this.ageSelectTarget.value = ""
      this.ageHiddenTarget.value = ""
    }

    this.updateLabel()
  }

  open() {
    // モーダルを開く直前に同期
    this.childSelectTarget.value = this.childHiddenTarget.value || ""
    this.refreshAgeOptions()

    this.ageSelectTarget.value = this.ageHiddenTarget.value || ""
    if (!this.optionExists(this.ageSelectTarget, this.ageSelectTarget.value)) {
      this.ageSelectTarget.value = ""
    }
  }

  // 子どもを変更したら、年齢候補を再生成して選択をクリア
  childChanged() {
    this.refreshAgeOptions()
    this.ageSelectTarget.value = ""
  }

  apply() {
    this.childHiddenTarget.value = this.childSelectTarget.value || ""
    this.ageHiddenTarget.value = this.ageSelectTarget.value || ""
    this.updateLabel()
  }

  cancel() {
    // hiddenは変えず、selectを戻す
    this.childSelectTarget.value = this.childHiddenTarget.value || ""
    this.refreshAgeOptions()

    this.ageSelectTarget.value = this.ageHiddenTarget.value || ""
    if (!this.optionExists(this.ageSelectTarget, this.ageSelectTarget.value)) {
      this.ageSelectTarget.value = ""
    }
  }

  // ===== 年齢候補を子どもに応じて作り直す =====
  refreshAgeOptions() {
    const childId = this.childSelectTarget.value
    const ages = (childId && this.agesByChildValue?.[childId]) ? this.agesByChildValue[childId] : []

    // selectを全消しして作り直す
    this.ageSelectTarget.innerHTML = ""

    // デフォルト
    const opt0 = document.createElement("option")
    opt0.value = ""
    opt0.textContent = "指定しない"
    this.ageSelectTarget.appendChild(opt0)

    // 実データに存在する年齢だけ追加
    ages.forEach((n) => {
      const opt = document.createElement("option")
      opt.value = String(n)
      opt.textContent = `${n}歳`
      this.ageSelectTarget.appendChild(opt)
    })
  }

  optionExists(selectEl, value) {
    return Array.from(selectEl.options).some((o) => o.value === value)
  }

  updateLabel() {
    const childId = this.childHiddenTarget.value
    const age = this.ageHiddenTarget.value

    this.selectedLabelTarget.innerHTML = ""

    if (!childId || !age) {
      const span = document.createElement("span")
      span.className = "text-base-content/50"
      span.textContent = "まだ選択されていません"
      this.selectedLabelTarget.appendChild(span)
      return
    }

    const opt = Array.from(this.childSelectTarget.options).find((o) => o.value === childId)
    const childName = opt ? opt.textContent : ""

    // Tsumugiっぽい「色文字＋文章」
    const span = document.createElement("span")
    span.className = "text-sm font-medium text-accent"
    span.textContent = `${childName}（${age}歳のころ）`

    this.selectedLabelTarget.appendChild(span)
  }
}
