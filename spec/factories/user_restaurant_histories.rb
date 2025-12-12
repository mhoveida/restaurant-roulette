FactoryBot.define do
  factory :user_restaurant_history do
    association :user
    association :restaurant
    visited_at { Time.current }
  end
end
