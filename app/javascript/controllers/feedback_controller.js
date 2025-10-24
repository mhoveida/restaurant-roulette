import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feedback"
export default class extends Controller {
  static targets = ["message"]

  giveFeedback(event) {
    const button = event.currentTarget
    const feedbackType = button.dataset.feedback

    // Disable both buttons after feedback is given
    const feedbackSection = button.closest(".feedback-section")
    const buttons = feedbackSection.querySelectorAll(".feedback-btn")
    buttons.forEach(btn => btn.disabled = true)

    // Show success message
    this.messageTarget.style.display = "block"

    // In a real app, you would send this to the server here
    // For now, just show the success message
    console.log(`Feedback recorded: ${feedbackType}`)
  }
}
