# frozen_string_literal: true

require "rails_helper"

RSpec.describe "view components" do
  shared_examples "navigate to" do |link|
    scenario "navigate to #{link}" do
      visit link

      expect(page.status_code).to eq(200)
    end
  end

  all_links = ViewComponent::Preview.all.map { |component|
    component.examples.map do |example|
      "#{Rails.application.config.view_component.preview_route}/#{component.preview_name}/#{example}"
    end
  }.flatten

  all_links.each do |link|
    include_examples "navigate to", link
  end
end
