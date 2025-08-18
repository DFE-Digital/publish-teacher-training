require "rails_helper"

RSpec.describe Publish::Schools::SchoolSummaryValueComponent, type: :component do
  subject(:component) { described_class.new(course: course.decorate) }

  describe "#inset_class" do
    context "when schools are validated" do
      let(:course) { build(:course, :unpublished) }

      before do
        allow(course).to receive(:schools_validated?).and_return(true)
      end

      it "returns nil" do
        expect(component.inset_class).to be_nil
      end
    end

    context "when schools are not validated and course has site errors" do
      let(:course) { build(:course, :unpublished, schools_validated: false) }

      before do
        course.errors.add(:sites, "must be selected")
      end

      it "returns inset class with error" do
        expect(component.inset_class)
          .to eq("govuk-inset-text app-inset-text--narrow-border app-inset-text--error")
      end
    end

    context "when schools are not validated and no site errors" do
      let(:course) { build(:course, :unpublished, schools_validated: false) }

      it "returns inset class with important" do
        expect(component.inset_class)
          .to eq("govuk-inset-text app-inset-text--narrow-border app-inset-text--important")
      end
    end
  end

  describe "#enter_school_text" do
    let(:rendered) { render_inline(component) }

    context "when the course has no associated sites" do
      let(:course) { build(:course, sites: []) }

      it "returns the enter schools string" do
        expect(rendered.text).to include(
          I18n.t("publish.schools.school_summary_value_component.enter_schools"),
        )
      end
    end

    context "when the course has at least one site" do
      let(:site)   { build(:site) }
      let(:course) { create(:course, sites: [site]) }

      it "returns the check schools string" do
        expect(rendered.text).to include(
          I18n.t("publish.schools.school_summary_value_component.check_schools"),
        )
      end
    end
  end

  describe "#enter_school_link" do
    let(:rendered) { render_inline(component) }
    let(:course) { build(:course) }
    let(:enter_school_link) { rendered.css("a").first["href"] }

    it "generates the correct publish path with provider, recruitment cycle and course code" do
      expect(enter_school_link).to eq(
        Rails.application.routes.url_helpers.schools_publish_provider_recruitment_cycle_course_path(
          course.provider.provider_code,
          course.provider.recruitment_cycle.year,
          course.course_code,
          nil, # no errors
        ),
      )
    end

    context "when the course has validation errors" do
      let(:course) { build(:course) }

      before { course.errors.add(:base, "Some error") }

      it "includes extra_link_arguments" do
        expect(enter_school_link).to eq(
          Rails.application.routes.url_helpers.schools_publish_provider_recruitment_cycle_course_path(
            course.provider.provider_code,
            course.provider.recruitment_cycle.year,
            course.course_code,
            { display_errors: true },
          ),
        )
      end
    end
  end

  describe "#extra_link_arguments" do
    context "when the course has no errors" do
      let(:course) { build(:course) }

      it "returns nil" do
        expect(component.extra_link_arguments).to be_nil
      end
    end

    context "when the course has errors" do
      let(:course) { build(:course) }

      before { course.errors.add(:sites, "must be present") }

      it "returns {display_errors: true}" do
        expect(component.extra_link_arguments).to eq(display_errors: true)
      end
    end
  end
end
