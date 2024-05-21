# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe CourseSalaryForm, type: :model do
    let(:params) { {} }
    let(:course) { build(:course, :salary_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    subject { described_class.new(enrichment, params:) }

    describe 'validations' do
      context 'salary details' do
        before do
          enrichment.salary_details = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it 'validates the word count for fee details' do
          expect(subject).not_to be_valid
          expect(subject.errors[:salary_details])
            .to include(I18n.t('activemodel.errors.models.publish/course_salary_form.attributes.salary_details.too_long'))
        end
      end
    end

    describe '#save!' do
      let(:params) { { salary_details: 'some text' } }

      before do
        enrichment.salary_details = Faker::Lorem.sentence(word_count: 249)
      end

      it 'saves the provider with any new attributes' do
        expect { subject.save! }.to change(enrichment, :salary_details).to('some text')
      end
    end
  end
end
