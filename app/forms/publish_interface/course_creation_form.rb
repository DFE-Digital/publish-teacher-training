module PublishInterface
  class CourseCreationForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :course, :params, :fields

    def initialize(course: Course.new, params: {})
      @course = course
      @params = params
      @fields = compute_fields
    end

  private

    def compute_fields
      raise(NotImplementedError)
    end

    def stash
      valid? && store.set(id, form_store_key, fields.except(*fields_to_ignore_before_stash))
    end
  end
end
