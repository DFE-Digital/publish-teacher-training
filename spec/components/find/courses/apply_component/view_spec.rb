# frozen_string_literal: true

require 'rails_helper'

describe Find::Courses::ApplyComponent::View, type: :component do
  let(:provider) { build(:provider) }

  context 'it is mid cycle' do
    before do
      allow(Find::CycleTimetable).to receive(:mid_cycle?).and_return(true)
    end

    it 'renders the apply button when the course is open' do
      course = build(:course, :open, provider:)

      result = render_inline(described_class.new(course))

      expect(result).to have_link('Apply for this course', href: "/publish/organisations/#{course.provider.provider_code}/#{course.provider.recruitment_cycle.year}/courses/#{course.course_code}/apply")
    end

    context "using 'Find::CoursesController'" do
      it 'renders the apply button when the course is open' do
        course = build(:course, :open, provider:)
        result = with_controller_class(Find::CoursesController) do
          render_inline(described_class.new(course))
        end

        expect(result).to have_link('Apply for this course', href: "/course/#{course.provider.provider_code}/#{course.course_code}/apply")
      end
    end

    it "renders a 'closed for applications' warning when the course is closed" do
      course = build(:course, :closed, provider:, site_statuses: [create(:site_status, :unpublished, :running)])

      result = render_inline(described_class.new(course))

      expect(result.text).to include('This course is not accepting applications at the moment.')
    end

    context 'when the course has a deadline for candidates who require visa sponsorship' do
      before { FeatureFlag.activate(:visa_sponsorship_deadline) }

      it 'renders the deadline' do
        deadline = 2.days.from_now.change(hour: 11, min: 59)
        course = build(
          :course,
          :open,
          :can_sponsor_student_visa,
          visa_sponsorship_application_deadline_at: deadline,
          provider:
        )

        result = render_inline(described_class.new(course))

        expect(result.text).to include "Non-UK citizens, apply by #{deadline.to_fs(:govuk_date)}"
      end
    end
  end

  context 'it is not mid cycle' do
    it 'displays that courses are currently closed' do
      allow(Find::CycleTimetable).to receive(:mid_cycle?).and_return(false)

      course = build(:course, :closed, provider:)

      result = render_inline(described_class.new(course))

      expect(result.text).to include('Courses are currently closed')
    end
  end
end
