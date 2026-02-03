FactoryBot.define do
  factory :invoice do
    customer { association :customer }
    bill_of_lading { association :bill_of_lading, customer: customer }
    amount { 1000 }
    due_date { 30.days.from_now }
  end
end
