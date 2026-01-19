import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    const postForm = document.getElementById("post-form")
    const draftForm = document.getElementById("draft-form")
    if (!postForm || !draftForm) return

    // 値をコピー
    const copy = (name, targetId) => {
      const src = postForm.querySelector(`[name="${name}"]`)
      const dst = document.getElementById(targetId)
      if (src && dst) dst.value = src.value
    }

    copy("post[photo_date]", "draft_photo_date")
    copy("post[title]", "draft_title")
    copy("post[content]", "draft_content")

    // person_tag_ids を hidden として詰める
    const holder = document.getElementById("draft_person_tags")
    holder.innerHTML = ""

    postForm
      .querySelectorAll(`input[name="post[person_tag_ids][]"]:checked`)
      .forEach((el) => {
        const hidden = document.createElement("input")
        hidden.type = "hidden"
        hidden.name = "post[person_tag_ids][]"
        hidden.value = el.value
        holder.appendChild(hidden)
      })

    draftForm.requestSubmit()
  }
}
