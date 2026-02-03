require 'rails_helper'

RSpec.describe RefundRequest, type: :model do
  let(:bill_of_lading) { create(:bill_of_lading) }

  describe '#status' do
    it 'is required' do
      refund_request = build(:refund_request, bill_of_lading: bill_of_lading, status: nil)

      expect(refund_request).not_to be_valid
    end

    it 'only accepts valid statuses' do
      RefundRequest::STATUSES.each do |status|
        refund = create(:refund_request, bill_of_lading: bill_of_lading, status: status)

        expect(refund).to be_valid
      end
    end

    it 'does not accept invalid statuses' do
      refund = build(:refund_request, bill_of_lading: bill_of_lading, status: 'invalid_status')

      expect(refund).not_to be_valid
    end

    it 'has PENDING as default status' do
      refund = create(:refund_request, bill_of_lading: bill_of_lading)

      expect(refund.status).to eq('PENDING')
    end
  end
end
