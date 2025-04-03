# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Support::RecruitmentCycleForm do
  describe 'attribute assignment' do
    it 'parses multi-parameter dates for application start date' do
      form = described_class.new(
        'application_start_date(1i)' => '2024',
        'application_start_date(2i)' => '09',
        'application_start_date(3i)' => '30'
      )
      expect(form.application_start_date).to eq(Date.new(2024, 9, 30))
    end

    it 'parses multi-parameter dates for application end date' do
      form = described_class.new(
        'application_end_date(1i)' => '2025',
        'application_end_date(2i)' => '10',
        'application_end_date(3i)' => '2'
      )
      expect(form.application_end_date).to eq(Date.new(2025, 10, 2))
    end

    it 'handles invalid dates gracefully' do
      form = described_class.new(
        'application_start_date(1i)' => '2025',
        'application_start_date(2i)' => '02',
        'application_start_date(3i)' => '30'
      )
      expect(form.application_start_date).to be_nil
    end

    it 'handles incomplete dates gracefully' do
      form = described_class.new(
        'application_start_date(1i)' => '',
        'application_start_date(2i)' => '',
        'application_start_date(3i)' => ''
      )
      expect(form.application_start_date).to be_nil
    end
  end

  describe 'validations' do
    subject(:form) { described_class.new(params) }

    context 'when required fields are missing' do
      let(:params) { {} }

      it 'is invalid without a year' do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include('Enter a year')
      end

      it 'is invalid without an application start date' do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include('Enter an application start date')
      end

      it 'is invalid without an application end date' do
        expect(form).not_to be_valid
        expect(form.errors[:application_end_date]).to include('Enter an application end date')
      end
    end

    context 'when year is not a number' do
      let(:params) { { year: 'twenty twenty five' } }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include('Enter a number')
      end
    end

    context 'when dates are valid' do
      let(:params) do
        {
          'year' => '2051',
          'application_start_date(1i)' => '2050',
          'application_start_date(2i)' => '10',
          'application_start_date(3i)' => '15',
          'application_end_date(1i)' => '2051',
          'application_end_date(2i)' => '03',
          'application_end_date(3i)' => '10'
        }
      end

      it 'is valid' do
        expect(form).to be_valid
      end
    end

    context 'when end date is before start date' do
      let(:params) do
        {
          'year' => '2025',
          'application_start_date(1i)' => '2025',
          'application_start_date(2i)' => '03',
          'application_start_date(3i)' => '15',
          'application_end_date(1i)' => '2025',
          'application_end_date(2i)' => '03',
          'application_end_date(3i)' => '10'
        }
      end

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include('Start date must be before the application end date')
        expect(form.errors[:application_end_date]).to include('End date must be after the application start date')
      end
    end

    context 'when dates are invalid' do
      let(:params) do
        {
          'year' => '2025',
          'application_start_date(1i)' => '2025',
          'application_start_date(2i)' => '02',
          'application_start_date(3i)' => '30',
          'application_end_date(1i)' => '2025',
          'application_end_date(2i)' => '03',
          'application_end_date(3i)' => '50'
        }
      end

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include('Enter a valid date')
        expect(form.errors[:application_end_date]).to include('Enter a valid date')
      end
    end

    context 'when dates are incomplete' do
      let(:params) do
        {
          'year' => '2025',
          'application_start_date(1i)' => '2025',
          'application_start_date(2i)' => '02',
          'application_end_date(1i)' => '2025',
          'application_end_date(2i)' => '03',
          'application_end_date(3i)' => '10'
        }
      end

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors[:application_start_date]).to include('Enter an application start date')
      end
    end

    context 'when year is not unique' do
      let(:params) { { year: } }
      let(:year) { '2025' }

      before { create(:recruitment_cycle, year:) }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include('Year has already been taken')
      end
    end
  end
end
