import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "ownerNameInput",
    "locationSelect",
    "priceSelect",
    "cuisinesGrid",
    "categoriesInput",
    "dietaryRestrictionsGrid",
    "dietaryRestrictionsInput", 
    "createButton",
    "validationMessage"
  ]

  connect() {
    this.selectedCuisines = []
    this.selectedDietaryRestrictions = []
    this.fetchNeighborhoods()
    this.fetchCuisines()
    this.fetchDietaryRestrictions()
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

  async fetchDietaryRestrictions() {
    try {
      const response = await fetch('/dietary_restrictions')
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const restrictions = await response.json()
      
      // Create checkbox grid
      const grid = this.dietaryRestrictionsGridTarget
      const html = restrictions.map(restriction => `
        <label class="cuisine-checkbox">
          <input type="checkbox" value="${restriction}" data-action="change->create-room#toggleDietaryRestriction">
          <span class="cuisine-label">${restriction}</span>
        </label>
      `).join('')
      
      grid.innerHTML = html
    } catch (error) {
      console.error('Error fetching dietary restrictions:', error)
      
      try {
        // Fallback options
        const fallbackRestrictions = [
          "Vegetarian", "Vegan", "Gluten-Free", "Halal", "Kosher", "No Restriction"
        ]
        const grid = this.dietaryRestrictionsGridTarget
        
        if (!grid) {
          console.error('dietaryRestrictionsGridTarget is undefined in fallback!')
          return
        }
        
        const html = fallbackRestrictions.map(restriction => `
          <label class="cuisine-checkbox">
            <input type="checkbox" value="${restriction}" data-action="change->create-room#toggleDietaryRestriction">
            <span class="cuisine-label">${restriction}</span>
          </label>
        `).join('')
        
        grid.innerHTML = html
      } catch (fallbackError) {
        console.error('Error in fallback:', fallbackError)
      }
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

  toggleDietaryRestriction(event) {
    const checkbox = event.target
    const restriction = checkbox.value
    
    // Special handling for "No Restriction"
    if (restriction === "No Restriction") {
      if (checkbox.checked) {
        // Uncheck all other dietary options
        this.dietaryRestrictionsGridTarget.querySelectorAll('input[type="checkbox"]').forEach(cb => {
          if (cb.value !== "No Restriction" && cb.checked) {
            cb.checked = false
            cb.closest('.cuisine-checkbox').classList.remove('selected')
          }
        })
        this.selectedDietaryRestrictions = ["No Restriction"]
      } else {
        this.selectedDietaryRestrictions = []
      }
    } else {
      // Regular dietary option selected - uncheck "No Restriction"
      const noRestrictionCheckbox = this.dietaryRestrictionsGridTarget.querySelector('input[value="No Restriction"]')
      if (noRestrictionCheckbox && noRestrictionCheckbox.checked) {
        noRestrictionCheckbox.checked = false
        noRestrictionCheckbox.closest('.cuisine-checkbox').classList.remove('selected')
      }
      
      if (checkbox.checked) {
        if (!this.selectedDietaryRestrictions.includes(restriction)) {
          this.selectedDietaryRestrictions.push(restriction)
        }
        // Remove "No Restriction" if it was there
        this.selectedDietaryRestrictions = this.selectedDietaryRestrictions.filter(r => r !== "No Restriction")
      } else {
        this.selectedDietaryRestrictions = this.selectedDietaryRestrictions.filter(r => r !== restriction)
      }
    }
    
    // Update hidden input
    this.dietaryRestrictionsInputTarget.value = this.selectedDietaryRestrictions.join(',')
    
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
    const dietary = this.selectedDietaryRestrictions.length > 0

    console.log('Validation:', { name, location, price, cuisines: this.selectedCuisines, dietary: this.selectedDietaryRestrictions })
    return name && location && price && cuisines && dietary
  }

  showValidationMessage() {
    this.validationMessageTarget.style.display = "block"
    this.validationMessageTarget.textContent = "Please fill in all fields, select at least one cuisine, and select at least one dietary option"
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