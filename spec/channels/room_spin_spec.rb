require "rails_helper"

RSpec.describe "Room spin", type: :request do
  describe "POST /rooms/:id/spin" do
    let(:room) { create(:room) }
    let(:fake_restaurant) { { "name" => "Golden Sushi", "id" => 999 } }

    before do
      allow_any_instance_of(RestaurantService)
        .to receive(:random_restaurant)
        .and_return(fake_restaurant)
    end

    it "broadcasts a spin_result with the restaurant" do
      expect {
        post spin_room_path(room), as: :json
      }.to have_broadcasted_to("room_#{room.id}")
       .with(
         hash_including(
           type: "spin_result",
           restaurant: hash_including("name" => "Golden Sushi")
         )
       )
    end

    it "returns JSON success response" do
      post spin_room_path(room), as: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(JSON.parse(response.body)["restaurant"]["name"]).to eq("Golden Sushi")
    end
  end
end
