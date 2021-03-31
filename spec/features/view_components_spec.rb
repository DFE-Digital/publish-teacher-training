# frozen_string_literal: true

require "rails_helper"

RSpec.feature "view components" do
  all_links = (ViewComponent::Preview.all.map do |component|
    component.examples.map do |example|
      "#{Rails.application.config.view_component.preview_route}/#{component.preview_name}/#{example}"
    end
  end).flatten

  shared_examples "navigate to" do |link|
    scenario "navigate to #{link}" do
      visit link

      expect(page.status_code).to eq(200)
      expect(page).to have_css("#main-content")
    end
  end

  all_links.each do |link|
    include_examples "navigate to", link
  end
end
