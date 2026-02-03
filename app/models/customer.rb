class Customer < ApplicationRecord
  has_many :invoices
  has_many :bill_of_ladings
  has_many :refund_requests, through: :bill_of_ladings

  validates :code, :name, :api_token, presence: true
  validates :code, :api_token, uniqueness: true

  # Generate a random API token if not provided
  before_validation :generate_api_token, if: -> { api_token.blank? }

  private

  def generate_api_token
    self.api_token = "token_#{SecureRandom.hex(16)}"
  end
end
