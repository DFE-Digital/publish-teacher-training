# frozen_string_literal: true

require 'rails_helper'

module Publish
  describe CourseFeesAndFinancialSupportForm, type: :model do
    let(:params) { {} }
    let(:course) { build(:course, :fee_type_based) }
    let(:enrichment) { course.enrichments.find_or_initialize_draft }

    subject { described_class.new(enrichment, params:) }

    describe 'validations' do
      it 'fee details' do
        enrichment.fee_details = Faker::Lorem.sentence(word_count: 251)
        expect(subject.valid?).to be false

        expect(subject.errors[:fee_details]).to include 'Reduce the word count for fees and financial support'
      end
    end

    describe '#save!' do
      valid_fee_details = Faker::Lorem.sentence(word_count: 250)
      let(:params) { { fee_details: valid_fee_details } }

      it 'saves the provider with any new attributes' do
        enrichment.fee_details = 'blah blah'
        expect { subject.save! }.to change(enrichment, :fee_details).from('blah blah').to(valid_fee_details)
      end
    end
  end
end
