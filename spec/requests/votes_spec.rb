require "rails_helper"

RSpec.describe "Votes", type: :request do
  describe "POST /rooms/:room_id/votes" do
    let(:room) { create(:room) }
    let(:restaurant_id) { "123" }
    let(:voter_name) { "Celine" }

    let(:valid_params) do
      {
        vote: {
          restaurant_id: restaurant_id,
          voter_name: voter_name,
          value: "up"
        }
      }
    end

    it "creates a new vote" do
      expect {
        post room_votes_path(room), params: valid_params, as: :json
      }.to change(Vote, :count).by(1)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to eq(true)
      expect(body["vote"]["value"]).to eq("up")
    end

    it "updates an existing vote with the same voter + restaurant + room" do
      existing = Vote.create!(
        room_id: room.id,
        restaurant_id: restaurant_id,
        voter_name: voter_name,
        value: "down"
      )

      expect {
        post room_votes_path(room), params: valid_params, as: :json
      }.not_to change(Vote, :count)

      expect(existing.reload.value).to eq("up")
    end

    it "broadcasts vote_update with formatted counts" do
      expect {
        post room_votes_path(room), params: valid_params, as: :json
      }.to have_broadcasted_to("room_#{room.id}")
        .with(
          hash_including(
            type: "vote_update",
            counts: hash_including("#{restaurant_id},up" => 1)
          )
        )
    end

    it "returns errors if vote is invalid" do
      invalid_params = {
        vote: {
          restaurant_id: nil,
          voter_name: voter_name,
          value: "up"
        }
      }

      post room_votes_path(room), params: invalid_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["success"]).to eq(false)
      expect(body["errors"]).to be_present
    end
  end
end
