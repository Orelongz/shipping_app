class InvoicesController < ApplicationController
  before_action :authenticate_customer!

  # GET /invoices/overdue
  def overdue
    invoices = Invoice
      .where(customer: current_customer)
      .overdue(Date.current)
      .order(due_date: :asc)

    render status: :ok, json: { invoices: ::InvoiceBlueprint.render_as_hash(invoices) }
  end

  # TODO
  def generate
  end
end
