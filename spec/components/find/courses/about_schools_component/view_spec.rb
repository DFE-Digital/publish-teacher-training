# frozen_string_literal: true

require "rails_helper"

describe Find::Courses::AboutSchoolsComponent::View, type: :component do
  include Rails.application.routes.url_helpers
  coordinates = { latitude: 51.509865, longitude: -0.118092, formatted_address: "London, UK" }
  distance_from_location = 10

  context "invalid program type" do
    it "renders the component" do
      provider = build(:provider)
      course = build(:course,
                     provider:).decorate

      result = render_inline(described_class.new(course, coordinates, distance_from_location))
      expect(result.text).to include("Enter details about how placements work")
    end
  end

  context "salaried course" do
    it "renders the correct content" do
      provider = build(:provider, selectable_school: false)
      course = build(
        :course,
        funding: "salary",
        provider:,
      ).decorate

      result = render_inline(described_class.new(course, coordinates, distance_from_location))

      expect(result.text).to include("You will spend most of your time in one school which will employ you. You will also spend some time in another school and at a location where you will study.")
      expect(result).to have_css(".app-callout__title", text: "How school placements work")
      expect(result.text).to include("Check with the provider before applying. They may require you to find your own school or want to discuss your situation to help them choose a school you can travel to.")
      expect(result.text).not_to include("Find out more about how school placements work")
    end
  end

  context "apprenticeship course" do
    it "renders the correct content" do
      course = build(:course,
                     funding: "apprenticeship").decorate

      result = render_inline(described_class.new(course, coordinates, distance_from_location))

      expect(result.text).to include("You will spend most of your time in one school which will employ you. You will also spend some time in another school and at a location where you will study.")
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

      result = render_inline(described_class.new(course, coordinates, distance_from_location))

      expect(result.text).to include("You will spend a minimum of 24 weeks on school placements. This time is spread across at least 2 schools. You will also spend time in a location to study.")
      expect(result).to have_css(".app-callout__title", text: "How school placements work")
      expect(result.text).to include("Find out more about how school placements work")
      expect(result.text).to include("The training provider will select placement schools for you. They will contact you and discuss your situation to help them select a location that you can travel to.")
    end
  end

  context "when the course allows selecting a placement location" do
    it "displays the correct placement message" do
      provider = build(:provider, selectable_school: true)
      course = build(:course, provider:).decorate

      result = render_inline(described_class.new(course, coordinates, distance_from_location))

      expect(result.text).not_to include("Advice from Get Into Teaching")
      expect(result.text).to include("You will be able to select a preferred placement school, but there is no guarantee you will be placed in the school you have chosen.")
      expect(result.text).to include("Find out more about how school placements work")
      expect(result.text).to include("The training provider will contact you to discuss your choice to help them select a location that suits you.")
    end
  end

  context "course without multiple sites" do
    it "renders the component" do
      provider = build(:provider)
      course = build(:course,
                     provider:,
                     site_statuses: [
                       build(:site_status, site: build(:site)),
                     ]).decorate
      result = render_inline(described_class.new(course, coordinates, distance_from_location))

      expect(result.text).to include("Enter details about how placements work")
    end
  end
end
