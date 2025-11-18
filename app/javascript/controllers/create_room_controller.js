import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "ownerNameInput",
    "locationSelect",
    "priceSelect",
    "cuisinesGrid",
    "categoriesInput",
    "createButton",
    "validationMessage"
  ]

  connect() {
    this.selectedCuisines = []
    this.fetchNeighborhoods()
    this.fetchCuisines()
  }

  async fetchNeighborhoods() {
    try {
      const response = await fetch('/neighborhoods')
      const neighborhoods = await response.json()
      
      // Populate the location dropdown
      const select = this.locationSelectTarget
      select.innerHTML = '<option value="">Select a neighborhood</option>'
      
      neighborhoods.forEach(neighborhood => {
        const option = document.createElement('option')
        option.value = neighborhood
        option.textContent = neighborhood
        select.appendChild(option)
      })
    } catch (error) {
      console.error('Error fetching neighborhoods:', error)
    }
  }

  async fetchCuisines() {
    try {
      const response = await fetch('/cuisines')
      const cuisines = await response.json()
      
      // Create checkbox grid
      const grid = this.cuisinesGridTarget
      grid.innerHTML = cuisines.map(cuisine => `
        <label class="cuisine-checkbox">
          <input type="checkbox" value="${cuisine}" data-action="change->create-room#toggleCuisine">
          <span class="cuisine-label">${cuisine}</span>
        </label>
      `).join('')
    } catch (error) {
      console.error('Error fetching cuisines:', error)
      // Fallback cuisines - UPDATED to match simplified list
      const fallbackCuisines = [
        "American", "Chinese", "French", "Indian", "Italian",
        "Japanese", "Korean", "Mediterranean", "Mexican", "Thai"
      ]
      const grid = this.cuisinesGridTarget
      grid.innerHTML = fallbackCuisines.map(cuisine => `
        <label class="cuisine-checkbox">
          <input type="checkbox" value="${cuisine}" data-action="change->create-room#toggleCuisine">
          <span class="cuisine-label">${cuisine}</span>
        </label>
      `).join('')
    }
  }

  toggleCuisine(event) {
    const checkbox = event.target
    const cuisine = checkbox.value
    
    if (checkbox.checked) {
      if (!this.selectedCuisines.includes(cuisine)) {
        this.selectedCuisines.push(cuisine)
      }
    } else {
      this.selectedCuisines = this.selectedCuisines.filter(c => c !== cuisine)
    }
    
    // Update hidden input
    this.categoriesInputTarget.value = this.selectedCuisines.join(',')
    
    // Visual feedback
    checkbox.closest('.cuisine-checkbox').classList.toggle('selected', checkbox.checked)
  }

  validateAndCreate(e) {
    e.preventDefault()

    if (!this.validateForm()) {
      this.showValidationMessage()
      return
    }

    this.hideValidationMessage()
    const form = this.createButtonTarget.closest("form")
    form.submit()
  }

  validateForm() {
    const name = this.ownerNameInputTarget.value.trim()
    const location = this.locationSelectTarget.value
    const price = this.priceSelectTarget.value
    const cuisines = this.selectedCuisines.length > 0

    console.log('Validation:', { name, location, price, cuisines: this.selectedCuisines })
    return name && location && price && cuisines
  }

  showValidationMessage() {
    this.validationMessageTarget.style.display = "block"
    this.validationMessageTarget.textContent = "Please fill in all fields and select at least one cuisine"
  }

  hideValidationMessage() {
    this.validationMessageTarget.style.display = "none"
  }

  onSubmit(e) {
    if (!this.validateForm()) {
      e.preventDefault()
      this.showValidationMessage()
    }
  }
}