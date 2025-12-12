import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('UserHistoryController connected')
    this.attachRemoveListeners()
  }

  attachRemoveListeners() {
    const removeButtons = document.querySelectorAll('.remove-button')
    console.log('Found remove buttons:', removeButtons.length)
    removeButtons.forEach(button => {
      button.addEventListener('click', (e) => this.removeRestaurant(e))
    })
  }

  async removeRestaurant(event) {
    console.log('Remove button clicked')
    const button = event.target.closest('.remove-button')
    const restaurantId = button.dataset.restaurantId
    const card = button.closest('.history-card')
    console.log('Restaurant ID:', restaurantId)

    if (!confirm('Are you sure you want to remove this restaurant from your history?')) {
      return
    }

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ""

      const response = await fetch(`/user_history/${restaurantId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        }
      })

      const data = await response.json()

      if (data.success) {
        card.style.animation = 'fadeOut 0.3s ease forwards'
        setTimeout(() => {
          card.remove()
          
          // Check if there are any cards left
          const remainingCards = document.querySelectorAll('.history-card')
          if (remainingCards.length === 0) {
            location.reload()
          }
        }, 300)
      } else {
        alert(data.error || 'Failed to remove restaurant')
      }
    } catch (error) {
      console.error('Error removing restaurant:', error)
      alert('An error occurred')
    }
  }
}

// Add animation styles
const style = document.createElement('style')
style.textContent = `
  @keyframes fadeOut {
    from {
      opacity: 1;
      transform: translateY(0);
    }
    to {
      opacity: 0;
      transform: translateY(-10px);
    }
  }
`
document.head.appendChild(style)
