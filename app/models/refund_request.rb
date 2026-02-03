class RefundRequest < ApplicationRecord
  belongs_to :bill_of_lading, foreign_key: :bl_number, primary_key: :bl_number

  STATUSES = %w[PENDING APPROVED REJECTED PAID].freeze

  validates :status, inclusion: { in: STATUSES }
end
