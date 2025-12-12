FactoryBot.define do
  factory :room do
    # Use a sequence to make sure every code is unique
    sequence(:code) { |n| "100#{n}" }

    # Required attributes
    owner_name { 'Test Owner' }
    location { 'New York' }
    price { '$$' }
    categories { 'Italian,American' }
    dietary_restrictions { [ 'No Restriction' ] }
  end
end
