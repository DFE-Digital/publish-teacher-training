# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProviderPartnership do
  let(:partnership) { create(:provider_partnership) }

  it 'creates a partnership' do
    expect(partnership.accredited_provider).to be_accredited
  end

  describe 'validations' do
    before { subject.validate }

    context 'blank accredited provider' do
      subject(:partnership) { build(:provider_partnership, accredited_provider: nil) }

      it 'has correct error message' do
        expect(subject.errors.full_messages).to include('Accredited provider must exist')
      end
    end

    context 'accredited provider must be accredited' do
      subject(:partnership) { build(:provider_partnership, accredited_provider: build(:provider)) }

      it 'has correct error message' do
        expect(subject.errors.full_messages).to include('Accredited provider must be accredited')
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
