import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    document.addEventListener("click", this.closeMenuOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.closeMenuOnOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.style.display = this.menuTarget.style.display === "block" ? "none" : "block"
  }

  closeMenuOnOutsideClick = (event) => {
    if (!this.element.contains(event.target)) {
      this.menuTarget.style.display = "none"
    }
  }
}