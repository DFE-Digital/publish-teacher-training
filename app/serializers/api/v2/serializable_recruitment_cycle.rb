module API
  module V2
    class SerializableRecruitmentCycle < JSONAPI::Serializable::Resource
      type "recruitment_cycles"

      attributes :year, :application_start_date, :application_end_date

      has_many :providers
    end
  end
end
