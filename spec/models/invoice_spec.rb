require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe '#amount' do
    it 'is required' do
      invoice = build(:invoice, amount: nil)
      expect(invoice).not_to be_valid
    end

    it 'must be greater than or equal to zero' do
      invoice = build(:invoice, amount: 500)
      expect(invoice).to be_valid
    end
  end

  describe '#due_date' do
    it 'is required' do
      invoice = build(:invoice, due_date: nil)
      expect(invoice).not_to be_valid
    end
  end

  describe '#status' do
    it 'is required' do
      invoice = build(:invoice, status: nil)
      expect(invoice).not_to be_valid
    end

    it 'only accepts valid statuses' do
      Invoice::STATUSES.each do |status|
        invoice = build(:invoice, status: status)
        expect(invoice).to be_valid
      end
    end

    it 'does not accept invalid statuses' do
      invoice = build(:invoice, status: 'invalid_status')
      expect(invoice).not_to be_valid
    end

    it 'has draft as default status' do
      invoice = create(:invoice)
      expect(invoice.status).to eq('draft')
    end
  end
end
