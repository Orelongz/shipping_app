class CreateRefundRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :refund_requests, id: :bigint do |t|
      t.belongs_to :bill_of_lading, index: true, foreign_key: { column: :bl_number }, comment: 'Legacy numero_bl'

      t.string :amount_requested, comment: 'Legacy montant_demande'
      t.string :status, default: 'PENDING', null: false, comment: 'Legacy statut (PENDING, APPROVED, REJECTED, PAID)'

      t.timestamps
    end

    add_index :refund_requests, :status
  end
end
