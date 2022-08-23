module Find
  class CoursesByLocationOrTrainingProviderForm
    include ActiveModel::Model
    attr_accessor :params, :find_courses, :city_town_postcode_query, :school_uni_or_provider_query

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
  end
end
