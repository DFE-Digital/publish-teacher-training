# frozen_string_literal: true

module Find
  class CourseTypeAnswerDeterminer
    attr_reader :age_group, :visa_status, :university_degree_status

    def initialize(age_group:, visa_status:, university_degree_status:)
      @age_group = age_group
      @visa_status = visa_status
      @university_degree_status = university_degree_status
    end

    def show_undergraduate_courses?
      no_further_education? && no_degrees? && does_not_require_visa_sponsorship?
    end

    def non_eligible_for_undergraduate_courses?
      no_further_education? && require_visa_sponsorship? && no_degrees?
    end

    private

    def no_further_education?
      !further_education?
    end

    def further_education?
      age_group == 'further_education'
    end

    def require_visa_sponsorship?
      ActiveModel::Type::Boolean.new.cast(visa_status)
    end

    def does_not_require_visa_sponsorship?
      !require_visa_sponsorship?
    end

    def no_degrees?
      !degrees?
    end

    def degrees?
      ActiveModel::Type::Boolean.new.cast(university_degree_status)
    end
  end
end
