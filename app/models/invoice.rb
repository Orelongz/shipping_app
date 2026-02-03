class Invoice < ApplicationRecord
  belongs_to :customer

  belongs_to :bill_of_lading, foreign_key: :bl_number, primary_key: :bl_number

  STATUSES = %w[draft sent paid cancelled].freeze

  validates :amount, :due_date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_due_date, on: :create

  # Create audit log entry when invoice is created
  after_create :log_invoice_creation

  # Prevent amount from being modified after creation
  validate :enforce_immutable_amount, on: :update, if: :persisted?

  # open invoice (any status other than 'paid').
  scope :open, -> { where.not(status: :paid) }
  scope :overdue, ->(date = Date.current) do
    where.not(status: %w[paid cancelled]).where("due_date < ?", date)
  end

  def days_overdue
    overdue_days = (Date.current - due_date.to_date).to_i

    overdue_days.positive? ? overdue_days : 0
  end

  private

  def set_due_date
    self.due_date ||= Date.current + customer.payment_terms_days.days
  end

  def log_invoice_creation
    AuditLog.create!(
      actor: "system",
      resource_id: id,
      resource_type: "Invoice",
      event_type: "invoice_created",
      metadata: {
        bl_number: bl_number,
        customer_id: customer_id,
        amount: amount.to_s,
        currency: currency
      }
    )
  end

  def enforce_immutable_amount
    errors.add(:amount, "cannot be modified after creation") if amount_changed?
  end
end
