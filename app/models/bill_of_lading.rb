class BillOfLading < ApplicationRecord
  RATE_PER_CONTAINER_PER_DAY = 80 # USD

  belongs_to :customer

  has_many :invoices, foreign_key: :bl_number, primary_key: :bl_number
  has_many :refund_requests, foreign_key: :bl_number, primary_key: :bl_number

  validates :bl_number, uniqueness: true
  validates :bl_number, :arrival_date, presence: true
  validates :freetime,
    :number_of_20ft_containers,
    :number_of_40ft_containers,
    :number_of_40ft_high_cube_containers,
    :number_of_45ft_containers,
    :number_of_reefer_containers,
    :number_of_other_containers, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :generate_bl_number, on: :create

  scope :became_overdue_on, ->(date) do
    where("(arrival_date::date + interval '1 day' * freetime) = ?", date)
  end

  def due_date
    arrival_date + freetime.days
  end

  def amount
    total_number_of_containers * RATE_PER_CONTAINER_PER_DAY * days_overdue
  end

  # Total container count
  def total_number_of_containers
    number_of_20ft_containers +
      number_of_40ft_containers +
      number_of_40ft_high_cube_containers +
      number_of_45ft_containers +
      number_of_reefer_containers +
      number_of_other_containers
  end

  def days_overdue(date = Date.current)
    overdue_days = (date.to_date - due_date.to_date).to_i

    overdue_days.positive? ? overdue_days : 0
  end

  private

  def generate_bl_number
    self.bl_number ||= "BL_#{SecureRandom.hex(6)}"
  end
end
