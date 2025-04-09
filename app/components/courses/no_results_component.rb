# frozen_string_literal: true

module Courses
  class NoResultsComponent < ViewComponent::Base
    attr_reader :search_params

    def initialize(search_params:)
      @search_params = search_params

      super
    end

    def country
      @search_params[:country]
    end

    def minimum_degree_required
      @search_params[:minimum_degree_required]
    end

    def subjects
      Array(@search_params[:subjects])
    end

    def devolved_nation?
      country.present? && DEVOLVED_NATIONS.include?(country)
    end

    def devolved_nation
      country.to_s.parameterize.underscore
    end

    def try_another_search_content
      t(".try_another_search_content", count: subjects.size)
    end

    def undergraduate_courses?
      minimum_degree_required == "no_degree_required"
    end
  end
end
