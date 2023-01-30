# frozen_string_literal: true

require 'rails_helper'

module Find
  RSpec.describe MatchOldParams do
    context 'with sortby and funding keys' do
      subject do
        described_class.call({
                               'sortby' => '2',
                               'funding' => '8'
                             })
      end

      it 'maps the old find params' do
        expect(subject).to eq({
                                'sortby' => 'distance',
                                'funding' => 'salary'
                              })
      end
    end

    context 'with FILTERS' do
      subject do
        described_class.call({
                               'senCourses' => 'true',
                               'lat' => '123',
                               'lng' => '456',
                               'rad' => '50',
                               'query' => 'provider name',
                               'hasvacancies' => 'false',
                               'subject_codes' => ['W1']
                             })
      end

      it 'maps the old find params' do
        expect(subject).to eq({
                                'send_courses' => 'true',
                                'latitude' => '123',
                                'longitude' => '456',
                                'radius' => '50',
                                'provider.provider_name' => 'provider name',
                                'has_vacancies' => 'false',
                                'subjects' => ['W1']
                              })
      end
    end

    context 'with STUDY_FILTERS' do
      subject do
        described_class.call({
                               'parttime' => 'true',
                               'fulltime' => 'true'
                             })
      end

      it 'maps the old find params' do
        expect(subject).to eq({ 'study_type' => %w[part_time full_time] })
      end
    end

    context 'with QUALIFICATION_FILTERS' do
      subject do
        described_class.call({
                               'qualifications' => %w[Other PgdePgceWithQts QtsOnly]
                             })
      end

      it 'maps the old find params' do
        expect(subject).to eq({
                                'qualification' => ['pgce pgde', 'pgce_with_qts', 'qts']
                              })
      end
    end
  end
end
