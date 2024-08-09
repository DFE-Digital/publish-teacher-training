# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Find::CourseTypeAnswerDeterminer do
  describe '#show_undergraduate_courses?' do
    context 'when the age group is not further education, no degree, and no visa sponsorship required' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'false',
          university_degree_status: 'false'
        }
      end

      it 'returns true' do
        determiner = described_class.new(**params)
        expect(determiner.show_undergraduate_courses?).to be true
      end
    end

    context 'when the age group is further education' do
      let(:params) do
        {
          age_group: 'further_education',
          visa_status: 'false',
          university_degree_status: nil
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.show_undergraduate_courses?).to be false
      end
    end

    context 'when visa status requires sponsorship' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'true',
          university_degree_status: 'false'
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.show_undergraduate_courses?).to be false
      end
    end

    context 'when there is a university degree' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'false',
          university_degree_status: 'true'
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.show_undergraduate_courses?).to be false
      end
    end

    context 'when there is not a university degree' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'false',
          university_degree_status: nil
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.show_undergraduate_courses?).to be false
      end
    end
  end

  describe '#not_elibible_for_undergraduate_courses?' do
    context 'when the age group is not further education, visa requires sponsorship, and no degree' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'true',
          university_degree_status: 'false'
        }
      end

      it 'returns true' do
        determiner = described_class.new(**params)
        expect(determiner.not_elibible_for_undergraduate_courses?).to be true
      end
    end

    context 'when the age group is further education' do
      let(:params) do
        {
          age_group: 'further_education',
          visa_status: 'true',
          university_degree_status: nil
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.not_elibible_for_undergraduate_courses?).to be false
      end
    end

    context 'when visa sponsorship is not required' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'false',
          university_degree_status: 'false'
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.not_elibible_for_undergraduate_courses?).to be false
      end
    end

    context 'when there is a university degree' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'true',
          university_degree_status: 'true'
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.not_elibible_for_undergraduate_courses?).to be false
      end
    end

    context 'when there is not a value for university degree' do
      let(:params) do
        {
          age_group: 'secondary',
          visa_status: 'true',
          university_degree_status: nil
        }
      end

      it 'returns false' do
        determiner = described_class.new(**params)
        expect(determiner.not_elibible_for_undergraduate_courses?).to be false
      end
    end
  end
end
