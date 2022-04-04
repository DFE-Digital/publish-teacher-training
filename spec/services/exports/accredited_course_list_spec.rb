# frozen_string_literal: true

require "rails_helper"

module Exports
  describe AccreditedCourseList do
    let(:course) do
      CourseDecorator.new(
        create(
          :course,
          site_statuses: [create(:site_status, :full_time_vacancies, :findable)],
          enrichments: [build(:course_enrichment, :published)],
        ),
      )
    end

    subject { described_class.new([course]) }

    describe "#data" do
      let(:expected_output) do
        {
          "Provider code" => course.provider.provider_code,
          "Provider" => course.provider.provider_name,
          "Course code" => course.course_code,
          "Course" => course.name,
          "Study mode" => course.study_mode&.humanize,
          "Programme type" => course.program_type&.humanize,
          "Qualification" => course.outcome,
          "Status" => course.content_status&.to_s&.humanize,
          "View on Find" => course.find_url,
          "Applications open from" => I18n.l(course.applications_open_from&.to_date),
          "Vacancies" => "Yes",
        }
      end

      it "sets the correct headers" do
        expect(subject.data).to include(expected_output.keys.join(","))
      end

      it "sets the correct row values" do
        expect(subject.data).to include(expected_output.values.join(","))
      end
    end
  end
end
