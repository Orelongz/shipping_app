class AuditLog < ApplicationRecord
  validates :event_type, :actor, :resource_type, :resource_id, presence: true
end
