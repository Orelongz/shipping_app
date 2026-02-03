module Demurrage
  class InvoiceGenerator
    class InvoiceGeneratorError < StandardError; end

    def self.call(customer_id:, date: Date.yesterday)
      ActiveRecord::Base.transaction do
        new(customer_id:, date:).generate_invoices
      end
    end

    attr_reader :customer_id, :date, :created, :skipped

    def initialize(customer_id:, date:)
      @created = []
      @skipped = []
      @customer_id = customer_id
      @date = date.is_a?(Date) ? date : Date.parse(date.to_s)
    end

    def generate_invoices
      overdue_bill_of_ladings.each do |bill_of_lading|
        create_or_skip_invoice(bill_of_lading)
      end

      invoice_summary
    end

    private

    def overdue_bill_of_ladings
      @overdue_bill_of_ladings ||=
        BillOfLading.where(customer_id: customer_id).became_overdue_on(date)
    end

    def create_or_skip_invoice(bill_of_lading)
      invoice = create_invoice_for(bill_of_lading)

      created << ::InvoiceBlueprint.render_as_hash(invoice)
    rescue ActiveRecord::RecordInvalid, InvoiceGeneratorError => e
      skipped << {
        bl_number: bill_of_lading.bl_number,
        reason: e.message
      }
    end

    def create_invoice_for(bill_of_lading)
      # Skip if bill_of_lading already has an open invoice
      raise InvoiceGeneratorError, "Open invoice already exists" if bill_of_lading.invoices.open.exists?

      # Skip if bill_of_lading with zero containers
      raise InvoiceGeneratorError, "Bill of lading currently have zero containers" if bill_of_lading.total_number_of_containers.zero?

      Invoice.create!(
        customer_id: customer_id,
        amount: bill_of_lading.amount,
        bl_number: bill_of_lading.bl_number
      )
    end

    def invoice_summary
      {
        created: created,
        skipped: skipped,
        created_count: created.size,
        skipped_count: skipped.size,
        total_amount: created.sum { |invoice| invoice[:amount] }
      }
    end
  end
end
