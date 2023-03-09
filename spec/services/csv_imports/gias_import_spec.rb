# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CSVImports::GiasImport do
  subject do
    described_class.call('spec/fixtures/test_schools.csv')
  end

  it 'upserts the correct schools' do
    expect { subject }.to change(GiasSchool, :count).from(0).to(2)
  end

  it 'logs info messages' do
    allow(Rails.logger).to receive(:info)
    subject
    expect(Rails.logger).to have_received(:info).with('Done! 2 schools upserted')
    expect(Rails.logger).to have_received(:info).with("Errors - [{:name=>[\"can't be blank\"]}, 2]")
  end
end
