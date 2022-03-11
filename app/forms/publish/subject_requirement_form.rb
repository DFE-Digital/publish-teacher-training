module Publish
  class SubjectRequirementForm
    # TODO: Refactor to use our form object pattern
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :additional_degree_subject_requirements, :degree_subject_requirements

    before_validation :cast_additional_degree_subject_requirements

    validates :additional_degree_subject_requirements, inclusion: { in: [true, false], message: "Select if you have degree subject requirements" }
    validates :degree_subject_requirements, presence: { message: "Enter details of degree subject requirements" }, if: -> { additional_degree_subject_requirements }

    def save(course)
      return false unless valid?

      course.update(
        additional_degree_subject_requirements: additional_degree_subject_requirements,
        degree_subject_requirements: additional_degree_subject_requirements.present? ? degree_subject_requirements : nil,
      )
    end

    def self.build_from_course(course)
      new(
        additional_degree_subject_requirements: course.additional_degree_subject_requirements,
        degree_subject_requirements: course.degree_subject_requirements,
      )
    end

  private

    def cast_additional_degree_subject_requirements
      self.additional_degree_subject_requirements = ActiveModel::Type::Boolean.new.cast(additional_degree_subject_requirements)
    end
  end
end
