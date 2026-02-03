require 'rails_helper'

RSpec.describe BillOfLading, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe '#bl_number' do
    it 'must be unique' do
      bl_number = 'BL123456'

      create(:bill_of_lading, bl_number: bl_number)
      bill_of_lading = build(:bill_of_lading, bl_number: bl_number)

      expect(bill_of_lading).not_to be_valid
    end
  end

  describe '#arrival_date' do
    it 'is required' do
      bill_of_lading = build(:bill_of_lading, arrival_date: nil)
      expect(bill_of_lading).not_to be_valid
    end
  end

  describe '#freetime' do
    it 'rejects negative integer' do
      bill_of_lading = build(:bill_of_lading, freetime: -1)
      expect(bill_of_lading).not_to be_valid
    end

    it 'accepts zero or positive integers' do
      bill_of_lading = build(:bill_of_lading, freetime: 10)
      expect(bill_of_lading).to be_valid
    end
  end

  describe 'container fields numericality' do
    it 'rejects negative integer' do
      bill_of_lading = build(:bill_of_lading, number_of_20ft_containers: -1)
      expect(bill_of_lading).not_to be_valid
    end

    it 'accepts zero or positive integers' do
      bill_of_lading = build(:bill_of_lading, number_of_20ft_containers: 0)
      expect(bill_of_lading).to be_valid
    end
  end

  describe '#due_date' do
    let(:arrival) { DateTime.current }
    let(:freetime) { 10 }

    subject(:bill_of_lading) { create(:bill_of_lading, arrival_date: arrival, freetime: freetime) }

    it 'calculates the due date as arrival_date plus freetime days' do
      expect(bill_of_lading.due_date.to_date).to eq(arrival.to_date + freetime.days)
    end
  end

  describe '#total_number_of_containers' do
    it 'sums all container types' do
      bill_of_lading = create(:bill_of_lading,
        number_of_20ft_containers: 10,
        number_of_40ft_containers: 5,
        number_of_40ft_high_cube_containers: 3,
        number_of_45ft_containers: 2,
        number_of_reefer_containers: 4,
        number_of_other_containers: 1
      )
      expected_total = 10 + 5 + 3 + 2 + 4 + 1

      expect(bill_of_lading.total_number_of_containers).to eq(expected_total)
    end

    it 'returns 0 when no containers' do
      bill_of_lading = create(:bill_of_lading, number_of_20ft_containers: 0)
      expect(bill_of_lading.total_number_of_containers).to eq(0)
    end
  end

  describe '.became_overdue_on' do
    let(:customer) { create(:customer) }
    subject { BillOfLading.became_overdue_on(Date.new(2026, 1, 11)) }

    it 'returns bill of ladings that became overdue on the given date' do
      # overdue date would be 2026-01-01 + 10.days = 2026-01-11
      expected_bill_of_lading = create(:bill_of_lading,
        customer: customer,
        arrival_date: Date.new(2026, 1, 1),
        freetime: 10
      )

      create(:bill_of_lading,
        customer: customer,
        arrival_date: Date.new(2026, 1, 2),
        freetime: 10
      )

      expect(subject).to contain_exactly(expected_bill_of_lading)
    end
  end

  describe '#days_overdue' do
    let(:bill_of_lading) { create(:bill_of_lading, arrival_date: Date.new(2026, 1, 1), freetime: 10) }

    it 'returns the number of overdue days when past due date' do
      expect(bill_of_lading.days_overdue(Date.new(2026, 1, 15))).to eq(4)
    end

    it 'returns 0 when not overdue' do
      expect(bill_of_lading.days_overdue(Date.new(2026, 1, 10))).to eq(0)
    end
  end

  describe '#amount' do
    let(:travel_date) { Date.new(2026, 1, 15) }

    around do |example|
      original_time_zone = Time.zone
      # Ensure consistent time for Date.current
      travel_to(travel_date) { example.run }
      Time.zone = original_time_zone
    end

    it 'calculates amount based on containers, rate, and overdue days' do
      bill_of_lading = create(:bill_of_lading,
        arrival_date: Date.new(2026, 1, 1),
        freetime: 10,
        number_of_20ft_containers: 1,
        number_of_40ft_containers: 2,
        number_of_40ft_high_cube_containers: 0,
        number_of_45ft_containers: 1,
        number_of_reefer_containers: 0,
        number_of_other_containers: 0
      )

      expected_days_overdue = 4 # From 11th of Jan (arrival + freetime) to 15th of Jan
      expected_total_containers = 1 + 2 + 0 + 1 + 0 + 0

      expect(bill_of_lading.amount).to eq(expected_total_containers * BillOfLading::RATE_PER_CONTAINER_PER_DAY * expected_days_overdue)
    end
  end
end
