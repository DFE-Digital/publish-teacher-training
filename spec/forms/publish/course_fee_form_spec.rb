# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe CourseFeeForm, type: :model do
    let(:params) { {} }
    let(:course) { build(:course, :fee_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    subject { described_class.new(enrichment, params:) }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:fee_uk_eu) }

      it 'validates UK/EU Fee' do
        expect(subject).to validate_numericality_of(:fee_uk_eu)
          .only_integer
          .is_greater_than_or_equal_to(1)
          .is_less_than_or_equal_to(100_000)
          .allow_nil
      end

      it 'validates International Fee' do
        expect(subject).to validate_numericality_of(:fee_international)
          .only_integer
          .is_greater_than_or_equal_to(1)
          .is_less_than_or_equal_to(100_000)
          .allow_nil
      end

      context 'fee details' do
        before do
          enrichment.fee_details = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it 'validates the word count for fee details' do
          expect(subject).not_to be_valid
          expect(subject.errors[:fee_details])
            .to include(I18n.t('activemodel.errors.models.publish/course_fee_form.attributes.fee_details.too_long'))
        end
      end

      context 'financial support' do
        before do
          enrichment.financial_support = Faker::Lorem.sentence(word_count: 251)
          subject.valid?
        end

        it 'validates the word count for financial support' do
          expect(subject).not_to be_valid
          expect(subject.errors[:financial_support])
            .to include(I18n.t('activemodel.errors.models.publish/course_fee_form.attributes.financial_support.too_long'))
        end
      end

      context 'after 2023 recruitment cycle and if can_sponsor_student_visa' do
        let(:recruitment_cycle) { build(:recruitment_cycle, :next) }
        let(:provider) { build(:provider, recruitment_cycle:) }
        let(:course) { build(:course, :fee_type_based, can_sponsor_student_visa: true, provider:) }

        it { is_expected.to validate_presence_of(:fee_international) }
      end
    end

    describe '#save!' do
      let(:params) { { fee_uk_eu: 12_000 } }

      before do
        enrichment.fee_uk_eu = 9500
      end

      it 'saves the provider with any new attributes' do
        expect { subject.save! }.to change(enrichment, :fee_uk_eu).from(9500).to(12_000)
      end
    end
  end
end
