module API
  module Public
    module V1
      class SerializerService
        def call
          {
            Course: API::Public::V1::SerializableCourse,
            Provider: API::Public::V1::SerializableProvider,
            RecruitmentCycle: API::Public::V1::SerializableRecruitmentCycle,
          }
        end
      end
    end
  end
end
