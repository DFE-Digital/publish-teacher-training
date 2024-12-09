# frozen_string_literal: true

require 'rails_helper'

describe ProviderPartnership do
  let(:partnership) { create(:provider_partnership, description: 'Great partnership') }

  it 'creates a partnership' do
    expect(partnership.accredited_provider).to be_accredited
    expect(partnership.training_provider).not_to be_accredited
  end

  it 'has a description' do
    expect(partnership.description).to eq('Great partnership')
  end

  describe 'validations' do
    before { subject.validate }

    context 'blank accredited provider' do
      subject(:partnership) { build(:provider_partnership, accredited_provider: nil) }

      it 'has correct error message' do
        expect(subject.errors.messages[:accredited_provider]).to include('Accredited provider must exist')
      end
    end

    context 'duplicate record' do
      subject(:duplicate) { build(:provider_partnership, accredited_provider: partnership.accredited_provider, training_provider: partnership.training_provider) }

      let(:partnership) { create(:provider_partnership) }

      it 'has correct error message' do
        duplicate.validate
        expect(duplicate.errors.messages[:accredited_provider]).to include('This partnership already exists')
      end
    end

    context 'accredited provider must be accredited' do
      subject(:partnership) { build(:provider_partnership, accredited_provider: build(:provider)) }

      it 'has correct error message' do
        expect(subject.errors.messages[:accredited_provider]).to include('Accredited provider must be accredited')
      end
    end

    context 'accredited provider must not be accredited' do
      subject(:partnership) { build(:provider_partnership, training_provider: build(:accredited_provider)) }

      it 'has correct error message' do
        expect(subject.errors.full_messages).to include('Training provider must not be accredited')
      end
    end

    context 'blank training provider' do
      subject(:partnership) { build(:provider_partnership, training_provider: nil) }

      it 'has correct error message' do
        expect(subject.errors.full_messages).to include('Training provider must exist')
      end
    end
  end
end
