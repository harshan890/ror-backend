import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Harshan Ahmad is a good boy and live in Lahore"
  }
}
