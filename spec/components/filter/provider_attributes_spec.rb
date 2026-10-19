# frozen_string_literal: true

require "rails_helper"

module Filters
  describe ProviderAttributes do
    include Rails.application.routes.url_helpers

    alias_method :component, :page

    let(:filters) { nil }
    let(:year) { Find::CycleTimetable.current_year }

    before do
      with_request_url "/support/#{year}/providers", host: "publish.localhost" do
        render_inline(described_class.new(filters: {}))
      end
    end

    it "renders all the correct details" do
      expect(component).to have_text("Provider name, code or UKPRN")
      expect(component).to have_text("Course code")
    end

    it "wires the provider search to autocomplete" do
      expect(component).to have_css('[data-controller="remote-autocomplete"]')
      expect(component).to have_css(
        %(div[data-remote-autocomplete-path-value="#{suggest_support_recruitment_cycle_providers_path(year)}"]),
      )
    end
  end
end
