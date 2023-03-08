# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'gias_update' do
  Rails.application.load_tasks if Rake::Task.tasks.empty?

  subject do
    Rake::Task['gias_update'].invoke('spec/fixtures/test_schools.csv')
  end

  it 'calls GiasImport service' do
    expect(CSVImports::GiasImport).to receive(:new).with('spec/fixtures/test_schools.csv').and_call_original
    subject
  end
end
