# frozen_string_literal: true

require 'rails_helper'

class UkprnFormatValidatorTest
  include ActiveModel::Validations

  attr_accessor :ukprn

  validates :ukprn, ukprn_format: { allow_blank: true }
end

describe UkprnFormatValidator do
  let(:ukprn) { '12345678' }

  let(:model) do
    model = UkprnFormatValidatorTest.new
    model.ukprn = ukprn
    model
  end

  describe 'UKPRN validation' do
    context 'with a valid reference number' do
      it 'does not add an error' do
        expect(model).to be_valid
      end
    end

    context 'without a value' do
      let(:ukprn) { nil }

      it 'does not add an error' do
        expect(model).to be_valid
      end
    end

    context 'with an empty string' do
      let(:ukprn) { '' }

      it 'does not add an error' do
        expect(model).to be_valid
      end
    end

    context 'with a number not beginning with a 1' do
      let(:ukprn) { '22345678' }

      it 'adds an error' do
        expect(model).not_to be_valid
        expect(model.errors.first.type.to_s == 'contains_eight_numbers_starting_with_one').to be(true)
      end
    end

    context 'with a short UKPRN beginning with 1' do
      let(:ukprn) { '1234' }

      it 'adds an error' do
        expect(model).not_to be_valid
        expect(model.errors.first.type.to_s == 'contains_eight_numbers_starting_with_one').to be(true)
      end
    end

    context 'with a long UKPRN beginning with 1' do
      let(:ukprn) { '123456789' }

      it 'adds an error' do
        expect(model).not_to be_valid
        expect(model.errors.first.type.to_s == 'contains_eight_numbers_starting_with_one').to be(true)
      end
    end

    context 'with a UKPRN begining with 1 then 7 letters' do
      let(:ukprn) { '1AAAAAA' }

      it 'adds an error' do
        expect(model).not_to be_valid
        expect(model.errors.first.type.to_s == 'contains_eight_numbers_starting_with_one').to be(true)
      end
    end
  end
end
