# frozen_string_literal: true

module Courses
  class NoResultsComponent < ViewComponent::Base
    include ActionView::Helpers::NumberHelper

    attr_reader :country, :minimum_degree_required

    def initialize(country:, minimum_degree_required:, subjects:, search_params:, radius_links_query: nil)
      @country = country
      @minimum_degree_required = minimum_degree_required
      @search_params = search_params
      @radius_links_query = radius_links_query
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

    def search_by_provider_name
      @search_params[:provider_name]
    end

    def search_by_location
      @search_params[:location]
    end

    def undergraduate_courses?
      @minimum_degree_required == "no_degree_required"
    end
  end
end
