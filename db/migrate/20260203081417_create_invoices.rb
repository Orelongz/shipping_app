class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices, id: :bigint do |t|
      t.belongs_to :customer, index: true, foreign_key: true, comment: 'Legacy id_client'

      t.string :bl_number, null: false, index: true, comment: 'Foreign key to bill_of_ladings'
      t.decimal :amount, precision: 12, scale: 0, null: false, comment: 'Legacy montant_facture'
      t.string :currency, default: 'USD', null: false, comment: 'Legacy devise'
      t.string :status, default: 'draft', null: false, comment: 'Legacy statut (draft, sent, paid, overdue)'

      # Note: This is the requested due_date column
      t.datetime :due_date, null: false

      t.timestamps
    end

    add_foreign_key :invoices, :bill_of_ladings, column: :bl_number, primary_key: :bl_number
  end
end
