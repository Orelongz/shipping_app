module Demurrage
  class InvoiceGenerator
    class InvoiceGeneratorError < StandardError; end

    def self.call(customer:, date: Date.yesterday)
      ActiveRecord::Base.transaction do
        new(customer:, date:).generate_invoices
      end
    end

    attr_reader :customer, :date, :created, :skipped

    def initialize(customer:, date:)
      @created = []
      @skipped = []
      @customer = customer
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
        BillOfLading.where(customer: customer).became_overdue_on(date)
    end

    def create_or_skip_invoice(bill_of_lading)
      created << create_invoice_for(bill_of_lading)
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
        customer_id: customer.id,
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
        total_amount: created.sum(&:amount)
      }
    end
  end
end
