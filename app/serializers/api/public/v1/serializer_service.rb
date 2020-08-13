module API
  module Public
    module V1
      class SerializerService
        def self.call
          new.call
        end

        def call
          {
            Course: API::Public::V1::SerializableCourse,
            Provider: API::Public::V1::SerializableProvider,
            RecruitmentCycle: API::Public::V1::SerializableRecruitmentCycle,
            Site: API::Public::V1::SerializableLocation,
          }
        end
      end
    end
  end
end
