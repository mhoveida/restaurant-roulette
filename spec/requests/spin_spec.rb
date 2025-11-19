# spec/requests/spin_controller_spec.rb
require "rails_helper"

RSpec.describe RoomsController, type: :request do
  describe "POST /rooms/:id/spin" do
    let(:room) { create(:room) }
    let(:fake_restaurant) do
      {
        "id" => 999,
        "name" => "Golden Sushi",
        "price" => "$$",
        "rating" => 4.5
      }
    end

    before do
      allow_any_instance_of(RestaurantService)
        .to receive(:random_restaurant)
        .and_return(fake_restaurant)
    end

    it "broadcasts a spin_result to the room channel" do
      expect {
        post spin_room_path(room), xhr: true
      }.to have_broadcasted_to("room_#{room.id}")
        .with(
          type: "spin_result",
          restaurant: hash_including("name" => "Golden Sushi")
        )
    end

    it "returns success JSON with the restaurant" do
      post spin_room_path(room), xhr: true
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["success"]).to eq(true)
      expect(json["restaurant"]["name"]).to eq("Golden Sushi")
    end
  end
end
