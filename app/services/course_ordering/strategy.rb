# frozen_string_literal: true

module CourseOrdering
  class Strategy
    attr_accessor :sort, :default

    STRATEGIES = {
      default_ordering: DefaultOrderingStrategy,
      api_default_ordering: APIDefaultOrderingStrategy,
      course_asc: CourseAscStrategy,
      course_desc: CourseDescStrategy,
      provider_asc: ProviderAscStrategy,
      provider_desc: ProviderDescStrategy,
      distance: DistanceStrategy
    }.with_indifferent_access.freeze

    def self.find(sort:, default:)
      new(sort:, default:).call
    end

    def initialize(sort:, default:)
      @sort = sort
      @default = default
    end

    #    if provider_name.present?
    #      outer_scope = outer_scope
    #                    .accredited_provider_order(provider_name)
    #                    .ascending_provider_canonical_order
    #    elsif sort_by_provider_ascending?
    #      outer_scope = outer_scope.ascending_provider_canonical_order
    #      outer_scope = outer_scope.select('provider.provider_name', 'course.*')
    #    elsif sort_by_provider_descending?
    #      outer_scope = outer_scope.descending_provider_canonical_order
    #      outer_scope = outer_scope.select('provider.provider_name', 'course.*')
    #    elsif sort_by_course_ascending?
    #      outer_scope = outer_scope.ascending_course_canonical_order
    #    elsif sort_by_course_descending?
    #      outer_scope = outer_scope.descending_course_canonical_order
    #    elsif sort_by_distance?
    #      outer_scope = outer_scope.joins(courses_with_distance_from_origin)
    #      outer_scope = outer_scope.joins(:provider)
    #      outer_scope = outer_scope.select("course.*, distance, #{Course.sanitize_sql(distance_with_university_area_adjustment)}")
    #
    #      outer_scope =
    #        if expand_university?
    #          outer_scope.order(:boosted_distance)
    #        else
    #          outer_scope.order(:distance)
    #        end
    #    else
    #      outer_scope = default_ordering(outer_scope)
    #    end
    def call
      STRATEGIES[strategy_name]
    end

    def strategy_name
      if sort_by_course_ascending?
        :course_asc
      elsif sort_by_course_descending?
        :course_desc
      elsif sort_by_provider_ascending?
        :provider_asc
      elsif sort_by_provider_descending?
        :provider_desc
      elsif sort_by_distance?
        :distance
      else
        default
      end
    end

    def sort_by_course_ascending?
      sort == 'course_asc' || course_asc_requirement
    end

    def sort_by_course_descending?
      sort == 'course_desc' || course_desc_requirement
    end

    def sort_by_provider_ascending?
      sort == 'provider_asc' || provider_asc_requirement
    end

    def sort_by_provider_descending?
      sort == 'provider_desc' || provider_desc_requirement
    end

    def sort_by_distance?
      sort == 'distance'
    end

    def course_asc_requirement
      sort == 'name,provider.provider_name'
    end

    def course_desc_requirement
      sort == '-name,provider.provider_name'
    end

    def provider_asc_requirement
      sort == 'provider.provider_name,name'
    end

    def provider_desc_requirement
      sort == '-provider.provider_name,name'
    end
  end
end
