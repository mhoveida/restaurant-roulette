import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  // Connects to data-dropdown-target="menu"
  static targets = [ "menu" ]

  // This is the function that runs on click
  toggle() {
    // This just toggles the "hidden" attribute on the menu
    this.menuTarget.hidden = !this.menuTarget.hidden
  }
}