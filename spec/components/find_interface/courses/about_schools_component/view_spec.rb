require "rails_helper"

describe FindInterface::Courses::AboutSchoolsComponent::View, type: :component do
  context "valid program_type" do
    it "renders the component" do
      %w[higher_education_programme scitt_programme].each do |program_type|
        provider = build(:provider)
        course = build(:course,
          provider:,
          program_type:).decorate

        result = render_inline(described_class.new(course))

        expect(result.text).to include(course.placements_heading)
      end
    end
  end

  context "invalid program type" do
    it "does not render" do
      provider = build(:provider)
      course = build(:course,
        provider:).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include(course.placements_heading)
    end
  end

  context "course with multiple sites" do
    it "renders the component" do
      provider = build(:provider)
      course = build(:course,
        provider:,
        site_statuses: [
          build(:site_status, site: build(:site)),
          build(:site_status, site: build(:site)),
        ]).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include(course.placements_heading)
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

      result = render_inline(described_class.new(course))

      expect(result.text).not_to include(course.placements_heading)
    end
  end

  context "higher_education_programme" do
    it "renders the HEI where will you train advice box" do
      provider = build(:provider)

      course = build(:course,
        provider:,
        program_type: "higher_education_programme").decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("Universities can work with over 100 potential placement schools.")
    end

    context "Provider is The Bedfordshire Schools Training Partnership" do
      it "does not render the HEI where will you train advice box" do
        provider = build(
          :provider,
          provider_name: "The Bedfordshire Schools Training Partnership",
          provider_code: "B31",
          provider_type: "scitt",
          website: "https://scitt.org",
          address1: "1 Long Rd",
          postcode: "E1 ABC",
        )

        course = build(:course,
          provider:,
          program_type: "higher_education_programme").decorate

        result = render_inline(described_class.new(course))

        expect(result.text).not_to include("Universities can work with over 100 potential placement schools. Most will be within 10 miles of the university")
      end
    end
  end

  context "scitt_programme" do
    it "renders the SCITT where will you train advice box" do
      provider = build(:provider)

      course = build(:course,
        provider:,
        program_type: "scitt_programme").decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("You’ll be placed in different schools during your training.")
    end

    context "Provider is Educate Teacher Training" do
      it "does not render the SCITT where will you train advice box" do
        provider = build(
          :provider,
          provider_name: "Educate Teacher Training",
          provider_code: "E65",
          provider_type: "scitt",
          website: "https://scitt.org",
          address1: "1 Long Rd",
          postcode: "E1 ABC",
        )

        course = build(:course,
          provider:,
          program_type: "scitt_programme").decorate

        result = render_inline(described_class.new(course))

        expect(result.text).not_to include("You’ll be placed in different schools during your training. You can’t pick which schools you want to be in")
      end
    end
  end

  %w[pg_teaching_apprenticeship school_direct_training_programme school_direct_salaried_training_programme].each do |programme_type|
    context programme_type.to_s do
      it "does not render the where will you train advice box" do
        provider = build(:provider)

        course = build(:course,
          provider:).decorate

        result = render_inline(described_class.new(course))

        expect(result.text).not_to include("Advice from Get Into Teaching Where you will train")
      end
    end
  end
end
