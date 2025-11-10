import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  // --- Handle user click on 👍 / 👎 ---
  async vote(event) {
    const button = event.currentTarget
    const restaurantId = button.dataset.restaurantId
    const value = button.dataset.value
    const roomId = this.element.dataset.roomId
    const voterName = this.element.dataset.voterName || "Guest"

    // ✅ Step 1: Disable both buttons for this restaurant after first click
    const restaurantCard = button.closest(".restaurant-card")
    const allButtons = restaurantCard.querySelectorAll("button[data-action*='room-vote#vote']")
    allButtons.forEach(b => b.disabled = true)

    try {
        const response = await fetch(`/rooms/${roomId}/votes`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({
            vote: { restaurant_id: restaurantId, voter_name: voterName, value: value }
        })
        })

        const data = await response.json()

        if (data.success) {
        console.log("✅ Vote recorded:", data.vote)
        // Small visual feedback
        button.classList.add("voted")
        restaurantCard.classList.add(value === "up" ? "voted-up" : "voted-down")
        } else {
        console.warn("Vote failed:", data.errors)
        // If vote failed (e.g., duplicate), re-enable buttons
        allButtons.forEach(b => b.disabled = false)
        }
    } catch (err) {
        console.error("Vote request failed:", err)
        // If error, re-enable buttons so user can retry
        allButtons.forEach(b => b.disabled = false)
    }
    }
}
