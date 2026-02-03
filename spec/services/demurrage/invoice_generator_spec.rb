require 'rails_helper'

RSpec.describe Demurrage::InvoiceGenerator, type: :service do
  let(:customer_1) { create(:customer) }
  let!(:bill_of_lading_1) { create(:bill_of_lading, arrival_date: Date.yesterday, freetime: 0, customer: customer_1) }
  let!(:bill_of_lading_2) { create(:bill_of_lading, arrival_date: Date.yesterday, freetime: 0, customer: customer_1) }

  let(:customer_2) { create(:customer) }
  let!(:bill_of_lading_3) { create(:bill_of_lading, arrival_date: Date.yesterday, freetime: 0, customer: customer_2) }

  describe '.call' do
    subject { described_class.call(customer: customer_1) }

    context "when both bill of ladings have no existing invoices" do
      it 'returns a summary of created and skipped invoices and created totals' do
        expect { subject }.to change { Invoice.count }.by(2)

        expect(subject[:created_count]).to eq(2)
        expect(subject[:skipped_count]).to eq(0)
        expect(subject[:total_amount]).to eq(bill_of_lading_1.amount + bill_of_lading_2.amount)
      end
    end

    context "when one bill of lading has an existing open invoice" do
      before do
        create(:invoice, customer: customer_1, bl_number: bill_of_lading_1.bl_number, status: 'draft')
      end

      it 'skips the bill of lading with existing open invoice' do
        expect { subject }.to change { Invoice.count }.by(1)

        expect(subject[:created_count]).to eq(1)
        expect(subject[:skipped_count]).to eq(1)
        expect(subject[:total_amount]).to eq(bill_of_lading_2.amount)
        expect(subject[:skipped]).to eq([
          { bl_number: bill_of_lading_1.bl_number, reason: 'Open invoice already exists' }
        ])
      end
    end

    context "when bill of landings have zero containers" do
      let!(:bill_of_lading_3) { create(:bill_of_lading, arrival_date: Date.yesterday, freetime: 0, customer: customer_2, number_of_20ft_containers: 0) }

      subject { described_class.call(customer: customer_2) }

      it 'skips the bill of lading with zero containers' do
        expect { subject }.not_to change { Invoice.count }

        expect(subject[:created_count]).to eq(0)
        expect(subject[:skipped_count]).to eq(1)
        expect(subject[:total_amount]).to eq(0)
        expect(subject[:skipped]).to eq([
          { bl_number: bill_of_lading_3.bl_number, reason: 'Bill of lading currently have zero containers' }
        ])
      end
    end
  end
end
