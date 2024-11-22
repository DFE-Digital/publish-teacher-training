# frozen_string_literal: true

require 'rails_helper'

module Exports
  describe AccreditedCourseList do
    let(:course) do
      create(
        :course,
        site_statuses: [create(:site_status, :full_time_vacancies, :findable)],
        enrichments: [build(:course_enrichment, :published)]
      )
    end

    let(:decorated_course) { CourseDecorator.new(course) }

    subject { described_class.new(courses: Course.where(id: course)) }

    describe '#data' do
      let(:expected_output) do
        {
          'Provider code' => decorated_course.provider.provider_code,
          'Provider' => decorated_course.provider.provider_name,
          'Course code' => decorated_course.course_code,
          'Course' => decorated_course.name,
          'Study mode' => decorated_course.study_mode&.humanize,
          'Programme type' => decorated_course.program_type&.humanize,
          'Qualification' => decorated_course.outcome,
          'Status' => decorated_course.content_status&.to_s&.humanize,
          'View on Find' => decorated_course.find_url,
          'Applications open from' => I18n.l(decorated_course.applications_open_from&.to_date),
          'Campus Codes' => decorated_course.sites&.map(&:code)&.join(' ')
        }
      end

      it 'sets the correct headers' do
        expect(subject.data.lines[0].strip).to eq(expected_output.keys.join(','))
      end

      it 'sets the correct row values' do
        expect(subject.data.lines[1].strip).to eq(expected_output.values.join(','))
      end
    end
  end
end
