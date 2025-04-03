# frozen_string_literal: true

module Courses
  class NoResultsComponent < ViewComponent::Base
    attr_reader :country, :minimum_degree_required

    def initialize(country:, minimum_degree_required:, subjects:)
      @country = country
      @minimum_degree_required = minimum_degree_required
      @subjects = Array(subjects)

      super
    end

    def devolved_nation?
      @country.present? && DEVOLVED_NATIONS.include?(@country)
    end

    def devolved_nation
      @country.to_s.parameterize.underscore
    end

    def try_another_search_content
      t(".try_another_search_content", count: @subjects.size)
    end

    def undergraduate_courses?
      @minimum_degree_required == "no_degree_required"
    end
  end
end
