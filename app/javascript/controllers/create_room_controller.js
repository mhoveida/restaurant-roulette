import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-room"
export default class extends Controller {
  static targets = [
    "ownerNameInput",
    "locationInput",
    "priceSelect",
    "cuisineInput",
    "cuisineTags",
    "createButton",
    "validationMessage",
    "suggestions"
  ]

  connect() {
    this.updateCuisineTags()
  }

  validateAndCreate(e) {
    e.preventDefault()

    if (!this.validateForm()) {
      this.showValidationMessage()
      return
    }

    this.hideValidationMessage()
    const form = e.target.closest("form")
    form.submit()
  }

  validateForm() {
    const ownerName = this.ownerNameInputTarget.value.trim()
    const location = this.locationInputTarget.value.trim()
    const price = this.priceSelectTarget.value
    const cuisines = this.cuisineInputTarget.value.trim()

    return ownerName && location && price && cuisines
  }

  showValidationMessage() {
    this.validationMessageTarget.style.display = "block"
  }

  hideValidationMessage() {
    this.validationMessageTarget.style.display = "none"
  }

  onLocationChange() {
    this.updateLocationSuggestions()
  }

  updateLocationSuggestions() {
    const input = this.locationInputTarget.value.trim()
    const suggestionsContainer = this.suggestionsTarget

    if (!input) {
      suggestionsContainer.style.display = "none"
      return
    }

    const allSuggestions = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Miami"]
    const filtered = allSuggestions.filter(s =>
      s.toLowerCase().includes(input.toLowerCase())
    )

    if (filtered.length === 0) {
      suggestionsContainer.style.display = "none"
      return
    }

    suggestionsContainer.innerHTML = filtered.map(suggestion =>
      `<div class="location-suggestion" data-location="${suggestion}">${suggestion}</div>`
    ).join("")

    suggestionsContainer.style.display = "block"

    suggestionsContainer.querySelectorAll(".location-suggestion").forEach(el => {
      el.addEventListener("click", (e) => {
        this.locationInputTarget.value = e.target.dataset.location
        suggestionsContainer.style.display = "none"
      })
    })
  }

  onCuisineChange() {
    this.updateCuisineTags()
  }

  updateCuisineTags() {
    const input = this.cuisineInputTarget.value
    const tagsContainer = this.cuisineTagsTarget

    if (!input.trim()) {
      tagsContainer.innerHTML = ""
      return
    }

    const cuisines = input.split(",").map(c => c.trim()).filter(c => c)
    const tagsHtml = cuisines.map((cuisine) =>
      `<span class="cuisine-tag">
        ${cuisine}
        <button type="button" class="remove-btn" data-cuisine="${cuisine}">×</button>
      </span>`
    ).join("")

    tagsContainer.innerHTML = tagsHtml

    tagsContainer.querySelectorAll(".remove-btn").forEach(btn => {
      btn.addEventListener("click", (e) => {
        e.preventDefault()
        const cuisineToRemove = btn.dataset.cuisine
        const updated = input
          .split(",")
          .map(c => c.trim())
          .filter(c => c !== cuisineToRemove)
          .join(", ")
        this.cuisineInputTarget.value = updated
        this.updateCuisineTags()
      })
    })
  }
}
