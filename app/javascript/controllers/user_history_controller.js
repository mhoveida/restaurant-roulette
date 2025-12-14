import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('UserHistoryController connected')
    this.attachRemoveListeners()
    this.createModalHTML()
  }

  attachRemoveListeners() {
    const removeButtons = document.querySelectorAll('.remove-button')
    console.log('Found remove buttons:', removeButtons.length)
    removeButtons.forEach(button => {
      button.addEventListener('click', (e) => this.showConfirmModal(e))
    })
  }

  createModalHTML() {
    // Only create if it doesn't exist
    if (document.getElementById('deleteConfirmModal')) return;

    const modalHTML = `
      <div id="deleteConfirmModal" class="delete-modal-overlay" style="display: none;">
        <div class="delete-modal">
          <div class="delete-modal-icon">⚠️</div>
          <h3 class="delete-modal-title">Remove Restaurant?</h3>
          <p class="delete-modal-message">Are you sure you want to remove this restaurant from your history?</p>
          <div class="delete-modal-actions">
            <button class="delete-modal-cancel">Cancel</button>
            <button class="delete-modal-confirm">Remove</button>
          </div>
        </div>
      </div>
    `
    document.body.insertAdjacentHTML('beforeend', modalHTML)

    // Add styles
    this.addModalStyles()
  }

  addModalStyles() {
    if (document.getElementById('deleteModalStyles')) return;

    const style = document.createElement('style')
    style.id = 'deleteModalStyles'
    style.textContent = `
      .delete-modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.75);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        animation: fadeIn 0.2s ease;
      }

      .delete-modal {
        background: #2B2B2B;
        border: 2px solid rgba(254, 228, 64, 0.3);
        border-radius: 16px;
        padding: 2rem;
        max-width: 400px;
        width: 90%;
        text-align: center;
        animation: slideUp 0.3s ease;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
      }

      .delete-modal-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
      }

      .delete-modal-title {
        color: #FEE440;
        font-size: 1.5rem;
        margin: 0 0 1rem 0;
        font-weight: 600;
      }

      .delete-modal-message {
        color: rgba(255, 255, 255, 0.8);
        font-size: 1rem;
        margin: 0 0 2rem 0;
        line-height: 1.5;
      }

      .delete-modal-actions {
        display: flex;
        gap: 1rem;
        justify-content: center;
      }

      .delete-modal-cancel,
      .delete-modal-confirm {
        padding: 12px 24px;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        border: none;
        min-width: 120px;
      }

      .delete-modal-cancel {
        background: rgba(255, 255, 255, 0.1);
        color: rgba(255, 255, 255, 0.9);
        border: 1px solid rgba(255, 255, 255, 0.2);
      }

      .delete-modal-cancel:hover {
        background: rgba(255, 255, 255, 0.15);
        border-color: rgba(255, 255, 255, 0.3);
      }

      .delete-modal-confirm {
        background: #ef4444;
        color: white;
      }

      .delete-modal-confirm:hover {
        background: #dc2626;
        transform: scale(1.05);
      }

      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }

      @keyframes slideUp {
        from {
          opacity: 0;
          transform: translateY(20px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

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
  }

  showConfirmModal(event) {
    console.log('Remove button clicked')
    const button = event.target.closest('.remove-button')
    const restaurantId = button.dataset.restaurantId
    const card = button.closest('.history-card')
    console.log('Restaurant ID:', restaurantId)

    const modal = document.getElementById('deleteConfirmModal')
    const cancelBtn = modal.querySelector('.delete-modal-cancel')
    const confirmBtn = modal.querySelector('.delete-modal-confirm')

    // Show modal
    modal.style.display = 'flex'

    // Handle cancel
    const handleCancel = () => {
      modal.style.display = 'none'
      cancelBtn.removeEventListener('click', handleCancel)
      confirmBtn.removeEventListener('click', handleConfirm)
    }

    // Handle confirm
    const handleConfirm = () => {
      modal.style.display = 'none'
      this.removeRestaurant(restaurantId, card)
      cancelBtn.removeEventListener('click', handleCancel)
      confirmBtn.removeEventListener('click', handleConfirm)
    }

    // Close on background click
    const handleBackgroundClick = (e) => {
      if (e.target === modal) {
        handleCancel()
        modal.removeEventListener('click', handleBackgroundClick)
      }
    }

    cancelBtn.addEventListener('click', handleCancel)
    confirmBtn.addEventListener('click', handleConfirm)
    modal.addEventListener('click', handleBackgroundClick)
  }

  async removeRestaurant(restaurantId, card) {
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