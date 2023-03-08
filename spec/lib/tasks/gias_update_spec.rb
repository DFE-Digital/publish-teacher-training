# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'gias_update' do
  Rails.application.load_tasks if Rake::Task.tasks.empty?
  subject do
    Rake::Task['gias_update'].invoke(csv_path)
  end

  let(:csv_path) { 'spec/fixtures/test_schools.csv' }

  it 'calls GiasImport service' do
    expect(CSVImports::GiasImport).to receive(:new).with(csv_path).and_call_original
    subject
  end
end
