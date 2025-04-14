# frozen_string_literal: true

require "rails_helper"

describe Shared::Courses::SchoolPlacementsAdvice::View, type: :component do
  include Rails.application.routes.url_helpers

  context "salaried course" do
    it "renders the correct content" do
      provider = build(:provider, selectable_school: false)
      course = build(
        :course,
        funding: "salary",
        provider:,
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result).to have_css(".app-callout__title", text: "How school placements work")
      expect(result.text).to include("Check with the provider before applying. They may require you to find your own school or want to discuss your situation to help them choose a school you can travel to.")
      expect(result.text).not_to include("Find out more about how school placements work")
    end
  end

  context "fee paying course" do
    it "renders the correct content" do
      provider = build(:provider, selectable_school: false)
      course = build(
        :course,
        funding: "fee",
        provider:,
      ).decorate

      result = render_inline(described_class.new(course))

      expect(result).to have_css(".app-callout__title", text: "How school placements work")
      expect(result.text).to include("The training provider will select placement schools for you. They will contact you and discuss your situation to help them select a location that you can travel to.")
      expect(result.text).to include("Find out more about how school placements work")
    end
  end

  context "when the course allows selecting a placement location" do
    it "displays the correct placement message" do
      provider = build(:provider, selectable_school: true)
      course = build(:course, provider:).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("You will be able to select a preferred placement school, but there is no guarantee you will be placed in the school you have chosen. The training provider will contact you to discuss your choice to help them select a location that suits you.")
      expect(result.text).to include("Find out more about how school placements work")
      expect(result.text).to include("The training provider will contact you to discuss your choice to help them select a location that suits you.")
      expect(result.text).not_to include("Advice from Get Into Teaching")
    end
  end
end
