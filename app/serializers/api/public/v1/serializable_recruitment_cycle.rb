module API
  module Public
    module V1
      class SerializableRecruitmentCycle < JSONAPI::Serializable::Resource
        type "recruitment_cycles"

        attributes :application_start_date,
          :application_end_date

        attribute :year do
          @object.year.to_i
        end
      end
    end
  end
end
