# frozen_string_literal: true

module API
  module V3
    class SerializableRecruitmentCycle < JSONAPI::Serializable::Resource
      type "recruitment_cycles"

      attributes :year, :application_start_date, :application_end_date

      has_many :providers
    end
  end
end
