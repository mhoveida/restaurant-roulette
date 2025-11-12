import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["wheel", "spinButton", "resultModal", "resultContent"]

  connect() {
    this.drawWheel()
    this.subscribeToRoom()
  }

  disconnect() {
    if (this.subscription) {
      consumer.subscriptions.remove(this.subscription)
    }
  }

  subscribeToRoom() {
    const roomId = this.element.dataset.roomId
    this.subscription = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: roomId },
      {
        received: (data) => this.handleBroadcast(data)
      }
    )
  }

  updateVoteCounts(data) {
    const votes_summary = data.counts || {} // fallback to empty object

    Object.entries(votes_summary).forEach(([key, count]) => {
      const [restaurant_id, value] = key.split(",")
      const card = document.querySelector(`[data-restaurant-id="${restaurant_id}"]`)
      if (!card) return

      const upEl = card.querySelector(".count-up")
      const downEl = card.querySelector(".count-down")

      if (value === "up" && upEl) upEl.textContent = `👍 ${count}`
      if (value === "down" && downEl) downEl.textContent = `👎 ${count}`
    })
  }

  handleBroadcast(data) {
    if (data.type === "spin_result" && data.restaurant) {
      this.displayResult(data.restaurant)

      // Dynamically inject new restaurant into Group Voting section
      const list = document.querySelector('[data-room-vote-target="list"]')
      if (list) {
        const r = data.restaurant
        const card = document.createElement("div")
        card.className = "restaurant-card"
        card.dataset.restaurantId = r.id
        card.innerHTML = `
          <div class="rc-body">
            ${r.image_url ? `<img class="rc-img" src="${r.image_url}" alt="${r.name}">` : ""}
            <div class="rc-meta">
              <div class="rc-name">${r.name}</div>
              <div class="rc-sub">${[r.price, r.rating].filter(Boolean).join(" • ")}</div>
            </div>
          </div>
          <div class="rc-actions">
            <button data-action="click->room-vote#vote" data-restaurant-id="${r.id}" data-value="up">👍</button>
            <button data-action="click->room-vote#vote" data-restaurant-id="${r.id}" data-value="down">👎</button>
            <span class="count-up"></span>
            <span class="count-down"></span>
          </div>
        `
        list.appendChild(card)
      }
    }

    // Handle vote updates
    if (data.type === "vote_update") {
      this.updateVoteCounts(data)
    }
  }

  drawWheel() {
    const canvas = this.wheelTarget
    const ctx = canvas.getContext("2d")

    // Set canvas size
    canvas.width = 300
    canvas.height = 300

    const centerX = canvas.width / 2
    const centerY = canvas.height / 2
    const radius = 100

    // Colors for slices
    const colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F"]
    const slices = 6

    // Draw slices
    for (let i = 0; i < slices; i++) {
      const startAngle = (i * 2 * Math.PI) / slices
      const endAngle = ((i + 1) * 2 * Math.PI) / slices

      ctx.beginPath()
      ctx.moveTo(centerX, centerY)
      ctx.arc(centerX, centerY, radius, startAngle, endAngle)
      ctx.closePath()
      ctx.fillStyle = colors[i]
      ctx.fill()
      ctx.strokeStyle = "#333"
      ctx.lineWidth = 2
      ctx.stroke()
    }

    // Draw center circle
    ctx.beginPath()
    ctx.arc(centerX, centerY, radius * 0.15, 0, 2 * Math.PI)
    ctx.fillStyle = "#FFD700"
    ctx.fill()
    ctx.strokeStyle = "#333"
    ctx.lineWidth = 2
    ctx.stroke()

    // Draw pointer at top
    ctx.beginPath()
    ctx.moveTo(centerX - 10, 20)
    ctx.lineTo(centerX + 10, 20)
    ctx.lineTo(centerX, 35)
    ctx.closePath()
    ctx.fillStyle = "#FFD700"
    ctx.fill()
    ctx.strokeStyle = "#333"
    ctx.lineWidth = 2
    ctx.stroke()
  }

  async readyToSpin() {
    const spinButton = this.spinButtonTarget
    const wasDisabled = spinButton.disabled

    // Disable button during spin
    spinButton.disabled = true
    this.wheelTarget.classList.add("spinning")

    // Spin animation duration
    const spinDuration = 2000 + Math.random() * 1000

    // Wait for animation to complete
    await new Promise(resolve => setTimeout(resolve, spinDuration))

    // Remove spinning class
    this.wheelTarget.classList.remove("spinning")

    // Call the spin endpoint
    try {
      const roomId = this.element.dataset.roomId
      const response = await fetch(`/rooms/${roomId}/spin`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        }
      })

      const data = await response.json()

      if (data.success && data.restaurant) {
        this.displayResult(data.restaurant)
      } else {
        alert("No restaurants found matching your criteria")
      }
    } catch (error) {
      console.error("Error spinning:", error)
      alert("Error spinning wheel")
    } finally {
      spinButton.disabled = wasDisabled
    }
  }

  displayResult(restaurant) {
    const modal = this.resultModalTarget
    const content = this.resultContentTarget

    // Build HTML for restaurant
    let html = `<div class="restaurant-name">${restaurant.name}</div>`

    if (restaurant.image_url) {
      html += `
        <div class="restaurant-image">
          <img src="${restaurant.image_url}" alt="${restaurant.name}">
        </div>
      `
    }

    // Rating
    html += `
      <div class="restaurant-rating">
        <span class="stars">${"★".repeat(Math.round(restaurant.rating))}${"☆".repeat(5 - Math.round(restaurant.rating))}</span>
        <span class="rating-value">${restaurant.rating}/5</span>
      </div>
    `

    // Meta information
    html += `<div class="restaurant-meta">`

    if (restaurant.price) {
      html += `<div class="price">${restaurant.price}</div>`
    }

    html += `</div>`

    // Address
    if (restaurant.address) {
      html += `
        <div class="restaurant-address">
          <span class="address-icon">📍</span>
          <span>${restaurant.address}</span>
        </div>
      `
    }

    // Status
    html += `<div class="restaurant-status">`
    if (restaurant.is_open_now) {
      html += '<span class="status-open">🟢 Open</span>'
    } else {
      html += '<span class="status-closed">🔴 Closed</span>'
    }
    html += `</div>`

    // Phone
    if (restaurant.phone) {
      html += `
        <div class="restaurant-address">
          <span class="address-icon">📞</span>
          <a href="tel:${restaurant.phone}" style="color: var(--color-yellow); text-decoration: none;">${restaurant.phone}</a>
        </div>
      `
    }

    content.innerHTML = html
    modal.style.display = "flex"
  }

  closeResult() {
    this.resultModalTarget.style.display = "none"
  }
}
