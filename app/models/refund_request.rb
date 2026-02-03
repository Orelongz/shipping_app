class RefundRequest < ApplicationRecord
  belongs_to :bill_of_lading

  STATUSES = %w[PENDING APPROVED REJECTED PAID].freeze

  validates :status, inclusion: { in: STATUSES }
end
