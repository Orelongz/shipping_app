class AddApiTokenToCustomer < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :api_token, :string, null: false, comment: 'API token for authenticating API requests'

    add_index :customers, :api_token, unique: true
  end
end
