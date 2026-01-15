
// app/javascript/controllers/search_reset_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reset() {
    console.log("✅ search-reset fired")

    // 1) 年（select）を空にする + 有効化
    const year = this.element.querySelector('select[name="year"]')
    if (year) {
      year.value = ""
      year.disabled = false
      year.dispatchEvent(new Event("change", { bubbles: true }))
    }

    // 2) child-age をクリア（存在すれば clear() を呼ぶ）
    this.callControllerMethod('child-age', 'clear')

    // 3) person-tags をクリア（存在すれば clear() を呼ぶ）
    this.callControllerMethod('person-tags', 'clear')

    // 4) サマリなどを即時更新したい場合はイベント（任意）
    document.dispatchEvent(new CustomEvent("search:reset"))
  }

  callControllerMethod(identifier, methodName) {
    const el = this.element.querySelector(`[data-controller~="${identifier}"]`)
    if (!el) return

    const controller = this.application.getControllerForElementAndIdentifier(el, identifier)
    if (controller && typeof controller[methodName] === "function") {
      controller[methodName]()
    }
  }
}
