import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  static targets = ["list"];

  connect() {
    this.subscribeToRoom();
  }

  disconnect() {
    if (this.subscription) {
      consumer.subscriptions.remove(this.subscription);
    }
  }

  subscribeToRoom() {
    const roomId = this.element.dataset.roomId;
    this.subscription = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: roomId },
      { received: (data) => this.handleBroadcast(data) }
    );
  }

  handleBroadcast(data) {
    if (data.type === "vote_update") {
      this.updateVoteCounts(data.counts);
    }
  }

  updateVoteCounts(counts) {
    // For now, just log it — we'll display later
    console.log("📊 Live vote counts:", counts);

    // Optional: update the UI if your restaurant cards have data-restaurant-id
    for (const [key, value] of Object.entries(counts)) {
      const [restaurantId, voteType] = key.split(",");
      const count = value;

      const card = this.element
        .querySelector(`[data-restaurant-id="${restaurantId}"]`)
        ?.closest(".restaurant-card");
      if (!card) continue;

      let counter = card.querySelector(`.count-${voteType}`);
      if (!counter) {
        counter = document.createElement("span");
        counter.classList.add(`count-${voteType}`);
        card.querySelector(`.rc-actions`).appendChild(counter);
      }
      counter.textContent = `${voteType === "up" ? "👍" : "👎"} ${count}`;
    }
  }

  // --- Handle user click on 👍 / 👎 ---
  async vote(event) {
    const button = event.currentTarget;
    const restaurantId = button.dataset.restaurantId;
    const value = button.dataset.value;
    const roomId = this.element.dataset.roomId;
    const voterName = this.element.dataset.voterName || "Guest";

    // ✅ Step 1: Disable both buttons for this restaurant after first click
    const restaurantCard = button.closest(".restaurant-card");
    const allButtons = restaurantCard.querySelectorAll(
      "button[data-action*='room-vote#vote']"
    );
    allButtons.forEach((b) => (b.disabled = true));

    try {
      const response = await fetch(`/rooms/${roomId}/votes`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")
            .content,
        },
        body: JSON.stringify({
          vote: {
            restaurant_id: restaurantId,
            voter_name: voterName,
            value: value,
          },
        }),
      });

      const data = await response.json();

      if (data.success) {
        console.log("✅ Vote recorded:", data.vote);
        // Small visual feedback
        button.classList.add("voted");
        restaurantCard.classList.add(
          value === "up" ? "voted-up" : "voted-down"
        );
      } else {
        console.warn("Vote failed:", data.errors);
        // If vote failed (e.g., duplicate), re-enable buttons
        allButtons.forEach((b) => (b.disabled = false));
      }
    } catch (err) {
      console.error("Vote request failed:", err);
      // If error, re-enable buttons so user can retry
      allButtons.forEach((b) => (b.disabled = false));
    }
  }
}
