# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe CourseLengthForm, type: :model do
    let(:params) { {} }
    let(:course) { build(:course, :fee_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    describe 'validations' do
      subject { described_class.new(enrichment, params:) }

      it { is_expected.to validate_presence_of(:course_length) }
    end

    describe '#save!' do
      context 'with standard course value' do
        it 'saves standard value' do
          enrichment.update(course_length: 'TwoYears')
          params = { course_length: 'OneYear' }
          subject = described_class.new(enrichment, params:)
          expect { subject.save! }.to change(enrichment, :course_length).from('TwoYears').to('OneYear')
        end
      end

      context 'custom length, not specified' do
        it 'saves length as "Other"' do
          enrichment.update(course_length: 'TwoYears')
          params = { course_length: 'Other', course_length_other_length: nil }
          subject = described_class.new(enrichment, params:)
          expect { subject.save! }.to change(enrichment, :course_length).from('TwoYears').to('Other')
        end
      end

      context 'custom length, specified' do
        it 'saves length as with custom value' do
          enrichment.update(course_length: 'TwoYears')
          params = { course_length: 'Other', course_length_other_length: 'Some user input' }
          subject = described_class.new(enrichment, params:)
          expect { subject.save! }.to change(enrichment, :course_length).from('TwoYears').to('Some user input')
        end
      end
    end
  end
end
