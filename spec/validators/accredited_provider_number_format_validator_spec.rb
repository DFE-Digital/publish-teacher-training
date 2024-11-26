# frozen_string_literal: true

require 'rails_helper'

class AccreditedProviderNumberFormatValidatorTest
  include ActiveModel::Validations

  attr_accessor :accredited_provider_number

  validates :accredited_provider_number, accredited_provider_number_format: { allow_blank: false }
end

describe AccreditedProviderNumberFormatValidator do
  let(:accredited_provider) { create(:provider, :accredited_provider, :university) }
  let(:accredited_provider_number) { 1234 }

  let(:model) do
    model = accredited_provider
    model.accredited_provider_number = accredited_provider_number
    model
  end

  describe 'university validation' do
    context 'with a valid id starting with 1' do
      it 'does not add an error' do
        expect(model).to be_valid
      end
    end

    context 'with a valid id starting with 5' do
      let(:accredited_provider_number) { 5432 }

      it 'does not add an error' do
        expect(model).not_to be_valid
      end
    end
  end

  describe 'scitt validation' do
    let(:accredited_provider) { create(:provider, :accredited_provider, :scitt) }

    context 'with a valid id starting with 1' do
      it 'does add an error' do
        expect(model).not_to be_valid
      end
    end

    context 'with a valid id starting with 5' do
      let(:accredited_provider_number) { 5432 }

      it 'does not add an error' do
        expect(model).to be_valid
      end
    end
  end

  describe 'lead school validation' do
    let(:accredited_provider) { create(:provider, :accredited_provider, :lead_school) }

    context 'with a valid id starting with 1' do
      it 'adds provider_type error' do
        model.valid?
        expect(model.errors.attribute_names).to eq([:provider_type])
      end
    end

    context 'with a valid id starting with 5' do
      let(:accredited_provider_number) { 5432 }

      it 'adds provider_type error' do
        model.valid?
        expect(model.errors.attribute_names).to eq([:provider_type])
      end
    end
  end
end
