FactoryBot.define do
  factory :customer do
    code { "CUST_#{SecureRandom.hex(6)}" }
    sequence(:name) { |n| "Customer #{n}" }
  end
end
