# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'creates providers partnerships from enrichments' do
  subject do
    Rake::Task['provider_partnerships:create_from_enrichments'].invoke
  end

  let!(:accredited_provider) { create(:accredited_provider) }
  let!(:description) { 'The Description' }
  let!(:training_provider) { create(:provider, accrediting_provider_enrichments: [AccreditingProviderEnrichment.new(UcasProviderCode: accredited_provider.provider_code, Description: description)]) }

  Rails.application.load_tasks if Rake::Task.tasks.empty?

  it 'creates accredited partnerships for training partners from their enrichments' do
    expect { subject }.to change(training_provider.accredited_partnerships, :count).by(1)
    expect(training_provider.accredited_partnerships.last).to have_attributes(
      description: 'The Description',
      accredited_provider_id: accredited_provider.id
    )
  end
end
