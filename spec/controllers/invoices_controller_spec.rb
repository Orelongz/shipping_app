require 'rails_helper'

RSpec.describe InvoicesController, type: :request do
  describe 'GET /invoices/overdue' do
    let(:customer1) { create(:customer, api_token: 'token-1') }
    let(:customer2) { create(:customer, api_token: 'token-2') }

    let(:bill_of_lading_1) { create(:bill_of_lading, customer: customer1) }
    let(:bill_of_lading_2) { create(:bill_of_lading, customer: customer1) }
    let(:bill_of_lading_3) { create(:bill_of_lading, customer: customer2) }

    context 'with valid customer token' do
      let!(:overdue_invoice) { create(:invoice, customer: customer1, bl_number: bill_of_lading_1.bl_number, due_date: 5.days.ago, status: 'draft') }
      let!(:future_invoice) { create(:invoice, customer: customer1, bl_number: bill_of_lading_2.bl_number, due_date: 5.days.from_now, status: 'draft') }
      let!(:other_customer_invoice) { create(:invoice, customer: customer2, bl_number: bill_of_lading_3.bl_number, due_date: 5.days.ago, status: 'draft') }

      subject { get '/invoices/overdue', headers: { 'X-Api-Token' => 'token-1' } }

      it 'returns overdue invoices for authenticated customer' do
        subject

        expect(response).to have_http_status(:success)
        expect(parsed_body['invoices']).to be_an(Array)
        expect(parsed_body['invoices'].length).to eq(1)
        expect(parsed_body['invoices'][0]['bl_number']).to eq(overdue_invoice.bl_number)
      end

      it 'does not return other customer invoices' do
        subject

        invoice_bl_numbers = parsed_body['invoices'].map { |i| i['bl_number'] }

        expect(invoice_bl_numbers).not_to include(other_customer_invoice.bl_number)
      end

      it 'returns correct invoice fields' do
        subject

        invoice = parsed_body['invoices'][0]

        expect(invoice).to include('bl_number', 'amount', 'currency', 'status', 'due_date', 'days_overdue')
      end
    end

    context 'without token' do
      it 'returns 401 Unauthorized' do
        get '/invoices/overdue'

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body['error']).to include('Missing X-Api-Token')
      end
    end

    context 'with invalid token' do
      it 'returns 401 Unauthorized' do
        get '/invoices/overdue', headers: { 'X-Api-Token' => 'invalid-token' }

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_body['error']).to include('Invalid X-Api-Token')
      end
    end
  end
end
