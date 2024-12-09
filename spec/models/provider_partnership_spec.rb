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
end
