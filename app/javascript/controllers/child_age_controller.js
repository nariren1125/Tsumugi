import { Controller } from "@hotwired/stimulus"

// data-controller="child-age"
export default class extends Controller {
  static targets = ["childSelect", "ageSelect"]
  static values = { agesByChild: Object }

  // ====== form側（index）の要素を id で取得 ======
  get childHiddenEl() {
    return document.getElementById("child-age-child-hidden")
  }

  get ageHiddenEl() {
    return document.getElementById("child-age-age-hidden")
  }

  get labelEl() {
    return document.getElementById("child-age-selected-label")
  }

  connect() {
    // モーダルが描画されていないケースの保険
    if (!this.hasChildSelectTarget || !this.hasAgeSelectTarget) return

    // フォーム側(hidden)の値をモーダルのselectへ反映
    const childId = this.childHiddenEl?.value || ""
    const age = this.ageHiddenEl?.value || ""

    this.childSelectTarget.value = childId
    this.refreshAgeOptions()

    this.ageSelectTarget.value = age
    if (!this.optionExists(this.ageSelectTarget, this.ageSelectTarget.value)) {
      this.ageSelectTarget.value = ""
    }

    // フォーム側の表示を初期化（ページ戻り/GETパラメータでも表示を合わせる）
    this.updateLabelFromHidden()
  }

  // 「選択する」押下時（モーダルを開く前に同期）
  open() {
    const childId = this.childHiddenEl?.value || ""
    const age = this.ageHiddenEl?.value || ""

    this.childSelectTarget.value = childId
    this.refreshAgeOptions()

    this.ageSelectTarget.value = age
    if (!this.optionExists(this.ageSelectTarget, this.ageSelectTarget.value)) {
      this.ageSelectTarget.value = ""
    }
  }

  // 子ども変更で年齢候補を作り直し、年齢選択は一旦クリア
  childChanged() {
    this.refreshAgeOptions()
    this.ageSelectTarget.value = ""
  }

  // 「完了する」押下：フォーム(hidden)と表示を更新
  apply() {
    const childId = this.childSelectTarget.value || ""
    const age = this.ageSelectTarget.value || ""

    if (this.childHiddenEl) this.childHiddenEl.value = childId
    if (this.ageHiddenEl) this.ageHiddenEl.value = age

    this.updateLabel(childId, age)
  }

  // 「キャンセル」押下：何も保存しない（閉じるだけ）
  cancel() {
    // 何もしないのが一番安全
    // （hiddenを書き換えない＝フォーム状態は維持される）
  }

  // ===== 年齢候補を子どもに応じて作り直す =====
  refreshAgeOptions() {
    const childId = this.childSelectTarget.value
    const ages =
      childId && this.agesByChildValue?.[childId]
        ? this.agesByChildValue[childId]
        : []

    this.ageSelectTarget.innerHTML = ""

    // デフォルト
    const opt0 = document.createElement("option")
    opt0.value = ""
    opt0.textContent = "指定しない"
    this.ageSelectTarget.appendChild(opt0)

    // 実データにある年齢だけ
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

  // フォーム(hidden)から表示を更新（ページ初期表示用）
  updateLabelFromHidden() {
    const childId = this.childHiddenEl?.value || ""
    const age = this.ageHiddenEl?.value || ""
    this.updateLabel(childId, age)
  }

  // 表示更新本体
  updateLabel(childId, age) {
    const label = this.labelEl
    if (!label) return

    label.innerHTML = ""

    if (!childId || !age) {
      const span = document.createElement("span")
      span.className = "text-base-content/50"
      span.textContent = "まだ選択されていません"
      label.appendChild(span)
      return
    }

    const opt = Array.from(this.childSelectTarget.options).find(
      (o) => o.value === childId
    )
    const childName = opt ? opt.textContent : ""

    const span = document.createElement("span")
    span.className = "text-sm font-medium text-accent"
    span.textContent = `${childName}（${age}歳のころ）`

    label.appendChild(span)
  }
}
