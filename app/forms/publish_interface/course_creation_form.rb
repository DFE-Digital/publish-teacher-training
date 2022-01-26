module PublishInterface
  class CourseCreationForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :course, :params

    def initialize(course: nil, params: {})
      @course = course
      @params = params
    end

  private

    def stash
      valid? && store.set(id, form_store_key, fields.except(*fields_to_ignore_before_stash))
    end
  end
end
