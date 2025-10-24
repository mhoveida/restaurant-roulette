import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="solo-spin"
export default class extends Controller {
  static targets = [
    "nameInput",
    "locationInput",
    "priceSelect",
    "cuisineInput",
    "cuisineTags",
    "wheel",
    "spinButton",
    "validationMessage",
    "suggestions"
  ]

  connect() {
    this.drawWheel()
    this.updateCuisineTags()
  }

  drawWheel() {
    const canvas = this.wheelTarget
    const ctx = canvas.getContext("2d")
    const radius = canvas.width / 2
    const colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F"]

    const slices = 6
    const sliceAngle = (Math.PI * 2) / slices

    ctx.clearRect(0, 0, canvas.width, canvas.height)

    for (let i = 0; i < slices; i++) {
      ctx.beginPath()
      ctx.arc(radius, radius, radius * 0.8, i * sliceAngle, (i + 1) * sliceAngle)
      ctx.lineTo(radius, radius)
      ctx.closePath()
      ctx.fillStyle = colors[i]
      ctx.fill()
      ctx.strokeStyle = "#2B2B2B"
      ctx.lineWidth = 2
      ctx.stroke()
    }

    ctx.beginPath()
    ctx.arc(radius, radius, radius * 0.15, 0, Math.PI * 2)
    ctx.fillStyle = "#FEE440"
    ctx.fill()
    ctx.strokeStyle = "#2B2B2B"
    ctx.lineWidth = 2
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(radius, 0)
    ctx.lineTo(radius - 10, 20)
    ctx.lineTo(radius + 10, 20)
    ctx.closePath()
    ctx.fillStyle = "#FEE440"
    ctx.fill()
  }

  validateAndSpin(e) {
    e.preventDefault()

    if (!this.validateForm()) {
      this.showValidationMessage()
      return
    }

    this.hideValidationMessage()
    this.spinWheel()
  }

  validateForm() {
    const name = this.nameInputTarget.value.trim()
    const location = this.locationInputTarget.value.trim()
    const price = this.priceSelectTarget.value
    const cuisines = this.cuisineInputTarget.value.trim()

    return name && location && price && cuisines
  }

  showValidationMessage() {
    this.validationMessageTarget.style.display = "block"
  }

  hideValidationMessage() {
    this.validationMessageTarget.style.display = "none"
  }

  spinWheel() {
    const wheel = this.wheelTarget
    const button = this.spinButtonTarget

    button.disabled = true
    wheel.classList.add("spinning")

    const spinDuration = 2000 + Math.random() * 1000

    setTimeout(() => {
      wheel.classList.remove("spinning")
      button.disabled = false

      const form = button.closest("form")
      form.submit()
    }, spinDuration)
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
