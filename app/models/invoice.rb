class Invoice < ApplicationRecord
  belongs_to :customer

  belongs_to :bill_of_lading, foreign_key: :bl_number, primary_key: :bl_number

  STATUSES = %w[draft sent paid cancelled].freeze

  validates :amount, :due_date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_due_date, on: :create

  # open invoice (any status other than 'paid').
  scope :open, -> { where.not(status: :paid) }

  def set_due_date
    self.due_date ||= Date.current + customer.payment_terms_days.days
  end
end
