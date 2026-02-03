require 'rails_helper'

RSpec.describe RefundRequest, type: :model do
  describe '#status' do
    it 'is required' do
      refund_request = build(:refund_request, status: nil)
      expect(refund_request).not_to be_valid
    end

    it 'only accepts valid statuses' do
      RefundRequest::STATUSES.each do |status|
        refund = create(:refund_request, status: status)
        expect(refund).to be_valid
      end
    end

    it 'does not accept invalid statuses' do
      refund = build(:refund_request, status: 'invalid_status')
      expect(refund).not_to be_valid
    end

    it 'has PENDING as default status' do
      refund = create(:refund_request)
      expect(refund.status).to eq('PENDING')
    end
  end
end
