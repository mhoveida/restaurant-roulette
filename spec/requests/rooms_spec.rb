require 'rails_helper'

RSpec.describe "Rooms", type: :request do
  describe "GET /rooms/:id" do
    it "returns http success" do
      room = Room.create!(code: "TEST", owner_name: "Owner", location: "SoHo", price: "$$", categories: ["Italian"])
      get room_path(room)
      expect(response).to have_http_status(:success)
    end
  end
end