import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="room-show"
export default class extends Controller {
  shareCode() {
    const codeValue = document.querySelector(".code-value")?.textContent || ""
    const shareText = `Join my Restaurant Roulette room with code: ${codeValue}`

    if (navigator.share) {
      navigator.share({
        title: "Restaurant Roulette Room",
        text: shareText
      }).catch(err => console.log("Error sharing:", err))
    } else {
      // Fallback: Copy to clipboard
      navigator.clipboard.writeText(shareText).then(() => {
        alert("Room code copied to clipboard!")
      }).catch(err => console.log("Error copying to clipboard:", err))
    }
  }

  readyToSpin() {
    // For now, just show a message
    // In a real app, this would transition to the voting/spinning phase
    alert("Time to spin! (Coming soon)")
  }
}
