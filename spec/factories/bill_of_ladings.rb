FactoryBot.define do
  factory :bill_of_lading do
    customer { association :customer }
    arrival_date { 5.days.from_now }
    freetime { 15 }
  end
end
