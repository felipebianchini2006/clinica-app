import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 0 } }

  connect() {
    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.delayValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-[-10px]", "transition-all", "duration-300")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
