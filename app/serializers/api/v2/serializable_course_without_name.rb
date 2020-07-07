module API
  module V2
    class SerializableCourseWithoutName < SerializableCourse
    end
  end
end

API::V2::SerializableCourseWithoutName.instance_variable_get(:@attribute_blocks).delete(:name)
