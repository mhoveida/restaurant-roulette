import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  connect() {
    const roomId = this.element.dataset.roomId
    this.subscription = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: roomId },
      {
        received: (data) => {
          if (data.type === "start_spin" && data.url) {
            window.location.href = data.url
          }
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) consumer.subscriptions.remove(this.subscription)
  }
}
