class CreateRefundRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :refund_requests, id: :bigint do |t|
      t.string :bl_number, null: false, index: true, comment: 'Legacy numero_bl'
      t.string :amount_requested, comment: 'Legacy montant_demande'
      t.string :status, default: 'PENDING', null: false, comment: 'Legacy statut (PENDING, APPROVED, REJECTED, PAID)'

      t.timestamps
    end

    add_index :refund_requests, :status
    add_foreign_key :refund_requests, :bill_of_ladings, column: :bl_number, primary_key: :bl_number
  end
end
