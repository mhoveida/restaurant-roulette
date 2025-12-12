require 'rails_helper'

RSpec.describe UserRestaurantHistory, type: :model do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:restaurant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:restaurant_id) }
  end

  describe 'uniqueness' do
    it 'prevents duplicate entries for the same user and restaurant' do
      create(:user_restaurant_history, user: user, restaurant: restaurant)
      duplicate = build(:user_restaurant_history, user: user, restaurant: restaurant)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'scopes' do
    it 'returns histories ordered by creation date (most recent first)' do
      history1 = create(:user_restaurant_history, user: user)
      history2 = create(:user_restaurant_history, user: user)

      expect(UserRestaurantHistory.recent).to eq([ history2, history1 ])
    end
  end
end
