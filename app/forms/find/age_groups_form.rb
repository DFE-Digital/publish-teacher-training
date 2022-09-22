module Find
  class AgeGroupsForm
    include ActiveModel::Model

    attr_accessor :age_group, :city_town_postcode_query, :find_courses, :school_uni_or_provider_query

    def initialize(params: {})
      @params = params
      assign_attributes(params)
    end

    validates :age_group, presence: true
    validates :age_group, inclusion: { in: %w[primary secondary further_education] }
  end
end
