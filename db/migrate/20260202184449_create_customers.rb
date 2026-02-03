class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers, id: :bigint do |t|
      t.string :name, null: false, comment: 'Legacy nom'
      t.string :code, null: false, comment: 'Legacy code_client'

      t.timestamps
    end

    add_index :customers, :code, unique: true
  end
end
