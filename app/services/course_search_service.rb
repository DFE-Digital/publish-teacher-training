class CourseSearchService
  def initialize(filter:, sort: nil, course_scope: Course)
    @filter = filter || {}
    @course_scope = course_scope
    @sort = Set.new(sort&.split(","))
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    scope = course_scope.with_locatable_site
    scope = scope.findable

    scope = scope.ascending_canonical_order if sort_by_provider_ascending?
    scope = scope.descending_canonical_order if sort_by_provider_descending?
    scope = scope.by_distance(origin: origin) if sort_by_distance?

    scope = scope.with_salary if funding_filter_salary?
    scope = scope.with_qualifications(qualifications) if qualifications.any?
    scope = scope.with_vacancies if has_vacancies?
    scope = scope.with_study_modes(study_types) if study_types.any?
    scope = scope.with_subjects(subject_codes) if subject_codes.any?
    scope = scope.with_provider_name(provider_name) if provider_name.present?
    scope = scope.with_send if send_courses_filter?
    scope = scope.within(filter[:radius], origin: origin) if locations_filter?
    scope
  end

  private_class_method :new

private

  def locations_filter?
    filter.has_key?(:latitude) &&
      filter.has_key?(:longitude) &&
      filter.has_key?(:radius)
  end

  def sort_by_provider_ascending?
    sort == Set["name", "provider.provider_name"]
  end

  def sort_by_provider_descending?
    sort == Set["-name", "-provider.provider_name"]
  end

  def sort_by_distance?
    sort == Set["distance"]
  end

  def origin
    [filter[:latitude], filter[:longitude]]
  end

  attr_reader :sort, :filter, :course_scope

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

  def subject_codes
    return [] if filter[:subjects].blank?

    filter[:subjects].split(",")
  end

  def provider_name
    return [] if filter[:"provider.provider_name"].blank?

    filter[:"provider.provider_name"]
  end

  def send_courses_filter?
    filter[:send_courses].to_s.downcase == "true"
  end
end
