import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  static targets = ["list"];

  connect() {
    const roomId = this.element.dataset.roomId;
    const dsName = (this.element.dataset.voterName || "").trim();

    // Per-tab key
    const key = `room:${roomId}:name`;

    // Prefer dataset; otherwise use per-tab sessionStorage; if still empty, prompt
    let name = dsName || sessionStorage.getItem(key);
    if (!name) {
      name = prompt("Enter your name for voting") || "Guest";
    }
    sessionStorage.setItem(key, name);
    this.voterName = name;

    this.subscribeToRoom();
  }

  disconnect() {
    if (this.subscription) consumer.subscriptions.remove(this.subscription);
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
    for (const [key, value] of Object.entries(counts)) {
      const [restaurantId, voteType] = key.split(",");
      const card = this.element.querySelector(
        `[data-restaurant-id="${restaurantId}"]`
      )?.closest(".restaurant-card");
      if (!card) continue;

      let counter = card.querySelector(`.count-${voteType}`);
      if (!counter) {
        counter = document.createElement("span");
        counter.classList.add(`count-${voteType}`);
        card.querySelector(`.rc-actions`).appendChild(counter);
      }
      counter.textContent = `${voteType === "up" ? "👍" : "👎"} ${value}`;
    }
  }

  async vote(event) {
    const button = event.currentTarget;
    const restaurantId = button.dataset.restaurantId;
    const value = button.dataset.value;
    const roomId = this.element.dataset.roomId;
    const voterName = this.voterName;

    const card = button.closest(".restaurant-card");
    const allButtons = card.querySelectorAll(`button[data-action*='room-vote#vote']`);
    allButtons.forEach(b => b.disabled = true);

    try {
      const response = await fetch(`/rooms/${roomId}/votes`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content,
        },
        body: JSON.stringify({
          vote: { restaurant_id: restaurantId, voter_name: voterName, value }
        }),
      });

      const data = await response.json();
      if (data.success) {
        button.classList.add("voted");
        card.classList.add(value === "up" ? "voted-up" : "voted-down");
      } else {
        allButtons.forEach(b => b.disabled = false);
      }
    } catch (e) {
      allButtons.forEach(b => b.disabled = false);
    }
  }
}
