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
    it 'is set automatically before validation via set_due_date' do
      customer = create(:customer, payment_terms_days: 15)
      invoice = build(:invoice, customer: customer, due_date: nil)

      expect(invoice.valid?).to be_truthy
      expect(invoice.due_date).not_to be_nil
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

  describe '.open scope' do
    it 'returns all non-paid invoices' do
      create(:invoice, status: 'draft')
      create(:invoice, status: 'sent')
      create(:invoice, status: 'cancelled')
      create(:invoice, status: 'paid')

      expect(Invoice.open.count).to eq(3)
    end
  end

  describe '#set_due_date before validation' do
    it 'sets due_date to today plus customer payment terms when not provided' do
      customer = create(:customer, payment_terms_days: 30)
      invoice = build(:invoice, customer: customer, due_date: nil)

      expect(invoice.valid?).to be_truthy

      expect(invoice.due_date.to_date).to eq((Date.current + 30.days).to_date)
    end

    it 'preserves due_date when already set' do
      custom_due_date = 60.days.from_now
      invoice = build(:invoice, due_date: custom_due_date)

      expect(invoice.valid?).to be_truthy

      expect(invoice.due_date.to_date).to eq(custom_due_date.to_date)
    end

    it 'respects customer default payment terms' do
      customer = create(:customer, payment_terms_days: 15)
      invoice = build(:invoice, customer: customer, due_date: nil)

      expect(invoice.valid?).to be_truthy

      expect(invoice.due_date.to_date).to eq((Date.current + 15.days).to_date)
    end

    it 'uses different payment terms for different customers' do
      customer1 = create(:customer, payment_terms_days: 15)
      customer2 = create(:customer, payment_terms_days: 45)

      invoice1 = build(:invoice, customer: customer1, due_date: nil)
      invoice2 = build(:invoice, customer: customer2, due_date: nil)

      expect(invoice1.valid?).to be_truthy
      expect(invoice2.valid?).to be_truthy

      expect(invoice1.due_date.to_date).to eq((Date.current + 15.days).to_date)
      expect(invoice2.due_date.to_date).to eq((Date.current + 45.days).to_date)
    end
  end
end
