FactoryBot.define do
  factory :vote do
    room { nil }
    restaurant_id { 1 }
    voter_name { "MyString" }
    value { "MyString" }
  end
end
