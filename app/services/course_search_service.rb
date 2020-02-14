class CourseSearchService
  def initialize(filter:, sort: nil, course_scope: Course)
    @filter = filter || {}
    @course_scope = course_scope
    @sort = sort
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    scope = course_scope.findable

    scope = scope.by_provider_name_ascending if sort_by_provider_ascending?
    scope = scope.by_provider_name_descending if sort_by_provider_descending?

    scope = scope.with_salary if funding_filter_salary?
    scope = scope.with_qualifications(qualifications) if qualifications.any?
    scope = scope.with_vacancies if has_vacancies?
    scope = scope.with_study_modes(study_types) if study_types.any?
    scope
  end

  private_class_method :new

private

  def sort_by_provider_ascending?
    @sort == "provider.provider_name"
  end

  def sort_by_provider_descending?
    @sort == "-provider.provider_name"
  end

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
