require "rails_helper"

RSpec.describe RoomChannel, type: :channel do
  it "subscribes to the room stream" do
    subscribe(room_id: 1)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("room_1")
  end
end
