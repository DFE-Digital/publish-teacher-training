module PublishInterface
  class CourseCreationForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :course

    def initialize(course)
      @course = course
    end
  end
end
