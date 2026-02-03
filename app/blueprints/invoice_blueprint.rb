class InvoiceBlueprint < Blueprinter::Base
  identifier :bl_number

  fields :amount, :currency, :status, :due_date

  field :days_overdue do |invoice|
    invoice.days_overdue
  end
end
