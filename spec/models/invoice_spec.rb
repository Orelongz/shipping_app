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

  describe '#log_invoice_creation after_create callback' do
    let(:customer) { create(:customer) }
    let(:bill_of_lading) { create(:bill_of_lading, customer: customer) }

    it 'creates an AuditLog entry when an invoice is created' do
      expect {
        create(:invoice, customer: customer, bl_number: bill_of_lading.bl_number)
      }.to change { AuditLog.count }.by(1)

      audit_log = AuditLog.last

      expect(audit_log.event_type).to eq('invoice_created')
    end

    it 'logs the correct invoice metadata' do
      invoice = create(:invoice,
        customer: customer,
        bl_number: bill_of_lading.bl_number,
        amount: 1500.00
      )

      audit_log = AuditLog.last

      expect(audit_log.actor).to eq('system')
      expect(audit_log.resource_id).to eq(invoice.id)
      expect(audit_log.resource_type).to eq('Invoice')
      expect(audit_log.metadata['amount']).to eq('1500')
      expect(audit_log.metadata['customer_id']).to eq(customer.id)
      expect(audit_log.metadata['bl_number']).to eq(bill_of_lading.bl_number)
    end
  end

  describe '#enforce_immutable_amount on update' do
    let(:customer) { create(:customer) }
    let(:bill_of_lading) { create(:bill_of_lading, customer: customer) }
    let(:invoice) { create(:invoice, customer: customer, bl_number: bill_of_lading.bl_number, amount: 1000.00) }

    it 'prevents amount from being modified after creation' do
      invoice.amount = 2000.00

      expect(invoice.valid?).to be_falsey

      expect(invoice.errors[:amount]).to include('cannot be modified after creation')
    end
  end

  describe '#days_overdue' do
    it 'returns the number of days past due' do
      invoice = create(:invoice, due_date: 5.days.ago)
      expect(invoice.days_overdue).to eq(5)
    end

    it 'returns 0 for invoices not yet due' do
      invoice = create(:invoice, due_date: 5.days.from_now)
      expect(invoice.days_overdue).to eq(0)
    end

    it 'returns 0 for invoices due today' do
      invoice = create(:invoice, due_date: Date.current.to_datetime)
      expect(invoice.days_overdue).to eq(0)
    end
  end
end
