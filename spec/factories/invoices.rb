FactoryBot.define do
  factory :invoice do
    customer { association :customer }
    bill_of_lading { association :bill_of_lading, customer: customer }
    amount { Faker::Number.between(from: 1000, to: 10_000) }
    due_date { 30.days.from_now }
  end
end
