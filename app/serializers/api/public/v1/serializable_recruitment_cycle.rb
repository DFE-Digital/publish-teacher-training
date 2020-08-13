module API
  module Public
    module V1
      class SerializableRecruitmentCycle < JSONAPI::Serializable::Resource
        type "recruitment_cycles"

        attributes :year, :application_start_date, :application_end_date
      end
    end
  end
end
