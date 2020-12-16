module API
  module Public
    module V1
      class SerializerService
        include ServicePattern

        def call
          {
            Course: API::Public::V1::SerializableCourse,
            Provider: API::Public::V1::SerializableProvider,
            RecruitmentCycle: API::Public::V1::SerializableRecruitmentCycle,
            Site: API::Public::V1::SerializableLocation,
            SiteStatus: API::Public::V1::SerializableLocationStatus,
            Subject: API::Public::V1::SerializableSubject,
            PrimarySubject: API::Public::V1::SerializableSubject,
            SecondarySubject: API::Public::V1::SerializableSubject,
            ModernLanguagesSubject: API::Public::V1::SerializableSubject,
            FurtherEducationSubject: API::Public::V1::SerializableSubject,
          }
        end
      end
    end
  end
end
