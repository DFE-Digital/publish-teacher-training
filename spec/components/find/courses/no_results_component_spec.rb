# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::NoResultsComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:component) do
    render_inline(
      described_class.new(country:, minimum_degree_required:, subjects:),
    )
  end

  let(:country) { nil }
  let(:minimum_degree_required) { nil }
  let(:subjects) { [] }

  context "when the search is in Scotland" do
    let(:country) { "Scotland" }

    it "renders the devolved nation heading" do
      expect(component).to have_css("h2.govuk-heading-m", text: I18n.t("courses.no_results_component.devolved_nation.heading"))
    end

    it "includes a link to information about teacher training in the devolved nation" do
      link_text = I18n.t("courses.no_results_component.devolved_nation.scotland.link_content")
      link_url = find_track_click_path(url: I18n.t("courses.no_results_component.devolved_nation.scotland.link"))

      expect(component).to have_link(link_text, href: link_url)
    end
  end

  context "when the search is in Wales" do
    let(:country) { "Wales" }

    it "renders the devolved nation heading" do
      expect(component).to have_css("h2.govuk-heading-m", text: I18n.t("courses.no_results_component.devolved_nation.heading"))
    end

    it "includes a link to information about teacher training in the devolved nation" do
      link_text = I18n.t("courses.no_results_component.devolved_nation.wales.link_content")
      link_url = find_track_click_path(url: I18n.t("courses.no_results_component.devolved_nation.wales.link"))

      expect(component).to have_link(link_text, href: link_url)
    end
  end

  context "when the search is in Northern Ireland" do
    let(:country) { "Northern Ireland" }

    it "renders the devolved nation heading" do
      expect(component).to have_css("h2.govuk-heading-m", text: I18n.t("courses.no_results_component.devolved_nation.heading"))
    end

    it "includes a link to information about teacher training in the devolved nation" do
      link_text = I18n.t("courses.no_results_component.devolved_nation.northern_ireland.link_content")
      link_url = find_track_click_path(url: I18n.t("courses.no_results_component.devolved_nation.northern_ireland.link"))

      expect(component).to have_link(link_text, href: link_url)
    end
  end

  context "when there are no results in England" do
    let(:country) { "England" }

    it "renders the try another search message" do
      expect(component).to have_content(
        I18n.t("courses.no_results_component.try_another_search_content", count: 0),
      )
    end

    context "when searching by multiple subjects" do
      let(:subjects) { [1, 2] }

      it "renders the try another search message" do
        expect(component).to have_content(
          I18n.t("courses.no_results_component.try_another_search_content", count: 2),
        )
      end
    end
  end

  context "when searching for teacher degree apprenticeship courses" do
    let(:minimum_degree_required) { "no_degree_required" }

    it "renders the undergraduate message with contact support email" do
      expect(component).to have_content(
        I18n.t("courses.no_results_component.undergraduate.message_html", contact: Settings.support_email),
      )
    end

    it "includes a link to find out more about teacher degree apprenticeships" do
      link_text = I18n.t("courses.no_results_component.undergraduate.find_out_more_about_tda")
      link_url = find_track_click_path(url: I18n.t("find.get_into_teaching.url_tda"))

      expect(component).to have_link(link_text, href: link_url)
    end
  end
end
