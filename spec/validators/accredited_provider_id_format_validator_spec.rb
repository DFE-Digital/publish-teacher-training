# frozen_string_literal: true

require 'rails_helper'

class AccreditedProviderIdFormatValidatorTest
  include ActiveModel::Validations

  attr_accessor :accredited_provider_id

  validates :accredited_provider_id, accredited_provider_id_format: { allow_blank: false }
end

describe AccreditedProviderIdFormatValidator do
  let(:accredited_provider_id) { 1234 }

  let(:model) do
    model = AccreditedProviderIdFormatValidatorTest.new
    model.accredited_provider_id = accredited_provider_id
    model
  end

  describe 'accredited_provider_id validation' do
    context 'with a valid id starting with 1' do
      it 'does not add an error' do
        expect(model).to be_valid
      end
    end

    context 'with a valid id starting with 5' do
      let(:accredited_provider_id) { 5432 }

      it 'does not add an error' do
        expect(model).to be_valid
      end
    end

    context 'without a value' do
      let(:accredited_provider_id) { nil }

      it 'is invalid' do
        expect(model).not_to be_valid
        expect(model.errors.first.type.to_s).to eq('blank')
      end
    end

    context 'with an empty string' do
      let(:accredited_provider_id) { '' }

      it 'is invalid' do
        expect(model).not_to be_valid
        expect(model.errors.first.type.to_s).to eq('blank')
      end
    end

    context 'with a number not beginning with a 1' do
      let(:accredited_provider_id) { '2234' }

      it 'adds an error' do
        expect(model).to be_invalid
        expect(model.errors.first.type.to_s).to eq('format')
      end
    end

    context 'with a short UKPRN beginning with 1' do
      let(:accredited_provider_id) { '123' }

      it 'adds an error' do
        expect(model).to be_invalid
        expect(model.errors.first.type.to_s).to eq('format')
      end
    end

    context 'with a long UKPRN beginning with 1' do
      let(:accredited_provider_id) { '12345' }

      it 'adds an error' do
        expect(model).to be_invalid
        expect(model.errors.first.type.to_s).to eq('format')
      end
    end

    context 'with a UKPRN begining with 1 then 4 letters' do
      let(:accredited_provider_id) { '1AAA' }

      it 'adds an error' do
        expect(model).to be_invalid
        expect(model.errors.first.type.to_s).to eq('format')
      end
    end
  end
end
