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
      expected_url = "/publish/organisations/#{course.provider.provider_code}/#{course.provider.recruitment_cycle.year}/courses/#{course.course_code}/apply"

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

      it "renders the apply button without tracking when previewing the open course" do
        course = build(:course, :open, provider:)
        result = with_controller_class(Find::CoursesController) do
          render_inline(described_class.new(course, preview: true))
        end

        expect(result).to have_link("Apply for this course", href: "/course/#{course.provider.provider_code}/#{course.course_code}/apply")
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

        expect(result.text).to include "Non-UK citizens, apply by #{deadline.to_fs(:govuk_date)}"
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
end
