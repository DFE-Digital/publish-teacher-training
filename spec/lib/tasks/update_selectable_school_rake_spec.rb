# frozen_string_literal: true

require 'rails_helper'
require 'rake'

describe 'set_selectable_schools' do
  Rails.application.load_tasks if Rake::Task.tasks.empty?
  subject(:set_selectable_schools_task) do
    Rake::Task['set_selectable_schools'].invoke
  end

  let(:target_provider) { create(:provider, provider_code: 'E65', selectable_school: false) }
  let(:ignore_provider) { create(:provider, provider_code: 'Z00', selectable_school: false) }

  it 'updates the providers selectable_school to true' do
    expect(target_provider.selectable_school).to be(false)
    expect(ignore_provider.selectable_school).to be(false)

    set_selectable_schools_task

    expect(target_provider.reload.selectable_school).to be(true)
    expect(ignore_provider.reload.selectable_school).to be(false)
  end
end
