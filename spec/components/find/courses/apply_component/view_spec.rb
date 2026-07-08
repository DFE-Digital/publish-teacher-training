# frozen_string_literal: true

require "rails_helper"

describe Find::Courses::ApplyComponent::View, type: :component do
  include Rails.application.routes.url_helpers

  let(:provider) { build(:provider) }
  let(:utm_content) { "apply_button" }

  context "it is mid cycle" do
    before do
      allow(Find::CycleTimetable).to receive(:mid_cycle?).and_return(true)
    end

    it "renders the apply button when the course is open" do
      course = build(:course, :open, provider:)

      result = render_inline(described_class.new(course, preview: false, utm_content: utm_content))
      expected_url = "/course/#{course.provider.provider_code}/#{course.course_code}/apply"

      expect(result).to have_link("Apply for this course", href: find_track_click_path(url: expected_url, utm_content: utm_content))
    end

    context "using 'Find::CoursesController'" do
      it "renders the apply button when the course is open" do
        course = build(:course, :open, provider:)
        result = with_controller_class(Find::CoursesController) do
          render_inline(described_class.new(course, preview: false, utm_content: utm_content))
        end

        expected_url = find_track_click_path(url: "/course/#{course.provider.provider_code}/#{course.course_code}/apply", utm_content: utm_content)

        expect(result).to have_link("Apply for this course", href: expected_url)
      end

      it "routes through school experience interstitial for salaried courses that require school experience" do
        course = build(:course, :open, :salary, school_experience_required: true, provider:)
        allow(course).to receive(:show_school_experience?).and_return(true)
        result = with_controller_class(Find::CoursesController) do
          render_inline(described_class.new(course, preview: false, utm_content: utm_content))
        end

        expected_url = find_track_click_path(url: "/course/#{course.provider.provider_code}/#{course.course_code}/school-experience-interstitial", utm_content: utm_content)

        expect(result).to have_link("Apply for this course", href: expected_url)
      end

      it "does not route fee-funded courses through confirm apply" do
        course = build(:course, :open, :fee, school_experience_required: false, provider:)
        result = with_controller_class(Find::CoursesController) do
          render_inline(described_class.new(course, preview: false, utm_content: utm_content))
        end

        expected_url = find_track_click_path(url: "/course/#{course.provider.provider_code}/#{course.course_code}/apply", utm_content: utm_content)

        expect(result).to have_link("Apply for this course", href: expected_url)
      end

      it "renders the apply button without tracking when previewing the open course" do
        course = build(:course, :open, provider:)
        result = with_controller_class(Find::CoursesController) do
          render_inline(described_class.new(course, preview: true))
        end

        expect(result).to have_link(
          "Apply for this course",
          href: "/publish/organisations/#{course.provider.provider_code}/#{course.provider.recruitment_cycle.year}/courses/#{course.course_code}/apply",
        )
      end
    end

    it "renders a 'closed for applications' warning when the course is closed" do
      course = build(:course, :closed, provider:, site_statuses: [create(:site_status, :unpublished, :running)])

      result = render_inline(described_class.new(course, preview: false))

      expect(result.text).to include("This course is not accepting applications at the moment.")
    end

    context "when the course has a deadline for candidates who require visa sponsorship" do
      it "renders the deadline" do
        deadline = 2.days.from_now.change(hour: 11, min: 59)
        course = build(
          :course,
          :open,
          :can_sponsor_student_visa,
          visa_sponsorship_application_deadline_at: deadline,
          provider:,
        )

        result = render_inline(described_class.new(course, preview: false))

        expect(result.text).to include "Non-UK citizens, apply before #{deadline.to_fs(:govuk_date)}"
      end
    end
  end

  context "it is not mid cycle" do
    it "displays that courses are currently closed" do
      allow(Find::CycleTimetable).to receive(:mid_cycle?).and_return(false)

      course = build(:course, :closed, provider:)

      result = render_inline(described_class.new(course, preview: false))

      expect(result.text).to include("Courses are currently closed")
    end
  end

  describe "method behavior" do
    let(:component) { described_class.new(course, preview:, utm_content:) }
    let(:preview) { false }

    def render_component
      with_controller_class(Find::CoursesController) do
        render_inline(component)
      end
    end

    describe "#apply_path" do
      context "when school experience interstitial is required" do
        let(:course) { build(:course, :open, :salary, provider:) }

        it "returns the school experience interstitial path" do
          allow(course).to receive(:school_experience_interruption_required?).and_return(true)

          render_component

          expect(component.apply_path).to eq("/course/#{course.provider.provider_code}/#{course.course_code}/school-experience-interstitial")
        end
      end

      context "when candidate accounts are enabled and no interstitial is needed" do
        let(:course) { build(:course, :open, provider:) }

        it "returns the confirm apply path" do
          allow(course).to receive(:school_experience_interruption_required?).and_return(false)
          allow(FeatureFlag).to receive(:active?).with(:candidate_accounts).and_return(true)

          render_component

          expect(component.apply_path).to eq("/course/#{course.provider.provider_code}/#{course.course_code}/confirm-apply")
        end
      end

      context "when neither interstitial nor confirm apply is needed" do
        let(:course) { build(:course, :open, provider:) }

        it "returns the apply path" do
          allow(course).to receive(:school_experience_interruption_required?).and_return(false)
          allow(FeatureFlag).to receive(:active?).with(:candidate_accounts).and_return(false)

          render_component

          expect(component.apply_path).to eq("/course/#{course.provider.provider_code}/#{course.course_code}/apply")
        end
      end

      context "when previewing" do
        let(:course) { build(:course, :open, provider:) }
        let(:preview) { true }

        it "returns the publish apply path" do
          render_component

          expect(component.apply_path).to eq("/publish/organisations/#{course.provider.provider_code}/#{course.provider.recruitment_cycle.year}/courses/#{course.course_code}/apply")
        end
      end
    end

    describe "#show_application_deadline?" do
      context "when a visa sponsorship deadline is present" do
        let(:course) { build(:course, :open, visa_sponsorship_application_deadline_at: Time.zone.parse("2027-02-01 11:59"), provider:) }

        it "returns true" do
          expect(component.show_application_deadline?).to be(true)
        end
      end

      context "when a visa sponsorship deadline is absent" do
        let(:course) { build(:course, :open, visa_sponsorship_application_deadline_at: nil, provider:) }

        it "returns false" do
          expect(component.show_application_deadline?).to be(false)
        end
      end
    end

    describe "#application_deadline" do
      let(:deadline) { Time.zone.parse("2027-02-01 11:59") }
      let(:course) { build(:course, :open, visa_sponsorship_application_deadline_at: deadline, provider:) }

      it "returns the deadline in govuk date format" do
        expect(component.application_deadline).to eq(deadline.to_fs(:govuk_date))
      end
    end
  end
end
