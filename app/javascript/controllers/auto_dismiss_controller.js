
// 時間経過後に要素をフェードアウトして削除するStimulusコントローラー
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 3000 }
  }

  connect() {
    setTimeout(() => {
      this.element.classList.add("opacity-0")
      setTimeout(() => {
        this.element.remove()
      }, 500)
    }, this.timeoutValue)
  }
}
