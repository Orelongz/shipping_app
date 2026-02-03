class BillOfLading < ApplicationRecord
  belongs_to :customer

  has_many :invoices
  has_many :refund_requests

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

  def due_date
    arrival_date + freetime.days
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

  private

  def generate_bl_number
    self.bl_number ||= "BL_#{SecureRandom.hex(6)}"
  end
end
