module Find
  class CoursesByLocationOrTrainingProviderForm
    include ActiveModel::Model

    NO_OPTION = nil
    LOCATION_OPTION = "1".freeze

    attr_accessor :params, :find_courses, :city_town_postcode_query, :school_uni_or_provider_query, :prev_l, :prev_loc, :prev_lng, :prev_lat, :prev_rad, :prev_query, :prev_lq

    validate :valid_selections

    def initialize(params: {})
      @params = params
      assign_attributes(params)
    end

  private

    def valid_selections
      if params[:find_courses].blank?
        errors.add(:find_courses, :blank)
      elsif params[:find_courses] == "by_city_town_postcode" && params[:city_town_postcode_query].blank?
        errors.add(:city_town_postcode_query, :blank)
      elsif params[:find_courses] == "by_school_uni_or_provider" && params[:school_uni_or_provider_query].blank?
        errors.add(:school_uni_or_provider_query, :blank)
      end
    end

    def selected_option
      @params[:l]
    end

    def location_query
      @params[:lq]
    end

    def search_radius
      @params[:rad]
    end

    def country(results)
      flattened_results = results.address_components.map(&:values).flatten
      countries = [DEVOLVED_NATIONS, "England"].flatten

      countries.each { |country| return country if flattened_results.include?(country) }
    end
  end
end
