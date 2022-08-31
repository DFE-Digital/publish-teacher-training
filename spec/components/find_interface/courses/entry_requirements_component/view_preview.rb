# frozen_string_literal: true

module FindInterface::Courses::EntryRequirementsComponent
  class ViewPreview < ViewComponent::Preview
    def qualifications_needed_only
      course = Course.new(course_code: "FIND",
        provider: Provider.new(provider_code: "DFE"),
        additional_degree_subject_requirements: true,
        degree_subject_requirements: "Degree Subject Requirements Text",
        level: "secondary",
        additional_gcse_equivalencies: "Additional GCSE Equivalencies Text")

      render FindInterface::Courses::EntryRequirementsComponent::View.new(course: course.decorate)
    end

    def fully_populated
      render FindInterface::Courses::EntryRequirementsComponent::View.new(course: mock_course)
    end

  private

    def mock_course
      FakeCourse.new(degree_grade: 1,
        degree_subject_requirements: "Degree Subject Requirements Text Goes Here",
        level: "secondary",
        name: "Super Awesome Course",
        gcse_grade_required: "A*",
        accept_pending_gcse: true,
        accept_gcse_equivalency: true,
        accept_english_gcse_equivalency: true,
        accept_maths_gcse_equivalency: true,
        accept_science_gcse_equivalency: true,
        additional_gcse_equivalencies: "much much more",
        personal_qualities: "Personal Qualities Text Goes Here",
        other_requirements: "Other Requirements Text Goes Here")
    end

    class FakeCourse
      include ActiveModel::Model
      attr_accessor(:degree_grade, :degree_subject_requirements, :level, :name, :gcse_grade_required, :accept_pending_gcse, :accept_gcse_equivalency, :accept_english_gcse_equivalency, :accept_maths_gcse_equivalency, :accept_science_gcse_equivalency, :additional_gcse_equivalencies, :personal_qualities, :other_requirements)

      def enrichment_attribute(params)
        send(params)
      end

      def accept_gcse_equivalency?
        accept_gcse_equivalency
      end
    end
  end
end
