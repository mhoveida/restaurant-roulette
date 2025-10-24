FactoryBot.define do
  factory :user do
    # Use sequence to make sure emails are always unique
    sequence(:email) { |n| "person#{n}@example.com" }
    sequence(:name) { |n| "Person#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
