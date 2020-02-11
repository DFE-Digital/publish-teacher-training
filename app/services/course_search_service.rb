class CourseSearchService
  def initialize(filter:, course_scope: Course)
    @filter = filter || {}
    @course_scope = course_scope
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    scope = course_scope.findable

    scope = scope.with_salary if funding_filter_salary?
    scope = scope.with_qualifications(qualifications) if qualifications.any?
    scope = scope.with_vacancies if has_vacancies?
    scope = scope.with_study_modes(study_types) if study_types.any?
    scope
  end

  private_class_method :new

private

  attr_reader :filter, :course_scope

  def funding_filter_salary?
    filter[:funding] == "salary"
  end

  def qualifications
    return [] if filter[:qualification].blank?

    filter[:qualification].split(",")
  end

  def has_vacancies?
    filter[:has_vacancies].to_s.downcase == "true"
  end

  def study_types
    return [] if filter[:study_type].blank?

    filter[:study_type].split(",")
  end
end
