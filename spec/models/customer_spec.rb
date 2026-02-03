require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe '#name' do
    it 'is required' do
      customer = build(:customer, name: nil)
      expect(customer).not_to be_valid
    end
  end

  describe '#code' do
    it 'is required' do
      customer = build(:customer, code: nil)
      expect(customer).not_to be_valid
    end

    it 'must be unique' do
      code = 'CUST_001'

      create(:customer, code: code)
      customer = build(:customer, code: code)

      expect(customer).not_to be_valid
    end
  end
end
