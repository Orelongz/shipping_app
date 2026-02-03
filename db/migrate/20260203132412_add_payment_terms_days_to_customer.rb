class AddPaymentTermsDaysToCustomer < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :payment_terms_days, :integer, null: false, default: 15, comment: 'Number of days for payment terms'
  end
end
