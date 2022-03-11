module Publish
  class DegreeStartForm
    # TODO: Refactor to use our form object pattern
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    attr_accessor :degree_grade_required

    before_validation :cast_degree_grade_required

    validates :degree_grade_required, inclusion: { in: [true, false], message: "Select if you require a minimum degree classification" }

    def save(course)
      return false unless valid? && degree_grade_required_is_false?

      course.update(degree_grade: "not_required")
    end

    def build_from_course(course)
      self.degree_grade_required = handle_degree_grade_required(course)
    end

  private

    def cast_degree_grade_required
      self.degree_grade_required = ActiveModel::Type::Boolean.new.cast(degree_grade_required)
    end

    def degree_grade_required_is_false?
      degree_grade_required == false
    end

    def handle_degree_grade_required(course)
      if course.degree_grade == "not_required"
        false
      elsif course.degree_grade.present?
        true
      end
    end
  end
end
