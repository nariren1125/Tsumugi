import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "draftForm", "discardForm", "personTagsHolder"]

  open() {
    this.modalTarget.classList.add("modal-open")
  }

  close() {
    this.modalTarget.classList.remove("modal-open")
  }

  discard() {
    if (!confirm("入力内容を破棄して戻りますか？")) return
    this.discardFormTarget.requestSubmit()
  }

  save() {
    if (!confirm("入力内容を下書きとして保存しますか？")) return

    // 画面上の入力値を拾って hidden に反映（重要：@post じゃなく「今入力中」を送る）
    const photoDate = document.querySelector('[name="post[photo_date]"]')?.value || ""
    const title     = document.querySelector('[name="post[title]"]')?.value || ""
    const content   = document.querySelector('[name="post[content]"]')?.value || ""

    this.draftFormTarget.querySelector('[name="post[photo_date]"]').value = photoDate
    this.draftFormTarget.querySelector('[name="post[title]"]').value = title
    this.draftFormTarget.querySelector('[name="post[content]"]').value = content

    // person_tag_ids を丸ごとコピー（post[person_tag_ids][]=... を全部移す）
    this.personTagsHolderTarget.innerHTML = ""
    const tagInputs = document.querySelectorAll('[name="post[person_tag_ids][]"]')
    tagInputs.forEach((input) => {
      if (!input.value) return
      const hidden = document.createElement("input")
      hidden.type = "hidden"
      hidden.name = "post[person_tag_ids][]"
      hidden.value = input.value
      this.personTagsHolderTarget.appendChild(hidden)
    })

    this.draftFormTarget.requestSubmit()
  }
}
