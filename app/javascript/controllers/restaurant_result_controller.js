import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="restaurant-result"
export default class extends Controller {
  close() {
    const overlay = this.element
    overlay.style.animation = "slideDown 0.3s ease-out"
    setTimeout(() => {
      overlay.remove()
    }, 300)
  }

  spinAgain() {
    // Close the result overlay - the form and preferences stay visible
    this.close()
  }

  share() {
    const restaurantName = document.querySelector(".restaurant-name")?.textContent || "a restaurant"
    const restaurantAddress = document.querySelector(".restaurant-address")?.textContent?.trim() || ""

    const shareText = `Check out ${restaurantName}! ${restaurantAddress}`

    if (navigator.share) {
      navigator.share({
        title: "Restaurant Roulette",
        text: shareText
      }).catch(err => console.log("Error sharing:", err))
    } else {
      // Fallback: Copy to clipboard
      navigator.clipboard.writeText(shareText).then(() => {
        alert("Shared text copied to clipboard!")
      }).catch(err => console.log("Error copying to clipboard:", err))
    }
  }
}
