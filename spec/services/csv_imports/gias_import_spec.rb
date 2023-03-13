# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CSVImports::GiasImport do
  subject do
    described_class.call('spec/fixtures/test_schools.csv')
  end

  it 'upserts the correct schools' do
    expect { subject }.to change(GiasSchool, :count).from(0).to(2)
  end

  it 'logs messages to STDOUT' do
    expect { subject }.to output(
      match(/Done! 2 schools upserted/)
      .and(match(/Failures 1/))
      .and(match(/Errors - /))
      .and(match(/:name=>/))
      .and(match(/"can't be blank"/))
    ).to_stdout
  end
end
