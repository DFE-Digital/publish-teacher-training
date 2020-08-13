module API
  module Public
    module V1
      class SerializerService
        def call
          {
            Course: API::Public::V1::SerializableCourse,
            Provider: API::Public::V1::SerializableProvider,
          }
        end
      end
    end
  end
end
