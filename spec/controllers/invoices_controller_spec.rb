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

  describe 'POST /invoices/generate' do
    context 'with valid admin token' do
      let(:customer) { create(:customer) }
      let(:admin_token) { 'valid-admin-token' }

      let(:mocked_invoice_generator_result) do
        created = create_list(:invoice, 3, customer: customer, due_date: 5.days.ago)
        skipped = create_list(:invoice, 2, customer: customer, due_date: 15.days.from_now)

        {
          created: created,
          skipped: skipped,
          created_count: created.size,
          skipped_count: skipped.size,
          total_amount: created.sum(&:amount)
        }
      end

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('ADMIN_TOKEN').and_return(admin_token)
      end

      context 'with customer_id parameter' do
        it 'calls Demurrage::InvoiceGenerator.call with customer_id' do
          allow(Demurrage::InvoiceGenerator).to receive(:call).and_return(mocked_invoice_generator_result)

          post '/invoices/generate',
            params: { customer_id: customer.id },
            headers: { 'X-Admin-Token' => admin_token }

          expect(Demurrage::InvoiceGenerator).to have_received(:call).with(customer_id: customer.id.to_s)

          expect(response).to have_http_status(:ok)
        end
      end

      context 'without customer_id parameter' do
        it 'returns 422 Unprocessable Entity' do
          post '/invoices/generate', headers: { 'X-Admin-Token' => admin_token }

          expect(response).to have_http_status(422)
          expect(parsed_body['error']).to include('Missing customer_id parameter')
        end

        it 'does not call Demurrage::InvoiceGenerator.call' do
          allow(Demurrage::InvoiceGenerator).to receive(:call)

          post '/invoices/generate', headers: { 'X-Admin-Token' => admin_token }

          expect(Demurrage::InvoiceGenerator).not_to have_received(:call)
        end
      end

      context 'without admin token' do
        it 'returns 403 Forbidden' do
          post '/invoices/generate', params: { customer_id: 1 }

          expect(response).to have_http_status(:forbidden)
          expect(parsed_body['error']).to include('Invalid X-Admin-Token')
        end
      end

      context 'with invalid admin token' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('ADMIN_TOKEN').and_return('valid-admin-token')
        end

        it 'returns 403 Forbidden' do
          post '/invoices/generate',
            params: { customer_id: 1 },
            headers: { 'X-Admin-Token' => 'wrong-token' }

          expect(response).to have_http_status(:forbidden)
          expect(parsed_body['error']).to include('Invalid X-Admin-Token')
        end
      end
    end
  end
end
