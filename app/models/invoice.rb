class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :bill_of_lading

  STATUSES = %w[draft sent paid cancelled].freeze

  validates :amount, :due_date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }
end
