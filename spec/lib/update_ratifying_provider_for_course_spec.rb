# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UpdateRatifyingProviderForCourse do
  let(:current_ratifying_provider) { create(:accredited_provider) }
  let(:target_ratifying_provider) { create(:accredited_provider) }
  let!(:provider) { create(:provider, courses: [create(:course, accrediting_provider: current_ratifying_provider)]) }

  it 'changes the ratifying provider from current to target' do
    described_class.new(training_provider_code: provider.provider_code, target_ratifying_provider_code: target_ratifying_provider.provider_code).call
    expect(provider.courses.reload.first.accrediting_provider).to eq(target_ratifying_provider)
  end
end
