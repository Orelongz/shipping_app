class Customer < ApplicationRecord
  has_many :invoices
  has_many :bill_of_ladings
  has_many :refund_requests, through: :bill_of_ladings

  validates :code, :name, presence: true
  validates :code, uniqueness: true
end
