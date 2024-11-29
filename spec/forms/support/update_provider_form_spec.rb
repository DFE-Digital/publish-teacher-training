# frozen_string_literal: true

require 'rails_helper'

module Support
  describe UpdateProviderForm, type: :model do
    let(:provider) { create(:provider, :accredited_provider) }
    let(:update_provider_form) { described_class.new(provider, attributes:) }
    let(:attributes) { attributes_for(:provider, :accredited_provider) }

    subject { update_provider_form }

    describe '#save' do
      context 'provider is changed from accredited_provider to not accredited_provider' do
        let(:attributes) { { accrediting_provider: 'not_an_accredited_provider' } }

        it 'removes the accredited_provider_number' do
          expect { subject.save }.to change(provider.reload, :accredited_provider_number).from(provider.accredited_provider_number).to(nil)
        end
      end
    end
  end
end
