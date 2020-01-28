class CourseSearch
  def initialize(filter:, recruitment_cycle_year: Settings.current_recruitment_cycle_year)
    @filter = filter || {}
    @recruitment_cycle_year = recruitment_cycle_year
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    scope = Course
      .findable
      .with_recruitment_cycle(recruitment_cycle_year)

    scope = scope.with_salary if funding_filter_salary?
    scope = scope.with_qualifications(qualifications) if qualifications.any?
    scope = scope.with_vacancies if has_vacancies?
    scope = scope.with_study_modes(study_types) if study_types.any?
    scope
  end

  private_class_method :new

private

  attr_reader :filter, :recruitment_cycle_year

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
