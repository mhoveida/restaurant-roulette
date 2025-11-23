import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "nameInput",
    "locationSelect",
    "priceSelect",
    "cuisinesGrid",
    "categoriesInput",
    "wheel",
    "spinButton",
    "validationMessage"
  ]

  connect() {
    this.selectedCuisines = []
    this.currentRestaurant = null
    this.fetchNeighborhoods()
    this.fetchCuisines()
    this.drawWheel()
  }

  async fetchNeighborhoods() {
    try {
      const response = await fetch('/neighborhoods')
      const neighborhoods = await response.json()
      
      const select = this.locationSelectTarget
      select.innerHTML = '<option value="">Select a neighborhood</option>'
      
      neighborhoods.forEach(neighborhood => {
        const option = document.createElement('option')
        option.value = neighborhood
        option.textContent = neighborhood
        select.appendChild(option)
      })
    } catch (error) {
      /*console.error('Error fetching neighborhoods:', error)*/
      const fallbackNeighborhoods = [
        "Astoria", "DUMBO", "East Village", "Lower East Side", 
        "Midtown", "Park Slope", "SoHo", "Upper East Side", 
        "West Village", "Williamsburg"
      ]
      const select = this.locationSelectTarget
      select.innerHTML = '<option value="">Select a neighborhood</option>'
      fallbackNeighborhoods.forEach(neighborhood => {
        const option = document.createElement('option')
        option.value = neighborhood
        option.textContent = neighborhood
        select.appendChild(option)
      })
    }
  }

  async fetchCuisines() {
    try {
      const response = await fetch('/cuisines')
      const cuisines = await response.json()
      
      const grid = this.cuisinesGridTarget
      grid.innerHTML = cuisines.map(cuisine => `
        <label class="cuisine-checkbox">
          <input type="checkbox" value="${cuisine}" data-action="change->solo-spin#toggleCuisine">
          <span class="cuisine-label">${cuisine}</span>
        </label>
      `).join('')
    } catch (error) {
      /*console.error('Error fetching cuisines:', error)*/
      const fallbackCuisines = [
        "American", "Chinese", "French", "Indian", "Italian",
        "Japanese", "Korean", "Mediterranean", "Mexican", "Thai"
      ]
      const grid = this.cuisinesGridTarget
      grid.innerHTML = fallbackCuisines.map(cuisine => `
        <label class="cuisine-checkbox">
          <input type="checkbox" value="${cuisine}" data-action="change->solo-spin#toggleCuisine">
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
    
    this.categoriesInputTarget.value = this.selectedCuisines.join(',')
    checkbox.closest('.cuisine-checkbox').classList.toggle('selected', checkbox.checked)
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

    ctx.beginPath()
    ctx.moveTo(radius, 0)
    ctx.lineTo(radius - 10, 20)
    ctx.lineTo(radius + 10, 20)
    ctx.closePath()
    ctx.fillStyle = "#FEE440"
    ctx.fill()
  }

  async spin(event) {
    event.preventDefault()
    
    if (!this.validateForm()) {
      this.showValidationMessage()
      return
    }
    
    this.hideValidationMessage()
    
    const location = this.locationSelectTarget.value
    const price = this.priceSelectTarget.value
    const categories = this.selectedCuisines
    
    // Show spinning animation
    this.wheelTarget.classList.add('spinning')
    this.spinButtonTarget.disabled = true
    
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ""

      const response = await fetch('/solo_spin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({
          location: location,
          price: price,
          categories: categories
        })
      })
      
      const data = await response.json()
      
      // Wait for spin animation
      setTimeout(() => {
        this.wheelTarget.classList.remove('spinning')
        this.spinButtonTarget.disabled = false
        
        if (data.success) {
          this.showResult(data.restaurant, data.match_type)
        } else {
          alert(data.error || 'No restaurant found')
        }
      }, 2000 + Math.random() * 1000)
      
    } catch (error) {
      console.error('Spin error:', error)
      // We can revert to the simple alert now that we know the issue
      alert('An error occurred') 
      this.wheelTarget.classList.remove('spinning')
      this.spinButtonTarget.disabled = false
    }
  }

  validateForm() {
    const name = this.nameInputTarget.value.trim()
    const location = this.locationSelectTarget.value
    const price = this.priceSelectTarget.value
    const cuisines = this.selectedCuisines.length > 0
    
    return name && location && price && cuisines
  }

  showValidationMessage() {
    this.validationMessageTarget.style.display = "block"
    this.validationMessageTarget.textContent = "Please fill in all fields and select at least one cuisine"

  }

  hideValidationMessage() {
    this.validationMessageTarget.style.display = "none"
  }

  showResult(restaurant, matchType) {
    this.currentRestaurant = restaurant
    
    const stars = '★'.repeat(Math.floor(restaurant.rating)) + '☆'.repeat(5 - Math.floor(restaurant.rating))
    
    const resultHTML = `
      <div class="result-overlay" id="soloResult">
        <div class="result-modal">
          <button class="close-button" id="closeResultBtn">×</button>
          
          <div class="result-header">
            <h3>🎉 You should try:</h3>
          </div>

          <div class="restaurant-result">
            ${restaurant.image_url ? `
              <div class="restaurant-image">
                <img src="${restaurant.image_url}" alt="${restaurant.name}">
              </div>
            ` : ''}

            <h2 class="restaurant-name">${restaurant.name}</h2>

            <div class="restaurant-rating">
              <span class="stars">${stars}</span>
              <span class="rating-value">(${restaurant.rating})</span>
            </div>

            <div class="restaurant-meta">
              <span class="price">${restaurant.price}</span>
              ${restaurant.categories ? `
                <div class="cuisine-list">
                  ${restaurant.categories.map(cat => `<span class="cuisine-tag">${cat}</span>`).join('')}
                </div>
              ` : ''}
            </div>

            <div class="restaurant-address">
              <span class="address-icon">📍</span>
              ${restaurant.address}
            </div>
            
            <div style="text-align: center; margin-top: 0.5rem; color: rgba(255,255,255,0.6); font-size: 0.9rem;">
              ${restaurant.neighborhood}
            </div>

            ${matchType && matchType !== 'exact' ? `
              <div style="color: rgba(255, 255, 255, 0.5); font-size: 0.85rem; margin-top: 1rem; text-align: center; font-style: italic;">
                ${this.getMatchTypeText(matchType)}
              </div>
            ` : ''}
          </div>

          <div class="result-actions">
            <a href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(restaurant.address)}" 
               target="_blank"
               class="button spin-again-button">
              🗺️ View on Map
            </a>
            <button class="button share-button" id="shareResultBtn">
              Share
            </button>
          </div>
        </div>
      </div>
    `
    
    document.body.insertAdjacentHTML('beforeend', resultHTML)
    
    // Add event listeners
    document.getElementById('closeResultBtn').addEventListener('click', () => {
      document.getElementById('soloResult').remove()
    })
    
    document.getElementById('shareResultBtn').addEventListener('click', () => {
      this.shareResult()
    })
  }

  shareResult() {
    const restaurant = this.currentRestaurant
    if (!restaurant) return
    
    const shareText = `Check out ${restaurant.name}! 📍 ${restaurant.address}`
    
    if (navigator.share) {
      navigator.share({
        title: 'Restaurant Roulette',
        text: shareText
      }).catch(() => {})
    } else {
      navigator.clipboard.writeText(shareText).then(() => {
        const btn = document.getElementById('shareResultBtn')
        const originalText = btn.textContent
        btn.textContent = '✓ Copied!'
        btn.style.backgroundColor = '#22c55e'
        
        setTimeout(() => {
          btn.textContent = originalText
          btn.style.backgroundColor = ''
        }, 2000)
      }).catch(() => {
        alert('Could not copy to clipboard')
      })
    }
  }

  getMatchTypeText(matchType) {
    const texts = {
      'location_price': '📍 Same area & price (different cuisine)',
      'location_cuisine': '📍 Same area & cuisine (different price)',
      'location_only': '📍 Same area only',
      'price_cuisine': '🍽️ Same cuisine & price (different area)',
      'cuisine_only': '🍽️ Same cuisine only',
      'price_only': '💰 Same price only',
      'random': '🎲 Random pick'
    }
    return texts[matchType] || ''
  }
}