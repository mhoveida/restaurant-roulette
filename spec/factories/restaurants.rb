FactoryBot.define do
  factory :restaurant do
    name { "MyString" }
    rating { "9.99" }
    price { "MyString" }
    address { "MyText" }
    phone { "MyString" }
    image_url { "MyString" }
    latitude { "9.99" }
    longitude { "9.99" }
    review_count { 1 }
    is_open_now { false }
    categories { "MyText" }
  end
end
