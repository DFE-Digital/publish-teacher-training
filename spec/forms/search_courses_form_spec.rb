# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchCoursesForm do
  describe '#search_params' do
    context 'when can_sponsor_visa is true' do
      let(:form) { described_class.new(can_sponsor_visa: 'true') }

      it 'returns the correct search params with can_sponsor_visa set to true' do
        expect(form.search_params).to eq({ can_sponsor_visa: true })
      end
    end

    context 'when can_sponsor_visa is false' do
      let(:form) { described_class.new(can_sponsor_visa: 'false') }

      it 'returns the correct search params with can_sponsor_visa set to false' do
        expect(form.search_params).to eq({ can_sponsor_visa: false })
      end
    end

    context 'when send_courses is true' do
      let(:form) { described_class.new(send_courses: 'true') }

      it 'returns the correct search params with send_courses set to true' do
        expect(form.search_params).to eq({ send_courses: true })
      end
    end

    context 'when send_courses is false' do
      let(:form) { described_class.new(send_courses: 'false') }

      it 'returns the correct search params with send_courses set to false' do
        expect(form.search_params).to eq({ send_courses: false })
      end
    end

    context 'when applications_open is true' do
      let(:form) { described_class.new(applications_open: 'true') }

      it 'returns the correct search params with applications_open set to true' do
        expect(form.search_params).to eq({ applications_open: true })
      end
    end

    context 'when applications_open is false' do
      let(:form) { described_class.new(applications_open: 'false') }

      it 'returns the correct search params with applications_open set to false' do
        expect(form.search_params).to eq({ applications_open: false })
      end
    end

    context 'when study_types are provided' do
      let(:form) { described_class.new(study_types: %w[full_time part_time]) }

      it 'returns the correct search params with study_types as an array' do
        expect(form.search_params).to eq({ study_types: %w[full_time part_time] })
      end
    end

    context 'when no attributes are set' do
      let(:form) { described_class.new }

      it 'returns empty search params' do
        expect(form.search_params).to eq({})
      end
    end

    context 'when multiple attributes are set' do
      let(:form) { described_class.new(can_sponsor_visa: 'true', send_courses: 'true', study_types: ['full_time']) }

      it 'returns the correct search params with all attributes' do
        expect(form.search_params).to eq({ can_sponsor_visa: true, send_courses: true, study_types: ['full_time'] })
      end
    end

    context 'when attributes contain nil values' do
      let(:form) { described_class.new(can_sponsor_visa: nil, send_courses: 'false') }

      it 'returns search params without nil values' do
        expect(form.search_params).to eq({ send_courses: false })
      end
    end
  end
end
