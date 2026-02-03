class InvoicesController < ApplicationController
  before_action :authenticate_customer!, only: %i[overdue]
  before_action :authenticate_admin!, only: %i[generate]

  # GET /invoices/overdue
  def overdue
    invoices = Invoice
      .where(customer: current_customer)
      .overdue(Date.current)
      .order(due_date: :asc)

    render status: :ok, json: { invoices: ::InvoiceBlueprint.render_as_hash(invoices) }
  end

  # POST /invoices/generate
  def generate
    # Generate invoices for all overdue bill of ladings for a given customer
    unless params[:customer_id].present?
      return render json: { error: "Missing customer_id parameter" }, status: :unprocessable_entity
    end

    result = Demurrage::InvoiceGenerator.call(customer_id: params[:customer_id])

    render json: { result: result }, status: :ok
  end
end
