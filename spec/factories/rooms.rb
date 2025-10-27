FactoryBot.define do
  factory :room do
    # Use a sequence to make sure every code is unique
    sequence(:code) { |n| "100#{n}" }
    owner_name { "Test Owner" }
    location { "New York" }
    price { "$" }
    categories { "Italian" }
  end
end
