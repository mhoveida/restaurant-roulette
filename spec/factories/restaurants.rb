FactoryBot.define do
  factory :restaurant do
    name { "Da Andrea" }
    rating { 4.7 }
    price { "$$" }
    address { "160 8th Ave, New York, NY 10011" }
    phone { "+1 212-367-1979" }
    image_url { "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&h=300&fit=crop" }
    latitude { 40.7423 }
    longitude { -74.0018 }
    review_count { 1250 }
    is_open_now { true }
    closing_time { "10:00 PM" }
    categories { [ "Italian", "Mediterranean", "Pasta" ] }
  end
end