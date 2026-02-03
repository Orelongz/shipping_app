FactoryBot.define do
  factory :refund_request do
    bill_of_lading { association :bill_of_lading }
    amount_requested { '500' }
  end
end
