# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Support', service: :publish do
  include DfESignInUserHelper

  let(:courses) do
    [
      create(:course, :unpublished, :with_full_time_sites),
      create(:course, :published, :with_full_time_sites),
      create(:course, :withdrawn, :with_full_time_sites)
    ]
  end
  let!(:source_provider) { create(:provider, provider_name: 'Source Provider', courses:) }
  let!(:target_provider) { create(:provider, provider_name: 'Target Provider') }
  let(:user) { create(:user, :admin) }

  before do
    sign_in_system_test(user:)
  end

  # TODO: Javascript tests cannot run on CI
  # The test running cannot find the chromedriver
  #
  # > Errno::ENOENT:
  # >       No such file or directory - /root/.cache/selenium/chromedriver/linux64/131.0.6778.87/chromedriver
  #
  it 'copy courses from one provider to another', :js do
    pending('Javascript tests cannot run on CI')
    visit '/support'
    click_on 'Target Provider'
    click_on 'Courses'
    click_on 'Copy Courses'
    autocomplete = page.find('input#provider')
    autocomplete.set(source_provider.provider_code)
    sleep 3
    li = page.find('ul#provider__listbox li', visible: false)
    li.click
    page.find_by_id('schools-true-field', visible: false).click
    click_on 'Copy courses'
    click_on 'Courses'
    courses.map(&:name).each do |course_name|
      expect(page).to have_content(course_name)
    end
  end
end
