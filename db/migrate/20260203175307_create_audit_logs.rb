class CreateAuditLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :audit_logs, id: :bigint do |t|
      t.string :event_type, null: false
      t.string :actor, null: false, comment: 'system or customer identifier'
      t.string :resource_type, null: false
      t.bigint :resource_id, null: false, comment: 'ID of the resource modified'
      t.jsonb :metadata, default: {}, comment: 'Additional context'

      t.timestamps
    end

    add_index :audit_logs, :event_type
    add_index :audit_logs, %i[resource_type resource_id]
  end
end
