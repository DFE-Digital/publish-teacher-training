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
